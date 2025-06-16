import 'dart:convert'; // Not actively used, but often present
import 'dart:io'; // For File type in SpaceModel

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloudkeja/models/review_model.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/models/property_filter_state_model.dart'; // Import for filters
// import 'package:cloudkeja/providers/auth_provider.dart'; // usersRef not directly used here for user updates, _firestore.collection('users') is used.
import 'package:cloudkeja/providers/subscription_provider.dart'; // Added import

// Define a constant for max price if using < for price range filter end
const double kMaxPriceForFilter = 10000000.0; // Example: 10 Million KES

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<SpaceModel> _spaces = [];

  List<SpaceModel> get spaces {
    return [..._spaces];
  }

  // Helper to get user model - can be moved to a user service/provider if used frequently
  Future<UserModel?> _getUserModel(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return UserModel.fromJson(userDoc);
    }
    return null;
  }

  Future<void> addSpace(SpaceModel space) async {
    if (space.ownerId == null) {
      throw Exception("Owner ID is required to add a space.");
    }

    // --- Subscription Check ---
    final subscriptionProvider = SubscriptionProvider(); // Instantiate directly
    final userModel = await _getUserModel(space.ownerId!);

    if (userModel == null) {
      throw Exception("Owner (user) not found. Cannot verify subscription.");
    }

    if (!subscriptionProvider.canAddProperty(userModel)) {
      throw Exception(
          "You have reached the maximum number of properties for your current subscription plan. Please upgrade to add more.");
    }
    // --- End Subscription Check ---

    final spaceCollection = _firestore.collection('spaces');
    final docRef = spaceCollection.doc();
    space.id = docRef.id;

    List<String> urls = [];
    if (space.imageFiles != null && space.imageFiles!.isNotEmpty) {
      for (int i = 0; i < space.imageFiles!.length; i++) {
        final upload = await _storage
            .ref('spaces/${space.id}/image_$i')
            .putFile(space.imageFiles![i]);
        urls.add(await upload.ref.getDownloadURL());
      }
      space.images = urls;
    }

    Map<String, dynamic> spaceData = space.toJson();
    // Add lowercase name for searching if not already handled by a keywords array
    if (space.spaceName != null) {
      spaceData['spaceName_lowercase'] = space.spaceName!.toLowerCase();
    }
    // Consider adding other searchable fields to a 'searchKeywords' array in spaceData

    // Note: space.units are saved here if present in spaceData (from space.toJson()).
    // Unit management (populating space.units) is typically handled elsewhere,
    // e.g., on the property details screen after initial creation.
    await docRef.set(spaceData);

    // --- Increment Property Count ---
    try {
      final currentPropertyCount = userModel.propertyCount ?? 0;
      await _firestore.collection('users').doc(space.ownerId!).update({
        'propertyCount': currentPropertyCount + 1,
      });
    } catch (e) {
      // Log this error, but don't let it fail the space creation.
      // Or, decide on a rollback strategy if property count update is critical.
      print("Error updating property count for user ${space.ownerId}: $e");
      // Potentially rethrow if this is a critical failure, or handle gracefully.
    }
    // --- End Increment Property Count ---

    _spaces.insert(0, space); // Add to local cache
    notifyListeners();
  }

  Future<void> editSpace(SpaceModel space) async {
    if (space.id == null) throw Exception("Space ID cannot be null for editing.");
    final docRef = _firestore.collection('spaces').doc(space.id);

    List<String> urls = [];
    if (space.imageFiles != null && space.imageFiles!.isNotEmpty) {
      for (int i = 0; i < space.imageFiles!.length; i++) {
        final upload = await _storage
            .ref('spaces/${space.id}/image_$i')
            .putFile(space.imageFiles![i]);
        urls.add(await upload.ref.getDownloadURL());
      }
       space.images = urls;
    }

    Map<String, dynamic> spaceData = space.toJson();
    if (space.spaceName != null) {
      spaceData['spaceName_lowercase'] = space.spaceName!.toLowerCase();
    }

    // Note: space.units are saved here if present in spaceData (from space.toJson()).
    // Unit management (populating/modifying space.units) is typically handled elsewhere,
    // e.g., on the property details screen.
    await docRef.update(spaceData);
    int index = _spaces.indexWhere((s) => s.id == space.id);
    if (index != -1) {
      _spaces[index] = space;
    }
    notifyListeners();
  }

  Future<List<SpaceModel>> getSpaces({bool forceRefresh = false}) async {
    if (!forceRefresh && _spaces.isNotEmpty) {
      return _spaces;
    }
    final results = await _firestore.collection('spaces').where('isAvailable', isEqualTo: true).orderBy('spaceName').get();
    _spaces = results.docs.map((e) => SpaceModel.fromJson(e)).toList();
    notifyListeners();
    return _spaces;
  }

  Future<List<SpaceModel>> fetchLandlordSpaces(String uid) async {
    final results = await _firestore.collection('spaces').where('ownerId', isEqualTo: uid).get();
    return results.docs.map((e) => SpaceModel.fromJson(e)).toList();
  }

  Future<UserModel> fetchLandLordDetails(String id) async {
    final userDoc = await _firestore.collection('users').doc(id).get();
    return UserModel.fromJson(userDoc);
  }

  Future<List<SpaceModel>> searchSpaces(
    String? searchText, {
    PropertyFilterStateModel? filters,
  }) async {
    Query query = _firestore.collection('spaces').where('isAvailable', isEqualTo: true);

    // Apply Firestore-side Keyword Search (if spaceName_lowercase field exists and is indexed)
    // This is a simple prefix search. For full-text search, a dedicated service or different data structure is better.
    if (searchText != null && searchText.trim().isNotEmpty) {
      String searchTermLower = searchText.trim().toLowerCase();
      query = query
        .where('spaceName_lowercase', isGreaterThanOrEqualTo: searchTermLower)
        .where('spaceName_lowercase', isLessThanOrEqualTo: '$searchTermLower\uf8ff');
    }

    // Apply Firestore-side Filters
    if (filters != null) {
      if (filters.priceRange != null) {
        if (filters.priceRange!.start > 0) {
          query = query.where('price', isGreaterThanOrEqualTo: filters.priceRange!.start);
        }
        if (filters.priceRange!.end < kMaxPriceForFilter) {
          query = query.where('price', isLessThanOrEqualTo: filters.priceRange!.end);
        }
      }

      if (filters.selectedPropertyTypes.isNotEmpty) {
        if (filters.selectedPropertyTypes.length <= 30) {
           query = query.where('propertyType', whereIn: filters.selectedPropertyTypes);
        } else {
          debugPrint("Warning: Property types filter exceeds 30 items. Querying first 30 only.");
          query = query.where('propertyType', whereIn: filters.selectedPropertyTypes.take(30).toList());
        }
      }

      if (filters.selectedBedrooms != null && filters.selectedBedrooms! > 0) {
        if (filters.selectedBedrooms == 5) {
          query = query.where('numBedrooms', isGreaterThanOrEqualTo: 5);
        } else {
          query = query.where('numBedrooms', isEqualTo: filters.selectedBedrooms);
        }
      }

      if (filters.selectedBathrooms != null && filters.selectedBathrooms! > 0) {
        if (filters.selectedBathrooms == 3) {
          query = query.where('numBathrooms', isGreaterThanOrEqualTo: 3);
        } else {
          query = query.where('numBathrooms', isEqualTo: filters.selectedBathrooms);
        }
      }

      // Add new filter for Listing Category (For Rent / For Sale)
      // Assumes 'category' field in Firestore stores this distinction.
      // Assumes filters.selectedListingCategory will be null if "Any" is selected.
      if (filters.selectedListingCategory != null) {
        query = query.where('category', isEqualTo: filters.selectedListingCategory);
      }
    }

    // Default sort order - can be made more sophisticated or user-selectable
    // query = query.orderBy('price'); // Example: order by price if no other order is dominant

    final snapshot = await query.get();
    debugPrint("Firestore query executed. Number of results before client-side filtering: ${snapshot.docs.length}");
    List<SpaceModel> results = snapshot.docs.map((doc) => SpaceModel.fromJson(doc)).toList();

    // --- Client-Side Filtering ---

    // 1. Amenities Filter (All selected amenities must be present)
    if (filters != null && filters.selectedAmenities.isNotEmpty) {
      results = results.where((space) {
        if (space.amenities == null || space.amenities!.isEmpty) return false;
        return filters.selectedAmenities.every((amenity) => space.amenities!.contains(amenity));
      }).toList();
      debugPrint("Results after Amenity filter: ${results.length}");
    }

    // 2. Client-side Search Text Filter (if Firestore search was not comprehensive enough or not used)
    // This acts as a fallback or refinement if `spaceName_lowercase` prefix search isn't sufficient,
    // or if you want to search other fields like description, address client-side.
    // For this task, the Firestore prefix search on 'spaceName_lowercase' is the primary text search.
    // If you had a `searchKeywords` array field in Firestore, `array-contains` would be better.
    // This client-side part is more for if the Firestore query for text is limited.

    // Example of broader client-side text filtering if needed (currently commented out as Firestore handles primary text search)
    /*
    if (searchText != null && searchText.trim().isNotEmpty) {
      String searchTermLower = searchText.trim().toLowerCase();
      results = results.where((space) {
        bool nameMatch = space.spaceName?.toLowerCase().contains(searchTermLower) ?? false;
        bool addressMatch = space.address?.toLowerCase().contains(searchTermLower) ?? false;
        bool categoryMatch = space.category?.toLowerCase().contains(searchTermLower) ?? false;
        bool propertyTypeMatch = space.propertyType?.toLowerCase().contains(searchTermLower) ?? false;
        // bool descriptionMatch = space.description?.toLowerCase().contains(searchTermLower) ?? false;
        // return nameMatch || addressMatch || categoryMatch || propertyTypeMatch || descriptionMatch;
        return nameMatch || addressMatch || propertyTypeMatch; // Simplified example
      }).toList();
      debugPrint("Results after client-side text filter: ${results.length}");
    }
    */

    debugPrint("Final search results count: ${results.length}");
    return results;
  }

  Future<void> sendRating(ReviewModel review) async {
    await _firestore
        .collection('spaces/${review.spaceId!}/reviews')
        .doc()
        .set(review.toJson());
  }

  Future<void> deleteSpace(String id) async {
    await _firestore.collection('spaces').doc(id).delete();
    _spaces.removeWhere((space) => space.id == id);
    notifyListeners();
  }

  Future<void> addUnitToSpace(String spaceId, Map<String, dynamic> newUnitData) async {
    if (newUnitData['unitId'] == null) {
      throw ArgumentError("New unit data must include a unique 'unitId'.");
    }
    final docRef = _firestore.collection('spaces').doc(spaceId);
    await docRef.update({
      'units': FieldValue.arrayUnion([newUnitData])
    });

    // Optional: Update local cache if necessary
    int index = _spaces.indexWhere((s) => s.id == spaceId);
    if (index != -1) {
      // Create a new list of units for the updated space
      List<Map<String, dynamic>> updatedUnits =
          List<Map<String, dynamic>>.from(_spaces[index].units ?? []);
      updatedUnits.add(newUnitData);
      _spaces[index] = _spaces[index].copyWith(units: updatedUnits);
      notifyListeners();
    }
  }

  Future<void> updateUnitInSpace(String spaceId, String unitIdToUpdate, Map<String, dynamic> updatedUnitData) async {
    if (updatedUnitData['unitId'] == null || updatedUnitData['unitId'] != unitIdToUpdate) {
      throw ArgumentError("Updated unit data must include a matching 'unitId'.");
    }
    final docRef = _firestore.collection('spaces').doc(spaceId);

    // Read-modify-write
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Space document not found!");
      }

      List<Map<String, dynamic>> units = List<Map<String, dynamic>>.from(
          (snapshot.data() as Map<String, dynamic>)['units'] ?? []);

      int unitIndex = units.indexWhere((u) => u['unitId'] == unitIdToUpdate);

      if (unitIndex != -1) {
        units[unitIndex] = updatedUnitData; // Replace the old unit with the new data
        transaction.update(docRef, {'units': units});

        // Optional: Update local cache
        int spaceIndexInCache = _spaces.indexWhere((s) => s.id == spaceId);
        if (spaceIndexInCache != -1) {
          _spaces[spaceIndexInCache] = _spaces[spaceIndexInCache].copyWith(units: List<Map<String,dynamic>>.from(units));
          notifyListeners();
        }
      } else {
        // Handle case where unit to update is not found, though this shouldn't happen if UI is correct
        debugPrint("Unit with ID $unitIdToUpdate not found in space $spaceId for update.");
      }
    });
  }

  Future<void> deleteUnitFromSpace(String spaceId, String unitIdToDelete) async {
    final docRef = _firestore.collection('spaces').doc(spaceId);

    // Read-modify-write for robust deletion based on ID
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Space document not found!");
      }

      List<Map<String, dynamic>> units = List<Map<String, dynamic>>.from(
          (snapshot.data() as Map<String, dynamic>)['units'] ?? []);

      List<Map<String, dynamic>> updatedUnits = units.where((u) => u['unitId'] != unitIdToDelete).toList();

      if (units.length != updatedUnits.length) { // Check if a unit was actually removed
          transaction.update(docRef, {'units': updatedUnits});

          // Optional: Update local cache
          int spaceIndexInCache = _spaces.indexWhere((s) => s.id == spaceId);
          if (spaceIndexInCache != -1) {
              _spaces[spaceIndexInCache] = _spaces[spaceIndexInCache].copyWith(units: updatedUnits);
              notifyListeners();
          }
      } else {
          debugPrint("Unit with ID $unitIdToDelete not found in space $spaceId for deletion.");
      }
    });
  }
}
