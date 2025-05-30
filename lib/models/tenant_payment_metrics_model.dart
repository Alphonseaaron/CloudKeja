import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For @required

// Value Object for displaying individual analyzed payment records
class AnalyzedPaymentRecordVo {
  final String originalPaymentId;
  final String paymentCycle; // e.g., "Jan 2023 Rent", "Q1 Service Charge"
  final DateTime dueDate;
  final DateTime paymentDate;
  final double amountDue;
  final double amountPaid;
  final String status; // "Early", "On-Time", "Late", "Partial", "Unpaid"
  final int daysDifference; // Positive if paid early, negative if late, 0 if on time on due date

  AnalyzedPaymentRecordVo({
    required this.originalPaymentId,
    required this.paymentCycle,
    required this.dueDate,
    required this.paymentDate,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
    required this.daysDifference,
  });
}

class TenantPaymentMetrics {
  final int totalPaymentsAnalyzed;
  final int onTimePayments;
  final int earlyPayments;
  final int latePayments;

  final double onTimePaymentPercentage;
  final double averageDaysLate;

  final int currentConsecutiveOnTimeStreak;
  final int longestConsecutiveOnTimeStreak;
  final int currentConsecutiveLateStreak;
  final int longestConsecutiveLateStreak;

  final String overallSummary;
  final List<AnalyzedPaymentRecordVo> analyzedRecords;

  TenantPaymentMetrics({
    this.totalPaymentsAnalyzed = 0,
    this.onTimePayments = 0,
    this.earlyPayments = 0,
    this.latePayments = 0,
    this.onTimePaymentPercentage = 0.0,
    this.averageDaysLate = 0.0,
    this.currentConsecutiveOnTimeStreak = 0,
    this.longestConsecutiveOnTimeStreak = 0,
    this.currentConsecutiveLateStreak = 0,
    this.longestConsecutiveLateStreak = 0,
    this.overallSummary = "No Data",
    this.analyzedRecords = const [],
  });
}

class LeasePaymentData {
  final String id;
  final String tenantId;
  final String? leaseId;
  final String paymentCycle;
  final Timestamp dueDate;
  final Timestamp? paymentDate;
  final double amountDue;
  final double? amountPaid;

  LeasePaymentData({
    required this.id,
    required this.tenantId,
    this.leaseId,
    required this.paymentCycle,
    required this.dueDate,
    this.paymentDate,
    required this.amountDue,
    this.amountPaid,
  });

  factory LeasePaymentData.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return LeasePaymentData(
      id: snapshot.id,
      tenantId: data['tenantId'] as String,
      leaseId: data['leaseId'] as String?,
      paymentCycle: data['paymentCycle'] as String,
      dueDate: data['dueDate'] as Timestamp,
      paymentDate: data['paymentDate'] as Timestamp?,
      amountDue: (data['amountDue'] as num).toDouble(),
      amountPaid: (data['amountPaid'] as num?)?.toDouble(),
    );
  }

  static final DateTime _now = DateTime.now();

  static List<LeasePaymentData> getGoodPayerData(String tenantId) {
    return List.generate(12, (index) {
      int month = _now.month - index;
      int year = _now.year;
      if (month <= 0) {
        month += 12;
        year -= 1;
      }
      DateTime dueDate = DateTime(year, month, 5);
      DateTime paymentDate;
      // Mostly early or on-time
      if (index % 4 == 0 && index != 0) { // One late payment for variety
        paymentDate = dueDate.add(const Duration(days: 4)); // Late by 4 days (1 day after grace)
      } else if (index % 3 == 0) { // Some on-time (within grace)
        paymentDate = dueDate.add(const Duration(days: 2)); // On-time (within grace)
      } else { // Mostly early
        paymentDate = dueDate.subtract(const Duration(days: 4)); // Early
      }
      return LeasePaymentData(
        id: 'good_p${index + 1}', tenantId: tenantId, paymentCycle: '${DateFormat.MMM().format(dueDate)} $year Rent',
        dueDate: Timestamp.fromDate(dueDate), paymentDate: Timestamp.fromDate(paymentDate),
        amountDue: 1000, amountPaid: 1000,
      );
    }).reversed.toList(); // Chronological order
  }

  static List<LeasePaymentData> getBadPayerData(String tenantId) {
    return List.generate(12, (index) {
      int month = _now.month - index;
      int year = _now.year;
      if (month <= 0) {
        month += 12;
        year -= 1;
      }
      DateTime dueDate = DateTime(year, month, 5);
      DateTime paymentDate;
      // Mostly late payments
      if (index % 4 == 0 && index != 0) { // One on-time payment for variety
        paymentDate = dueDate;
      } else { // Mostly late
        paymentDate = dueDate.add(Duration(days: 7 + (index % 3 * 3))); // Varying degrees of lateness (7, 10, 13 days)
      }
      return LeasePaymentData(
        id: 'bad_p${index + 1}', tenantId: tenantId, paymentCycle: '${DateFormat.MMM().format(dueDate)} $year Rent',
        dueDate: Timestamp.fromDate(dueDate), paymentDate: Timestamp.fromDate(paymentDate),
        amountDue: 1000, amountPaid: 1000,
      );
    }).reversed.toList();
  }

  static List<LeasePaymentData> getMixedPayerData(String tenantId) {
     return List.generate(12, (index) {
      int month = _now.month - index;
      int year = _now.year;
      if (month <= 0) {
        month += 12;
        year -= 1;
      }
      DateTime dueDate = DateTime(year, month, 5);
      DateTime paymentDate;
      // Mix of early, on-time, and late
      if (index % 3 == 0) { // Early
        paymentDate = dueDate.subtract(const Duration(days: 5));
      } else if (index % 3 == 1) { // Late
        paymentDate = dueDate.add(const Duration(days: 6));
      } else { // On-time (within grace)
        paymentDate = dueDate.add(const Duration(days: 1));
      }
      // One partial payment
      double amountPaid = (index == 5) ? 800 : 1000;

      return LeasePaymentData(
        id: 'mix_p${index + 1}', tenantId: tenantId, paymentCycle: '${DateFormat.MMM().format(dueDate)} $year Rent',
        dueDate: Timestamp.fromDate(dueDate), paymentDate: Timestamp.fromDate(paymentDate),
        amountDue: 1000, amountPaid: amountPaid,
      );
    }).reversed.toList();
  }

  // Original dummyData can be kept for other tests or removed if not needed
  static List<LeasePaymentData> get dummyData {
    // This can now be a default or a specific scenario if needed elsewhere
    return getGoodPayerData('testTenant1'); // Default to good payer for existing tests
  }
}
