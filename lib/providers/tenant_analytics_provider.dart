import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For DateTimeRange, if used in methods
import 'package:cloudkeja/models/tenant_payment_metrics_model.dart';

class TenantAnalyticsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const int _earlyDaysThreshold = 3;
  static const int _gracePeriodDays = 3;

  // Test tenant IDs are now only relevant if you manually seed data with these IDs
  // and want to test specific scenarios by passing these IDs to the calculate method.
  static const String goodPayerTestId = 'goodPayerTest';
  static const String badPayerTestId = 'badPayerTest';
  static const String mixedPayerTestId = 'mixedPayerTest';
  static const String defaultTestTenantId = 'testTenant1';

  Future<TenantPaymentMetrics?> calculateTenantPaymentMetrics({
    required String tenantId,
    String? leaseId,
  }) async {
    try {
      debugPrint('Calculating payment metrics for tenantId: $tenantId, leaseId: $leaseId from Firestore.');

      // --- Live Firestore Query ---
      Query query = _firestore.collection('lease_payments').where('tenantId', isEqualTo: tenantId);
      if (leaseId != null && leaseId.isNotEmpty) {
        query = query.where('leaseId', isEqualTo: leaseId);
      }
      query = query.orderBy('dueDate', ascending: true);

      final snapshot = await query.get();
      final paymentDocs = snapshot.docs;

      List<LeasePaymentData> leasePayments = paymentDocs
          .map((doc) => LeasePaymentData.fromSnapshot(doc))
          .toList();

      debugPrint('Fetched ${leasePayments.length} payment records from Firestore for tenant $tenantId.');

      if (leasePayments.isEmpty) {
        debugPrint('No payment data found in Firestore for tenantId: $tenantId.');
        return TenantPaymentMetrics(overallSummary: "No Payment Data Available");
      }

      // --- Metric Calculation Logic (remains the same) ---
      int totalPaymentsAnalyzed = 0;
      int onTimePayments = 0;
      int earlyPayments = 0;
      int latePayments = 0;
      double totalDaysLate = 0;

      int currentOnTimeStreak = 0;
      int maxOnTimeStreak = 0;
      int currentLateStreak = 0;
      int maxLateStreak = 0;

      List<AnalyzedPaymentRecordVo> analyzedRecords = [];

      for (var payment in leasePayments) {
        if (payment.paymentDate == null || payment.amountPaid == null) {
          if (payment.dueDate.toDate().isBefore(DateTime.now())) { // Only consider overdue if not paid
             analyzedRecords.add(AnalyzedPaymentRecordVo(
                originalPaymentId: payment.id,
                paymentCycle: payment.paymentCycle,
                dueDate: payment.dueDate.toDate(),
                paymentDate: payment.dueDate.toDate(),
                amountDue: payment.amountDue,
                amountPaid: payment.amountPaid ?? 0.0,
                status: "Unpaid", // Status for records in the log
                daysDifference: DateTime.now().difference(payment.dueDate.toDate()).inDays,
              ));
          }
          // Skip unpaid/partially setup records from main metric calculations for now
          // Or adjust logic to include them if "Unpaid" should affect streaks/percentages.
          continue;
        }

        totalPaymentsAnalyzed++;
        DateTime dueDate = payment.dueDate.toDate();
        DateTime paymentDate = payment.paymentDate!.toDate();

        DateTime dueDateOnly = DateTime.utc(dueDate.year, dueDate.month, dueDate.day);
        DateTime paymentDateOnly = DateTime.utc(paymentDate.year, paymentDate.month, paymentDate.day);

        int daysDifference = dueDateOnly.difference(paymentDateOnly).inDays;

        String status;

        if (payment.amountPaid! < payment.amountDue) {
          status = "Partial";
          currentOnTimeStreak = 0;
          currentLateStreak = 0;
        } else if (daysDifference >= _earlyDaysThreshold) {
          status = "Early";
          earlyPayments++;
          currentOnTimeStreak++;
          maxOnTimeStreak = currentOnTimeStreak > maxOnTimeStreak ? currentOnTimeStreak : maxOnTimeStreak;
          currentLateStreak = 0;
        } else if (daysDifference >= 0 || (daysDifference < 0 && daysDifference.abs() <= _gracePeriodDays)) {
          status = "On-Time";
          onTimePayments++;
          currentOnTimeStreak++;
          maxOnTimeStreak = currentOnTimeStreak > maxOnTimeStreak ? currentOnTimeStreak : maxOnTimeStreak;
          currentLateStreak = 0;
        } else {
          status = "Late";
          latePayments++;
          // Only count days late beyond the grace period towards the average
          int effectiveDaysLate = daysDifference.abs() - _gracePeriodDays;
          if (effectiveDaysLate > 0) {
            totalDaysLate += effectiveDaysLate;
          }
          currentLateStreak++;
          maxLateStreak = currentLateStreak > maxLateStreak ? currentLateStreak : maxLateStreak;
          currentOnTimeStreak = 0;
        }

        analyzedRecords.add(AnalyzedPaymentRecordVo(
          originalPaymentId: payment.id,
          paymentCycle: payment.paymentCycle,
          dueDate: dueDate,
          paymentDate: paymentDate,
          amountDue: payment.amountDue,
          amountPaid: payment.amountPaid!,
          status: status,
          daysDifference: daysDifference,
        ));
      }

      double onTimePaymentPercentage = 0;
      if (totalPaymentsAnalyzed > 0) {
        onTimePaymentPercentage = ((earlyPayments + onTimePayments) / totalPaymentsAnalyzed) * 100;
      }

      double averageDaysLate = 0;
      if (latePayments > 0) {
        averageDaysLate = totalDaysLate / latePayments;
      }

      String overallSummary;
      if (totalPaymentsAnalyzed == 0 && analyzedRecords.where((r) => r.status == "Unpaid").isEmpty) { // Check if there are no payments at all, not even unpaid ones in log
        overallSummary = "No Payment Records";
      } else if (totalPaymentsAnalyzed == 0 && analyzedRecords.where((r) => r.status == "Unpaid").isNotEmpty) {
        overallSummary = "Pending Initial Payments"; // Or "Overdue" if all are unpaid and past due
      }
      else if (onTimePaymentPercentage >= 90 && latePayments <= 1) {
        overallSummary = "Excellent";
      } else if (onTimePaymentPercentage >= 70) {
        overallSummary = "Good";
      } else if (onTimePaymentPercentage >= 50) {
        overallSummary = "Needs Improvement";
      } else {
        overallSummary = "Poor";
      }

      return TenantPaymentMetrics(
        totalPaymentsAnalyzed: totalPaymentsAnalyzed,
        onTimePayments: onTimePayments,
        earlyPayments: earlyPayments,
        latePayments: latePayments,
        onTimePaymentPercentage: onTimePaymentPercentage,
        averageDaysLate: averageDaysLate,
        currentConsecutiveOnTimeStreak: currentOnTimeStreak,
        longestConsecutiveOnTimeStreak: maxOnTimeStreak,
        currentConsecutiveLateStreak: currentLateStreak,
        longestConsecutiveLateStreak: maxLateStreak,
        overallSummary: overallSummary,
        analyzedRecords: analyzedRecords,
      );

    } catch (e) {
      debugPrint('Error calculating tenant payment metrics for $tenantId from Firestore: $e');
      return TenantPaymentMetrics(overallSummary: "Error Calculating Metrics");
    }
  }
}
