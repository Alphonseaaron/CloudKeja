import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Added for DateTimeRange
import 'package:cloudkeja/models/invoice_models.dart';
import 'package:cloudkeja/models/notification_model.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/models/payment_model.dart'; // Import PaymentModel
import 'package:cloudkeja/providers/auth_provider.dart'; // For usersRef (if still used, though direct path is better)
import 'package:cloudkeja/providers/post_provider.dart'; // For spaceRef (if still used)
import 'package:cloudkeja/providers/tenant_model.dart';

class PaymentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //RENT SPACE
  Future<void> rentSpace(String userId, SpaceModel space) async { // Changed user to userId for clarity
    // Ensure usersRef is defined or use direct path
    final usersRef = _firestore.collection('users'); 

    await usersRef.doc(userId).update({
      'rentedPlaces': FieldValue.arrayUnion([space.id])
    });
    // final uid = _auth.currentUser!.uid; // Already have userId

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
      imageUrl: space.images?.first ?? '', // Handle null images
      createdAt: Timestamp.now(),
    );
    await _firestore
        .collection('userData') // Consider if 'users' collection is more appropriate for user-specific subcollections
        .doc(userId)
        .collection('notifications')
        .add(not.toJson());

    // Create a transaction record
    // This should align with PaymentModel structure
    await _firestore.collection('transactions').add({
      'userId': userId,
      'description': 'Rent for ${space.spaceName}',
      'amount': space.price,
      'currency': 'KES', // Assuming KES
      'status': 'Successful', // Assuming rentSpace implies successful payment
      'date': Timestamp.now(),
      'propertyId': space.id,
      'paymentMethod': 'System', // Or more specific if known
      'transactionId': 'RENTAL-${DateTime.now().millisecondsSinceEpoch}', // Example transaction ID
      // Adding space details for easier PDF generation later, though PaymentModel doesn't require all of these
      'spaceName': space.spaceName, 
      'spaceAddress': space.address,
      // 'type': 'Rental', // Could be useful for categorizing transactions
    });
    notifyListeners();
  }

  Future<void> checkOut(String userId, SpaceModel space) async { // Changed user to userId
    final usersRef = _firestore.collection('users');
    // final uid = _auth.currentUser!.uid; // Already have userId

    await usersRef.doc(userId).update({
      'rentedPlaces': FieldValue.arrayRemove([space.id])
    });
    
    await _firestore
        .collection('landlords')
        .doc(space.ownerId!)
        .collection('tenants')
        .where('user', isEqualTo: userId)
        .where('space', isEqualTo: space.id) // Be more specific when deleting
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
    if (uid == null) return []; // Not logged in

    final usersRef = _firestore.collection('users'); // Define usersRef
    final spaceRef = _firestore.collection('spaces'); // Define spaceRef


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
        final user = UserModel.fromJson(userData.data()); // Assuming fromJson handles Map<String, dynamic>?
        final space = SpaceModel.fromJson(spaceData.data()); // Assuming fromJson handles Map<String, dynamic>?
        
        if (tenants.where((t) => t.user?.userId == user.userId && t.space?.id == space.id).isEmpty) {
          tenants.add(TenantModel(user: user, space: space));
        }
      }
    }
    // notifyListeners(); // Usually not needed for fetch methods unless updating a local cache in provider
    return tenants;
  }

//PAY RENT
  Future<void> payRent(String ownerId, double amount) async { // Renamed owner to ownerId
    await _firestore
        .collection('users')
        .doc(ownerId)
        .update({'balance': FieldValue.increment(amount)});
    // notifyListeners(); // May not be needed if balance isn't directly shown by this provider
  }

  Future<Invoice> getTransactions() async {
    // This method seems to be for an admin/landlord to get all transactions for PDF.
    // It might need adjustments based on how transactions are stored and who can access them.
    final results = await _firestore.collection('transactions').orderBy('date', descending: true).get();
    final currentUser = _auth.currentUser; // Get current user for supplier info

    final itemsForInvoice = results.docs.map((doc) {
      final data = doc.data();
      return InvoiceItem(
        description: data['spaceName'] as String? ?? data['description'] as String? ?? 'N/A', // Use spaceName if available
        quantity: 1, // Assuming quantity is always 1 for rent payments
        unitPrice: (data['amount'] as num?)?.toDouble() ?? 0.0,
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        name: data['spaceAddress'] as String? ?? '', // Or tenant name if available and relevant
        // vat: 0.0, // Assuming no VAT for now
      );
    }).toList();

    return Invoice(
      info: InvoiceInfo(
        date: DateTime.now(),
        description: 'All Transactions Report',
        dueDate: DateTime.now().add(const Duration(days: 30)), // Example due date
        number: 'TRANS-${DateFormat('yyyyMMdd').format(DateTime.now())}', // Example invoice number
      ),
      // Use current user's details as supplier if this is their report
      supplier: Supplier(
        name: currentUser?.displayName ?? currentUser?.email ?? 'CloudKeja Platform', 
        address: 'CloudKeja Inc, Nairobi, Kenya', // Placeholder address
        paymentInfo: currentUser?.email ?? 'N/A'
      ),
      // Customer might be generic for an "All Transactions" report, or specific if filtering for one customer
      customer: Customer(name: 'All Users/Tenants', address: ''), 
      items: itemsForInvoice,
    );
  }

  // New method for fetching user-specific payment history
  Future<List<PaymentModel>> fetchUserPaymentHistory({
    DateTimeRange? dateFilter,
    String? specificUserId, // Optional: for admins to fetch specific user's history
    bool forceRefresh = false, // Optional: to bypass any caching if implemented
  }) async {
    final targetUserId = specificUserId ?? _auth.currentUser?.uid;

    if (targetUserId == null) {
      // Not logged in, or no specific user ID provided when required
      return []; 
    }

    try {
      Query query = _firestore
          .collection('transactions') // Assuming 'transactions' is the correct collection
          .where('userId', isEqualTo: targetUserId)
          .orderBy('date', descending: true); // Field for payment date

      if (dateFilter != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: dateFilter.start)
            .where('date', isLessThanOrEqualTo: dateFilter.end);
      }

      final snapshot = await query.get();

      final payments = snapshot.docs
          .map((doc) => PaymentModel.fromSnapshot(doc)) // Use PaymentModel.fromSnapshot
          .toList();
      
      return payments;
    } catch (e) {
      debugPrint('Error fetching user payment history: $e');
      // Propagate the error or return an empty list / specific error state
      throw Exception('Could not fetch payment history: $e');
    }
  }
}
