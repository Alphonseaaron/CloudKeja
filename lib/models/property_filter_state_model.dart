import 'package:flutter/material.dart'; // For RangeValues

class PropertyFilterStateModel {
  final RangeValues? priceRange;
  final List<String> selectedPropertyTypes;
  final int? selectedBedrooms; // 0 for Any, 1 for 1, etc. 5 for 5+
  final int? selectedBathrooms; // 0 for Any, 1 for 1, etc. 3 for 3+
  final List<String> selectedAmenities;
  final String? selectedListingCategory; // e.g., "For Rent", "For Sale", or null for "Any"

  const PropertyFilterStateModel({
    this.priceRange,
    this.selectedPropertyTypes = const [],
    this.selectedBedrooms, // Null means 'Any' or default state
    this.selectedBathrooms, // Null means 'Any' or default state
    this.selectedAmenities = const [],
    this.selectedListingCategory, // Added
  });

  // Factory constructor for the initial default state
  factory PropertyFilterStateModel.initial() {
    return const PropertyFilterStateModel(
      priceRange: null, // Or a default wide range like RangeValues(0, 500000)
      selectedPropertyTypes: [],
      selectedBedrooms: null, // Representing "Any"
      selectedBathrooms: null, // Representing "Any"
      selectedAmenities: [],
      selectedListingCategory: null, // Added
    );
  }

  // copyWith method for updating state immutably
  PropertyFilterStateModel copyWith({
    RangeValues? priceRange,
    List<String>? selectedPropertyTypes,
    int? selectedBedrooms,
    int? selectedBathrooms,
    List<String>? selectedAmenities,
    String? selectedListingCategory, // Added
    bool clearPriceRange = false, // Special flag to explicitly set priceRange to null
    bool clearSelectedBedrooms = false,
    bool clearSelectedBathrooms = false,
    bool clearSelectedListingCategory = false, // Added
  }) {
    return PropertyFilterStateModel(
      priceRange: clearPriceRange ? null : priceRange ?? this.priceRange,
      selectedPropertyTypes: selectedPropertyTypes ?? this.selectedPropertyTypes,
      selectedBedrooms: clearSelectedBedrooms ? null : selectedBedrooms ?? this.selectedBedrooms,
      selectedBathrooms: clearSelectedBathrooms ? null : selectedBathrooms ?? this.selectedBathrooms,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      selectedListingCategory: clearSelectedListingCategory ? null : selectedListingCategory ?? this.selectedListingCategory, // Added
    );
  }

  // Getter to check if the current state is the default/initial state
  bool get isDefault {
    return priceRange == null &&
        selectedPropertyTypes.isEmpty &&
        (selectedBedrooms == null || selectedBedrooms == 0) && // Assuming 0 also means 'Any' if used in UI
        (selectedBathrooms == null || selectedBathrooms == 0) && // Assuming 0 also means 'Any' if used in UI
         selectedAmenities.isEmpty &&
         selectedListingCategory == null; // Added
  }

  // Method to return a new instance with initial/cleared values
  PropertyFilterStateModel clear() {
    return PropertyFilterStateModel.initial();
  }

  // Optional: For debugging or display
  @override
  String toString() {
    return 'PropertyFilterStateModel(\n'
           '  priceRange: $priceRange,\n'
           '  selectedPropertyTypes: $selectedPropertyTypes,\n'
           '  selectedBedrooms: $selectedBedrooms,\n'
           '  selectedBathrooms: $selectedBathrooms,\n'
            '  selectedAmenities: $selectedAmenities,\n'
            '  selectedListingCategory: $selectedListingCategory\n' // Added
           ')';
  }

  // Optional: For equality comparison if needed
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyFilterStateModel &&
        other.priceRange == priceRange &&
        listEquals(other.selectedPropertyTypes, selectedPropertyTypes) &&
        other.selectedBedrooms == selectedBedrooms &&
        other.selectedBathrooms == selectedBathrooms &&
         listEquals(other.selectedAmenities, selectedAmenities) &&
         other.selectedListingCategory == selectedListingCategory; // Added
  }

  @override
  int get hashCode {
    return priceRange.hashCode ^
           Object.hashAll(selectedPropertyTypes) ^
           selectedBedrooms.hashCode ^
           selectedBathrooms.hashCode ^
           Object.hashAll(selectedAmenities) ^
           selectedListingCategory.hashCode; // Added
  }

  // Helper for list equality check
  static bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
