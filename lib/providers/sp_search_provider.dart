import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudkeja/models/user_model.dart'; // Ensure this path is correct

class ServiceProviderSearchProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> searchServiceProviders({
    String? searchText,
    String? selectedSPType, // This is a single type from the dropdown
    String? locationText,   // This is the text from the location input field
  }) async {
    debugPrint('Searching SPs: searchText="$searchText", type="$selectedSPType", location="$locationText"');

    Query query = _firestore
        .collection('users')
        .where('role', isEqualTo: 'ServiceProvider')
        .where('isVerified', isEqualTo: true);

    // Apply Service Provider Type Filter (Firestore)
    if (selectedSPType != null && selectedSPType.isNotEmpty && selectedSPType.toLowerCase() != 'any service type') {
      query = query.where('serviceProviderTypes', arrayContains: selectedSPType);
    }

    // Apply Location Filter (Firestore - exact match on spCounty for V1)
    // Consider making location search case-insensitive by storing a lowercase version of spCounty
    // or by performing client-side filtering if more flexible matching is needed.
    if (locationText != null && locationText.trim().isNotEmpty) {
      // For more flexible search (e.g., partial, multiple location fields), client-side filtering or
      // a dedicated searchKeywords field for locations would be better.
      // This is an exact match on spCounty.
      query = query.where('spCounty', isEqualTo: locationText.trim());
    }

    // Apply Search Text Filter (Firestore - using 'searchKeywords' array)
    // It's assumed 'searchKeywords' on UserModel contains lowercase parts of name, servicesOffered text, etc.
    bool performClientSideTextSearch = false;
    if (searchText != null && searchText.trim().isNotEmpty) {
      // If 'searchKeywords' field is available and indexed, use it.
      // query = query.where('searchKeywords', arrayContains: searchText.trim().toLowerCase());

      // Fallback/Alternative: If 'searchKeywords' is not reliably populated or for broader matching,
      // we might need to do more client-side. For now, let's assume we try a basic name match
      // if 'searchKeywords' isn't the primary strategy or doesn't exist.
      // This example will use a client-side filter for searchText as 'searchKeywords' might not be populated.
      // If 'searchKeywords' IS populated and indexed, the Firestore query above is preferred.
      // To demonstrate client-side, we'll fetch based on type/location and then filter.
      // If relying purely on Firestore for text search via 'searchKeywords', set performClientSideTextSearch = false.
      performClientSideTextSearch = true; // Set to true to enable client-side text filtering below
      debugPrint("Note: `searchText` will be applied client-side in this version.");
    }

    // Add default ordering if needed, e.g., by name or verification status
    // query = query.orderBy('name'); // Example

    try {
      final snapshot = await query.get();
      List<UserModel> results = snapshot.docs
          .map((doc) => UserModel.fromJson(doc)) // UserModel.fromJson handles DocumentSnapshot
          .toList();

      debugPrint('Firestore query returned ${results.length} SPs before client-side text filter.');

      // Client-Side Filtering for searchText (if performClientSideTextSearch is true)
      if (performClientSideTextSearch && searchText != null && searchText.trim().isNotEmpty) {
        String searchTermLower = searchText.trim().toLowerCase();
        results = results.where((sp) {
          bool nameMatch = sp.name?.toLowerCase().contains(searchTermLower) ?? false;
          bool servicesMatch = sp.servicesOffered?.any((service) => service.toLowerCase().contains(searchTermLower)) ?? false;
          // Also check against selectedSPType if it matches the search text, though primary filtering is by dropdown
          bool typeMatchInText = sp.serviceProviderTypes?.any((type) => type.toLowerCase().contains(searchTermLower)) ?? false;

          return nameMatch || servicesMatch || typeMatchInText;
        }).toList();
        debugPrint('Results after client-side text filter: ${results.length}');
      }

      // TODO: Consider adding client-side filtering for location if the Firestore 'spCounty' exact match is too restrictive
      // and a 'searchableLocations' array isn't used.
      // Example for client-side location filtering (if locationText was not used in Firestore query):
      /*
      if (locationText != null && locationText.trim().isNotEmpty) {
        String locationTermLower = locationText.trim().toLowerCase();
        results = results.where((sp) {
          bool countryMatch = sp.spCountry?.toLowerCase().contains(locationTermLower) ?? false;
          bool countyMatch = sp.spCounty?.toLowerCase().contains(locationTermLower) ?? false;
          bool subCountyMatch = sp.spSubCounty?.toLowerCase().contains(locationTermLower) ?? false;
          bool serviceAreasMatch = sp.serviceAreas?.any((area) => area.toLowerCase().contains(locationTermLower)) ?? false;
          return countryMatch || countyMatch || subCountyMatch || serviceAreasMatch;
        }).toList();
        debugPrint('Results after client-side location filter: ${results.length}');
      }
      */

      debugPrint('Final SP search results: ${results.length}');
      // notifyListeners(); // Not needed if this method is called and result used directly
      return results;

    } catch (e) {
      debugPrint('Error searching service providers: $e');
      throw Exception('Failed to search service providers: ${e.toString()}');
    }
  }
}
