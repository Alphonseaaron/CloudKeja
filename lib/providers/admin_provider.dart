import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased for clarity
import 'package:cloudkeja/models/user_model.dart';
// import 'package:cloudkeja/providers/auth_provider.dart'; // usersRef was from here, now using direct path

// It's better practice to define collection references within the provider or pass Firestore instance.
// For simplicity, directly using FirebaseFirestore.instance.collection('users').
// final usersRef = FirebaseFirestore.instance.collection('users'); // This was likely global or from AuthProvider

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance; // If needed for admin actions

  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<List<UserModel>> getAllUsers() async {
    final results = await _usersCollection.orderBy('name').get(); // Added ordering
    // notifyListeners(); // Typically not needed for simple fetch methods unless state is stored in provider
    return results.docs.map((doc) => UserModel.fromJson(doc)).toList(); // Use UserModel.fromJson(doc)
  }

  Future<List<UserModel>> getAllLandlords() async {
    final results = await _usersCollection
        .where('isLandlord', isEqualTo: true)
        .orderBy('name') // Added ordering
        .get();
    // notifyListeners();
    return results.docs.map((doc) => UserModel.fromJson(doc)).toList();
  }

  Future<List<UserModel>> getAllServiceProviders() async {
    final results = await _usersCollection
        .where('role', isEqualTo: 'ServiceProvider')
        .orderBy('name') // Added ordering
        .get();
    return results.docs.map((doc) => UserModel.fromJson(doc)).toList();
  }


  // Refactored deleteUser
  Future<void> deleteUserAccount(String targetUserId) async { // Renamed for clarity (account vs just doc)
    // This only deletes the Firestore document, not the Firebase Auth user.
    // Full user deletion requires Firebase Functions or Admin SDK on backend.
    try {
      await _usersCollection.doc(targetUserId).delete();
      debugPrint('User document deleted for $targetUserId');
      notifyListeners(); // If UI needs to refresh list after deletion
    } catch (error) {
      debugPrint('Error deleting user document $targetUserId: $error');
      throw error; // Rethrow to be caught by UI
    }
  }

  // Refactored makeAdmin
  Future<void> setUserAdminStatus(String targetUserId, bool newAdminStatus) async {
    try {
      await _usersCollection.doc(targetUserId).update({
        'isAdmin': newAdminStatus,
        // Optional: 'role': newAdminStatus ? 'Admin' : 'User', // Or handle role separately
        'updatedAt': Timestamp.now(), // Good practice to track updates
      });
      debugPrint('Admin status for $targetUserId set to $newAdminStatus');
      notifyListeners();
    } catch (error) {
      debugPrint('Error setting admin status for $targetUserId: $error');
      throw error;
    }
  }

  // Refactored makeLandlord
  Future<void> setUserLandlordStatus(String targetUserId, bool newLandlordStatus) async {
    try {
      await _usersCollection.doc(targetUserId).update({
        'isLandlord': newLandlordStatus,
        // If setting isLandlord to true, and role is not already Landlord or Admin,
        // you might want to update 'role' as well.
        // 'role': newLandlordStatus && (await _usersCollection.doc(targetUserId).get()).data()?['role'] != 'Admin'
        //          ? 'Landlord'
        //          : (await _usersCollection.doc(targetUserId).get()).data()?['role'], // Keep existing role or logic
        'updatedAt': Timestamp.now(),
      });
      debugPrint('Landlord status for $targetUserId set to $newLandlordStatus');
      notifyListeners();
    } catch (error) {
      debugPrint('Error setting landlord status for $targetUserId: $error');
      throw error;
    }
  }

  // New method for Service Provider Verification
  Future<void> setServiceProviderVerificationStatus(String targetUserId, bool newStatus) async {
    try {
      final Map<String, dynamic> updateData = {
        'isVerified': newStatus,
        'verificationStatusLastUpdated': Timestamp.now(),
      };
      // Optional: Add admin ID who performed the action
      // if (_auth.currentUser != null) {
      //   updateData['verifiedByAdminId'] = _auth.currentUser!.uid;
      // }

      // Also ensure the role is 'ServiceProvider' if verifying, or handle this appropriately
      // final userDoc = await _usersCollection.doc(targetUserId).get();
      // if (userDoc.exists && userDoc.data()?['role'] != 'ServiceProvider' && newStatus == true) {
      //   // This could be an error or an implicit role change, depending on business logic
      //   debugPrint("Warning: Verifying a user who is not currently a ServiceProvider. Role might need update.");
      //   // updateData['role'] = 'ServiceProvider'; // Example: Implicit role update
      // }


      await _usersCollection.doc(targetUserId).update(updateData);
      debugPrint('Service Provider verification status for $targetUserId set to $newStatus');
      notifyListeners(); // If admin UI needs to reflect this change immediately
    } catch (error) {
      debugPrint('Error updating SP verification status for $targetUserId: $error');
      throw error; // Rethrow to be caught by UI and show appropriate message
    }
  }

  // --- Subscription Management by Admin ---

  Future<void> updateUserSubscriptionTier(String targetUserId, String newTierId, Timestamp? expiryDate) async {
    try {
      await _usersCollection.doc(targetUserId).update({
        'subscriptionTier': newTierId,
        'subscriptionExpiryDate': expiryDate,
        'updatedAt': Timestamp.now(), // Track when this change was made
      });
      debugPrint('Subscription tier for $targetUserId updated to $newTierId with expiry $expiryDate');
      // notifyListeners(); // If admin UI has a live view of user details that needs refresh
    } catch (error) {
      debugPrint('Error updating subscription tier for $targetUserId: $error');
      throw error;
    }
  }

  // --- Admin User Count Management for Landlord by Admin ---

  Future<void> updateLandlordAdminUserCount(String landlordUserId, int newAdminUserCount) async {
    if (newAdminUserCount < 1) {
      throw ArgumentError("Admin user count cannot be less than 1.");
    }
    try {
      // Optional: Verify the user is indeed a landlord if necessary
      // final userDoc = await _usersCollection.doc(landlordUserId).get();
      // if (!userDoc.exists || !(userDoc.data() as Map<String, dynamic>)['isLandlord']) {
      //   throw Exception("Target user is not a landlord.");
      // }

      await _usersCollection.doc(landlordUserId).update({
        'adminUserCount': newAdminUserCount,
        'updatedAt': Timestamp.now(), // Track when this change was made
      });
      debugPrint('Admin user count for landlord $landlordUserId updated to $newAdminUserCount');
      // notifyListeners(); // If admin UI has a live view of user details
    } catch (error) {
      debugPrint('Error updating admin user count for landlord $landlordUserId: $error');
      throw error;
    }
  }
}
