import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart'; // For RangeValues if used in tests
import 'package:cloudkeja/models/property_filter_state_model.dart';

void main() {
  group('PropertyFilterStateModel Tests', () {
    group('Constructor and initial()', () {
      test('initial() should have null selectedListingCategory', () {
        // Act
        final model = PropertyFilterStateModel.initial();
        // Assert
        expect(model.selectedListingCategory, isNull);
      });

      test('Constructor should set selectedListingCategory', () {
        // Arrange
        const category = 'For Rent';
        // Act
        const model = PropertyFilterStateModel(selectedListingCategory: category);
        // Assert
        expect(model.selectedListingCategory, equals(category));
      });

      test('Constructor defaults selectedListingCategory to null if not provided', () {
        // Act
        const model = PropertyFilterStateModel();
        // Assert
        expect(model.selectedListingCategory, isNull);
      });
    });

    group('copyWith() for selectedListingCategory', () {
      const initialModel = PropertyFilterStateModel(selectedListingCategory: 'For Sale');

      test('should update selectedListingCategory when provided', () {
        // Arrange
        const newCategory = 'For Rent';
        // Act
        final updatedModel = initialModel.copyWith(selectedListingCategory: newCategory);
        // Assert
        expect(updatedModel.selectedListingCategory, equals(newCategory));
      });

      test('should clear selectedListingCategory when clearSelectedListingCategory is true', () {
        // Act
        final updatedModel = initialModel.copyWith(clearSelectedListingCategory: true);
        // Assert
        expect(updatedModel.selectedListingCategory, isNull);
      });

      test('clearSelectedListingCategory flag takes precedence over provided value', () {
        // Act
        final updatedModel = initialModel.copyWith(selectedListingCategory: 'For Rent', clearSelectedListingCategory: true);
        // Assert
        expect(updatedModel.selectedListingCategory, isNull);
      });

      test('should keep original selectedListingCategory if not provided and not cleared', () {
        // Act
        final updatedModel = initialModel.copyWith(priceRange: const RangeValues(0,100)); // changing other field
        // Assert
        expect(updatedModel.selectedListingCategory, equals(initialModel.selectedListingCategory));
      });

      test('should set selectedListingCategory from null', () {
        // Arrange
        const model = PropertyFilterStateModel.initial(); // selectedListingCategory is null
        const newCategory = 'For Sale';
        // Act
        final updatedModel = model.copyWith(selectedListingCategory: newCategory);
        // Assert
        expect(updatedModel.selectedListingCategory, equals(newCategory));
      });
    });

    group('isDefault getter', () {
      test('should be true when selectedListingCategory is null and other fields are default', () {
        // Act
        final model = PropertyFilterStateModel.initial();
        // Assert
        expect(model.isDefault, isTrue);
      });

      test('should be false when selectedListingCategory is set, even if other fields are default', () {
        // Arrange
        const model = PropertyFilterStateModel(selectedListingCategory: 'For Rent');
        // Assert
        expect(model.isDefault, isFalse);
      });

       test('should be true if only selectedBedrooms is 0 (which is considered default for that field too)', () {
        final model = PropertyFilterStateModel.initial().copyWith(selectedBedrooms: 0);
        expect(model.isDefault, isTrue);
      });

      test('should be false if selectedBedrooms is non-zero and non-null', () {
        final model = PropertyFilterStateModel.initial().copyWith(selectedBedrooms: 1);
        expect(model.isDefault, isFalse);
      });
    });

    group('operator== and hashCode', () {
      const model1Rent = PropertyFilterStateModel(selectedListingCategory: 'For Rent', selectedPropertyTypes: ['Apartment']);
      const model2Rent = PropertyFilterStateModel(selectedListingCategory: 'For Rent', selectedPropertyTypes: ['Apartment']);
      const modelForSale = PropertyFilterStateModel(selectedListingCategory: 'For Sale', selectedPropertyTypes: ['Apartment']);
      const modelRentHouse = PropertyFilterStateModel(selectedListingCategory: 'For Rent', selectedPropertyTypes: ['House']);
      const modelNullCategory = PropertyFilterStateModel(selectedPropertyTypes: ['Apartment']);


      test('Instances with same selectedListingCategory and other fields should be equal and have same hashCode', () {
        expect(model1Rent, equals(model2Rent));
        expect(model1Rent.hashCode, equals(model2Rent.hashCode));
      });

      test('Instances with different selectedListingCategory should not be equal', () {
        expect(model1Rent, isNot(equals(modelForSale)));
      });

      test('Instances with different other fields (even if selectedListingCategory is same) should not be equal', () {
        expect(model1Rent, isNot(equals(modelRentHouse)));
      });

      test('Instances with one null selectedListingCategory and one set should not be equal', () {
        expect(model1Rent, isNot(equals(modelNullCategory)));
        expect(modelNullCategory, isNot(equals(model1Rent)));
      });

      test('Two initial instances should be equal and have same hashCode', () {
        final initial1 = PropertyFilterStateModel.initial();
        final initial2 = PropertyFilterStateModel.initial();
        expect(initial1, equals(initial2));
        expect(initial1.hashCode, equals(initial2.hashCode));
      });
    });
  });
}
