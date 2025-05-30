import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/material.dart'; // For debugPrint
// Assuming TenantAnalyticsProvider is in this path if its constants are used.
// For this task, we'll define test IDs locally or pass them directly.
// import 'package:cloudkeja/providers/tenant_analytics_provider.dart';
import 'package:intl/intl.dart'; // For date formatting in payment cycles

class TestDataSeeder {
  // --- LEASE PAYMENT SEED DATA (Existing) ---
  static List<Map<String, dynamic>> getLeasePaymentSeedData() {
    final now = DateTime.now();
    // Use distinct IDs for clarity in testing different data sets
    final String goodPayerTenantId = 'tenantGoodPayer001';
    final String badPayerTenantId = 'tenantBadPayer001';
    final String mixedPayerTenantId = 'tenantMixedPayer001';

    final String testLandlord1Id = 'landlord001';
    final String testLandlord2Id = 'landlord002';

    final String testProperty1Id = 'property001';
    final String testProperty2Id = 'property002';
    final String testProperty3Id = 'property003';

    final String testLease1Id = 'lease001';
    final String testLease2Id = 'lease002';
    final String testLease3Id = 'lease003';


    return [
      // Payments for Tenant 'goodPayerTenantId'
      {
        'leaseId': testLease1Id, 'tenantId': goodPayerTenantId, 'landlordId': testLandlord1Id, 'propertyId': testProperty1Id,
        'paymentCycle': 'Rent - ${DateFormat.MMM().format(now.subtract(const Duration(days: 90)))} ${now.year}',
        'amountDue': 1000.0, 'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 90))),
        'amountPaid': 1000.0, 'paymentDate': Timestamp.fromDate(now.subtract(const Duration(days: 92))), // Early
        'isFullPayment': true, 'paymentStatusNotes': 'Paid early via Mpesa', 'paymentMethod': 'Mpesa',
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      },
      {
        'leaseId': testLease1Id, 'tenantId': goodPayerTenantId, 'landlordId': testLandlord1Id, 'propertyId': testProperty1Id,
        'paymentCycle': 'Rent - ${DateFormat.MMM().format(now.subtract(const Duration(days: 60)))} ${now.year}',
        'amountDue': 1000.0, 'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 60))),
        'amountPaid': 1000.0, 'paymentDate': Timestamp.fromDate(now.subtract(const Duration(days: 60))), // On-Time
        'isFullPayment': true, 'paymentStatusNotes': 'Paid on time', 'paymentMethod': 'Mpesa',
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      },
       {
        'leaseId': testLease1Id, 'tenantId': goodPayerTenantId, 'landlordId': testLandlord1Id, 'propertyId': testProperty1Id,
        'paymentCycle': 'Rent - ${DateFormat.MMM().format(now.subtract(const Duration(days: 30)))} ${now.year}',
        'amountDue': 1000.0, 'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        'amountPaid': 1000.0, 'paymentDate': Timestamp.fromDate(now.subtract(const Duration(days: 28))), // On-Time (within grace)
        'isFullPayment': true, 'paymentStatusNotes': 'Paid within grace', 'paymentMethod': 'Mpesa',
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      },

      // Payments for Tenant 'badPayerTenantId'
      {
        'leaseId': testLease2Id, 'tenantId': badPayerTenantId, 'landlordId': testLandlord2Id, 'propertyId': testProperty2Id,
        'paymentCycle': 'Rent - ${DateFormat.MMM().format(now.subtract(const Duration(days: 90)))} ${now.year}',
        'amountDue': 1200.0, 'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 90))),
        'amountPaid': 1200.0, 'paymentDate': Timestamp.fromDate(now.subtract(const Duration(days: 80))), // Late
        'isFullPayment': true, 'paymentStatusNotes': 'Paid very late', 'paymentMethod': 'Mpesa',
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      },
       {
        'leaseId': testLease2Id, 'tenantId': badPayerTenantId, 'landlordId': testLandlord2Id, 'propertyId': testProperty2Id,
        'paymentCycle': 'Rent - ${DateFormat.MMM().format(now.subtract(const Duration(days: 60)))} ${now.year}',
        'amountDue': 1200.0, 'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 60))),
        'amountPaid': 1200.0, 'paymentDate': Timestamp.fromDate(now.subtract(const Duration(days: 45))), // Late
        'isFullPayment': true, 'paymentStatusNotes': 'Paid extremely late', 'paymentMethod': 'Mpesa',
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      },

      // Payments for Tenant 'mixedPayerTenantId'
      {
        'leaseId': testLease3Id, 'tenantId': mixedPayerTenantId, 'landlordId': testLandlord1Id, 'propertyId': testProperty3Id,
        'paymentCycle': 'Rent - ${DateFormat.MMM().format(now.subtract(const Duration(days: 90)))} ${now.year}',
        'amountDue': 1500.0, 'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 90))),
        'amountPaid': 1500.0, 'paymentDate': Timestamp.fromDate(now.subtract(const Duration(days: 95))), // Early
        'isFullPayment': true, 'paymentStatusNotes': 'Paid early', 'paymentMethod': 'Bank',
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      },
      {
        'leaseId': testLease3Id, 'tenantId': mixedPayerTenantId, 'landlordId': testLandlord1Id, 'propertyId': testProperty3Id,
        'paymentCycle': 'Rent - ${DateFormat.MMM().format(now.subtract(const Duration(days: 60)))} ${now.year}',
        'amountDue': 1500.0, 'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 60))),
        'amountPaid': 700.0, 'paymentDate': Timestamp.fromDate(now.subtract(const Duration(days: 58))), // Partial & On-Time (within grace)
        'isFullPayment': false, 'paymentStatusNotes': 'Partial payment made on time', 'paymentMethod': 'Mpesa',
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      },
       {
        'leaseId': testLease3Id, 'tenantId': mixedPayerTenantId, 'landlordId': testLandlord1Id, 'propertyId': testProperty3Id,
        'paymentCycle': 'Rent - ${DateFormat.MMM().format(now.subtract(const Duration(days: 30)))} ${now.year}',
        'amountDue': 1500.0, 'dueDate': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        'amountPaid': 1500.0, 'paymentDate': Timestamp.fromDate(now.subtract(const Duration(days: 20))), // Late
        'isFullPayment': true, 'paymentStatusNotes': 'Paid late', 'paymentMethod': 'Mpesa',
        'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
      },
    ];
  }

  static Future<void> seedLeasePaymentsToFirestore(FirebaseFirestore firestore) async {
    debugPrint("Attempting to seed 'lease_payments' data...");
    final data = getLeasePaymentSeedData();
    final batch = firestore.batch();

    for (var record in data) {
      final docRef = firestore.collection('lease_payments').doc(); // Auto-generate ID
      batch.set(docRef, record);
    }
    try {
      await batch.commit();
      debugPrint("${data.length} lease payment records seeded successfully to 'lease_payments'.");
    } catch (e) {
      debugPrint("Error seeding 'lease_payments': $e");
    }
  }

  // --- NEW: SERVICE PROVIDER JOB SEED DATA ---
  static List<Map<String, dynamic>> getSPJobSeedData(String testSPId, String testClientId) {
    final now = DateTime.now();
    return [
      {
        'serviceProviderId': testSPId,
        'clientId': testClientId,
        'clientName': 'Alice Wonderland', // Example client name
        'propertyAddress': '101 Sky High Towers, Apt 15C',
        'serviceDescription': 'Emergency plumbing: Fixed burst pipe under kitchen sink.',
        'dateScheduled': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
        'dateCompleted': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'status': 'Completed', // "Paid" can also be a status if tracking payment to SP
        'amountEarned': 150.00,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      },
      {
        'serviceProviderId': testSPId,
        'clientId': testClientId, // Can use a different client ID for variety
        'clientName': 'Bob The Builder',
        'propertyAddress': '202 Ground Floor Estates',
        'serviceDescription': 'Scheduled electrical wiring inspection and minor repairs.',
        'dateScheduled': Timestamp.fromDate(now.add(const Duration(days: 3))), // Future date
        'dateCompleted': null, // Not yet completed
        'status': 'Scheduled',
        'amountEarned': 250.00, // Amount agreed upon
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      },
      {
        'serviceProviderId': testSPId,
        'clientId': 'client003', // Different client
        'clientName': 'Catherine Wheel',
        'propertyAddress': '303 Rolling Hills Villas',
        'serviceDescription': 'HVAC unit servicing and filter replacement.',
        'dateScheduled': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'dateCompleted': null, // In progress
        'status': 'InProgress',
        'amountEarned': 180.00,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'updatedAt': Timestamp.now(),
      },
      {
        'serviceProviderId': testSPId,
        'clientId': 'client004',
        'clientName': 'David Copperfield',
        'propertyAddress': '404 Magic Manor',
        'serviceDescription': 'Painting services for two bedrooms.',
        'dateScheduled': Timestamp.fromDate(now.subtract(const Duration(days: 8))),
        'dateCompleted': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
        'status': 'PendingPayment', // Job done, SP waiting for payment from client/platform
        'amountEarned': 320.00,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 8))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
      },
      {
        'serviceProviderId': testSPId,
        'clientId': 'client005',
        'clientName': 'Eva Green',
        'propertyAddress': '505 Evergreen Terrace',
        'serviceDescription': 'Gate lock replacement.',
        'dateScheduled': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'dateCompleted': null, // Not completed
        'status': 'Cancelled',
        'amountEarned': 0.00, // No earning for cancelled job
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      },
    ];
  }

  static Future<void> seedSPJobsToFirestore(FirebaseFirestore firestore, {required String spId, required String clientId}) async {
    debugPrint("Attempting to seed 'service_jobs' data for SP: $spId...");
    final data = getSPJobSeedData(spId, clientId);
    final batch = firestore.batch();

    for (var record in data) {
      final docRef = firestore.collection('service_jobs').doc(); // Auto-generate ID
      batch.set(docRef, record);
    }
    try {
      await batch.commit();
      debugPrint("${data.length} service job records seeded successfully for SP: $spId.");
    } catch (e) {
      debugPrint("Error seeding 'service_jobs': $e");
    }
  }
}
