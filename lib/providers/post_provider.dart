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
import 'package:cloudkeja/providers/auth_provider.dart'; // For usersRef

// Define a constant for max price if using < for price range filter end
const double kMaxPriceForFilter = 10000000.0; // Example: 10 Million KES

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<SpaceModel> _spaces = [];

  List<SpaceModel> get spaces {
    return [..._spaces];
  }

  Future<void> addSpace(SpaceModel space) async {
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

    await docRef.set(spaceData);
    _spaces.insert(0, space);
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
}
