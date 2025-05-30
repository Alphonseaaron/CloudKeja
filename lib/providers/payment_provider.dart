import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Added for DateTimeRange
import 'package:cloudkeja/models/invoice_models.dart';
import 'package:cloudkeja/models/notification_model.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/models/payment_model.dart';
// import 'package:cloudkeja/providers/auth_provider.dart'; // Not directly used if _auth is sufficient
// import 'package:cloudkeja/providers/post_provider.dart'; // Not directly used
import 'package:cloudkeja/providers/tenant_model.dart';
import 'package:intl/intl.dart'; // For date formatting

class PaymentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  //RENT SPACE
  Future<void> rentSpace(String userId, SpaceModel space) async {
    final usersRef = _firestore.collection('users');

    await usersRef.doc(userId).update({
      'rentedPlaces': FieldValue.arrayUnion([space.id])
    });

    await _firestore
        .collection('landlords')
        .doc(space.ownerId!)
        .collection('tenants')
        .add({
      'user': userId,
      'space': space.id,
      'joinedAt': Timestamp.now(),
    });

    await usersRef
        .doc(space.ownerId!)
        .update({'balance': FieldValue.increment(space.price!)});

    final not = NotificationModel(
      title: 'Rented ${space.spaceName!}',
      message: 'You have successfully rented a ${space.spaceName!}',
      imageUrl: space.images?.first ?? '',
      createdAt: Timestamp.now(),
    );
    await _firestore
        .collection('userData')
        .doc(userId)
        .collection('notifications')
        .add(not.toJson());

    await _firestore.collection('transactions').add({
      'userId': userId,
      'description': 'Initial rent/deposit for ${space.spaceName}',
      'amount': space.price,
      'currency': 'KES',
      'status': 'Successful',
      'date': Timestamp.now(),
      'propertyId': space.id,
      'paymentMethod': 'System (Rental Agreement)',
      'transactionId': 'RENTAL-${DateTime.now().millisecondsSinceEpoch}',
      'spaceName': space.spaceName,
      'spaceAddress': space.address,
      'type': 'RentalAgreement',
    });
    notifyListeners();
  }

  Future<void> recordTenantRentPayment({
    required String leaseId,
    required String tenantId,
    required String landlordId,
    required String propertyId,
    required String paymentCycle,
    required double amountDueForCycle,
    required DateTime dueDateForCycle,
    required double amountActuallyPaid,
    required DateTime actualPaymentDate,
    String? paymentMethodNotes,
    String? paymentMethod = "Mpesa",
  }) async {
    debugPrint('Recording payment for lease: $leaseId, cycle: $paymentCycle');
    try {
      final leasePaymentsRef = _firestore.collection('lease_payments');

      QuerySnapshot existingPaymentQuery = await leasePaymentsRef
          .where('leaseId', isEqualTo: leaseId)
          .where('paymentCycle', isEqualTo: paymentCycle)
          .limit(1)
          .get();

      final now = Timestamp.now();
      bool isFullPayment = amountActuallyPaid >= amountDueForCycle;

      Map<String, dynamic> paymentData = {
          'leaseId': leaseId,
          'tenantId': tenantId,
          'landlordId': landlordId,
          'propertyId': propertyId,
          'paymentCycle': paymentCycle,
          'amountDue': amountDueForCycle,
          'dueDate': Timestamp.fromDate(dueDateForCycle),
          'amountPaid': amountActuallyPaid,
          'paymentDate': Timestamp.fromDate(actualPaymentDate),
          'isFullPayment': isFullPayment,
          'paymentStatusNotes': paymentMethodNotes ?? (isFullPayment ? 'Payment completed' : (amountActuallyPaid > 0 ? 'Partial payment received' : 'Payment attempt recorded')),
          'paymentMethod': paymentMethod,
          'updatedAt': now,
      };

      if (existingPaymentQuery.docs.isNotEmpty) {
        DocumentReference paymentDocRef = existingPaymentQuery.docs.first.reference;
        await paymentDocRef.update(paymentData);
        debugPrint('Updated existing lease payment: ${paymentDocRef.id}');
      } else {
        paymentData['createdAt'] = now;
        await leasePaymentsRef.add(paymentData);
        debugPrint('Created new lease payment record.');
      }

      await _firestore.collection('users').doc(landlordId).update({
        'balance': FieldValue.increment(amountActuallyPaid)
      });
      debugPrint('Updated landlord ($landlordId) balance by $amountActuallyPaid.');

    } catch (e) {
      debugPrint('Error in recordTenantRentPayment: $e');
      throw Exception('Failed to record rent payment: ${e.toString()}');
    }
  }

  // Refactored for monthly summary
  Future<Map<String, double>> getLandlordMonthlyIncomeSummary({
    required String landlordId,
    int numberOfMonths = 6, // Default to last 6 months
  }) async {
    debugPrint('Fetching monthly income summary for landlord $landlordId for last $numberOfMonths months.');

    // Initialize map for the last N months with 0.0 income
    Map<String, double> monthlyIncome = {};
    DateTime currentDate = DateTime.now();
    for (int i = 0; i < numberOfMonths; i++) {
      DateTime monthDate = DateTime(currentDate.year, currentDate.month - i, 1);
      String monthKey = DateFormat('yyyy-MM').format(monthDate);
      monthlyIncome[monthKey] = 0.0;
    }

    // Calculate the start date for the query
    DateTime firstMonthToFetch = DateTime(currentDate.year, currentDate.month - (numberOfMonths - 1), 1);
    Timestamp startDateTimestamp = Timestamp.fromDate(firstMonthToFetch);

    try {
      Query query = _firestore
          .collection('lease_payments')
          .where('landlordId', isEqualTo: landlordId)
          .where('paymentDate', isGreaterThanOrEqualTo: startDateTimestamp)
          // Optional: Add .where('isFullPayment', isEqualTo: true) if only full payments count towards income summary
          ;

      final snapshot = await query.get();
      debugPrint('Fetched ${snapshot.docs.length} lease payments for monthly summary for landlord $landlordId.');

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('amountPaid') && data['amountPaid'] is num && data.containsKey('paymentDate') && data['paymentDate'] is Timestamp) {
            double amount = (data['amountPaid'] as num).toDouble();
            DateTime paymentDateTime = (data['paymentDate'] as Timestamp).toDate();
            String monthKey = DateFormat('yyyy-MM').format(paymentDateTime);

            // Check if this month is within our range of interest
            if (monthlyIncome.containsKey(monthKey)) {
              monthlyIncome.update(monthKey, (value) => value + amount, ifAbsent: () => amount);
            }
          }
        }
      }

      // Sort the map by month ascending (keys are "YYYY-MM")
      var sortedKeys = monthlyIncome.keys.toList()..sort();
      Map<String, double> sortedMonthlyIncome = { for (var k in sortedKeys) k : monthlyIncome[k]! };

      debugPrint('Monthly income summary for landlord $landlordId: $sortedMonthlyIncome');
      return sortedMonthlyIncome;

    } catch (e) {
      debugPrint('Error fetching landlord monthly income summary: $e');
      throw Exception('Could not fetch monthly income summary: $e');
    }
  }

  // This method is kept for overall total income if needed elsewhere, or can be removed
  // if monthly summary is always preferred.
  Future<double> getLandlordTotalIncomeFromLeasePayments({
    required String landlordId,
    DateTimeRange? dateFilter,
  }) async {
    debugPrint('Fetching total income for landlord $landlordId from lease_payments.');
    double totalIncome = 0.0;
    try {
      Query query = _firestore
          .collection('lease_payments')
          .where('landlordId', isEqualTo: landlordId);

      if (dateFilter != null) {
        query = query
            .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(dateFilter.start))
            .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(dateFilter.end.year, dateFilter.end.month, dateFilter.end.day, 23, 59, 59)));
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('amountPaid') && data['amountPaid'] is num) {
            totalIncome += (data['amountPaid'] as num).toDouble();
          }
        }
      }
      debugPrint('Total income calculated for landlord $landlordId: $totalIncome');
      return totalIncome;
    } catch (e) {
      debugPrint('Error fetching landlord total income from lease_payments: $e');
      throw Exception('Could not fetch total income: $e');
    }
  }


  Future<void> checkOut(String userId, SpaceModel space) async {
    final usersRef = _firestore.collection('users');
    await usersRef.doc(userId).update({
      'rentedPlaces': FieldValue.arrayRemove([space.id])
    });

    await _firestore
        .collection('landlords')
        .doc(space.ownerId!)
        .collection('tenants')
        .where('user', isEqualTo: userId)
        .where('space', isEqualTo: space.id)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        doc.reference.delete();
      }
    });

    final not = NotificationModel(
      title: 'Checked out ${space.spaceName!}',
      message: 'You have successfully checked out of ${space.spaceName!}',
      imageUrl: space.images?.first ?? '',
      createdAt: Timestamp.now(),
    );
    await _firestore
        .collection('userData')
        .doc(userId)
        .collection('notifications')
        .add(not.toJson());

    notifyListeners();
  }

  Future<List<TenantModel>> fetchTenants() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final usersRef = _firestore.collection('users');
    final spaceRef = _firestore.collection('spaces');

    final results = await _firestore
        .collection('landlords')
        .doc(uid)
        .collection('tenants')
        .get();

    List<TenantModel> tenants = [];

    for (var element in results.docs) {
      final userData = await usersRef.doc(element['user'] as String?).get();
      final spaceData = await spaceRef.doc(element['space'] as String?).get();

      if (userData.exists && spaceData.exists) {
        final user = UserModel.fromJson(userData.data());
        final space = SpaceModel.fromJson(spaceData.data());

        if (tenants.where((t) => t.user?.userId == user.userId && t.space?.id == space.id).isEmpty) {
          tenants.add(TenantModel(user: user, space: space));
        }
      }
    }
    return tenants;
  }

  Future<void> payRent(String ownerId, double amount) async {
    await _firestore
        .collection('users')
        .doc(ownerId)
        .update({'balance': FieldValue.increment(amount)});
  }

  Future<Invoice> getTransactions() async {
    final results = await _firestore.collection('transactions').orderBy('date', descending: true).get();
    final currentUser = _auth.currentUser;

    final itemsForInvoice = results.docs.map((doc) {
      final data = doc.data();
      return InvoiceItem(
        description: data['spaceName'] as String? ?? data['description'] as String? ?? 'N/A',
        quantity: 1,
        unitPrice: (data['amount'] as num?)?.toDouble() ?? 0.0,
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        name: data['spaceAddress'] as String? ?? '',
      );
    }).toList();

    return Invoice(
      info: InvoiceInfo(
        date: DateTime.now(),
        description: 'Platform Transaction Report',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        number: 'TRANS-${DateFormat('yyyyMMdd').format(DateTime.now())}',
      ),
      supplier: Supplier(
        name: currentUser?.displayName ?? currentUser?.email ?? 'CloudKeja Platform',
        address: 'CloudKeja Inc, Nairobi, Kenya',
        paymentInfo: currentUser?.email ?? 'N/A'
      ),
      customer: Customer(name: 'Platform Wide', address: ''),
      items: itemsForInvoice,
    );
  }

  Future<List<PaymentModel>> fetchUserPaymentHistory({
    DateTimeRange? dateFilter,
    String? specificUserId,
    bool forceRefresh = false,
  }) async {
    final targetUserId = specificUserId ?? _auth.currentUser?.uid;

    if (targetUserId == null) {
      return [];
    }

    try {
      Query query = _firestore
          .collection('transactions')
          .where('userId', isEqualTo: targetUserId)
          .orderBy('date', descending: true);

      if (dateFilter != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateFilter.start))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(dateFilter.end.year, dateFilter.end.month, dateFilter.end.day, 23, 59, 59)));
      }

      final snapshot = await query.get();
      final payments = snapshot.docs.map((doc) => PaymentModel.fromSnapshot(doc)).toList();
      return payments;
    } catch (e) {
      debugPrint('Error fetching user payment history: $e');
      throw Exception('Could not fetch payment history: $e');
    }
  }
}
