import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Aliased to avoid conflict
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart'; // Assuming UserModel is in models folder
import 'package:cloudkeja/models/lease_model.dart'; // Import LeaseModel
import 'package:cloudkeja/providers/post_provider.dart'; // For spaceRef, consider direct path

class TenancyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  // Existing method - ensure spaceRef is correctly defined or use direct path
  // For now, assuming spaceRef is accessible as per original code structure.
  // If spaceRef is from PostProvider, it's better to pass Firestore instance or use direct paths.
  Future<List<SpaceModel>> getUserTenancy(UserModel user, {bool forceRefresh = false}) async {
    // TODO: Implement caching or use forceRefresh if this data is fetched frequently
    List<SpaceModel> spaces = [];
    if (user.rentedPlaces == null || user.rentedPlaces!.isEmpty) {
      return spaces;
    }

    for (var element in user.rentedPlaces!) {
      try {
        final spaceResult = await _firestore.collection('spaces').doc(element).get(); // Direct path
        if (spaceResult.exists) {
          final space = SpaceModel.fromJson(spaceResult.data()); // Assuming fromJson handles Map<String, dynamic>?
          spaces.add(space);
        }
      } catch (e) {
        debugPrint("Error fetching space details for ID $element: $e");
      }
    }
    return spaces;
  }

  // New method to fetch active lease for the current user
  Future<LeaseModel?> fetchActiveLeaseForCurrentUser({bool forceRefresh = false}) async {
    final currentUserUid = _auth.currentUser?.uid;
    if (currentUserUid == null) {
      debugPrint('TenancyProvider: User not logged in.');
      return null; // Or throw Exception('User not logged in');
    }

    // TODO: Implement caching logic if forceRefresh is false and data is cached.

    try {
      debugPrint('TenancyProvider: Fetching active lease for user $currentUserUid.');
      final querySnapshot = await _firestore
          .collection('tenancies') // Assumed collection name for leases
          .where('tenantId', isEqualTo: currentUserUid)
          // Option 1: Using an 'isActive' flag (requires backend to manage this flag)
          .where('isActive', isEqualTo: true) 
          // Option 2: Filtering by date (more robust if 'isActive' isn't perfectly managed)
          // .where('leaseEndDate', isGreaterThanOrEqualTo: Timestamp.now()) 
          .orderBy('leaseStartDate', descending: true) // Get the most recent lease if multiple somehow active
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final leaseDoc = querySnapshot.docs.first;
        debugPrint('TenancyProvider: Active lease found: ${leaseDoc.id}');
        return LeaseModel.fromSnapshot(leaseDoc);
      } else {
        debugPrint('TenancyProvider: No active lease found for user $currentUserUid.');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching active lease: $e');
      throw Exception('Could not fetch active lease: $e');
    }
  }
}
