import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For GeoPoint
import 'package:cloudkeja/models/space_model.dart';

void main() {
  group('SpaceModel Tests', () {
    // Dummy GeoPoint for tests that require it
    const GeoPoint testGeoPoint = GeoPoint(0, 0);

    group('toJson() with units', () {
      test('should include units when units list is not empty', () {
        // Arrange
        final unitsList = [{'unitId': 'u1', 'floor': 1, 'unitNumber': 'A101', 'status': 'vacant'}];
        final space = SpaceModel(
          id: 's1',
          spaceName: 'Test Space with Units',
          ownerId: 'owner1',
          category: 'For Rent',
          location: testGeoPoint,
          units: unitsList,
        );

        // Act
        final json = space.toJson();

        // Assert
        expect(json['units'], isNotNull);
        expect(json['units'], isA<List>());
        expect(json['units'], equals(unitsList));
      });

      test('should include empty list when units list is empty', () {
        // Arrange
        final space = SpaceModel(
          id: 's2',
          spaceName: 'Test Space with Empty Units',
          ownerId: 'owner2',
          category: 'For Sale',
          location: testGeoPoint,
          units: [], // Empty list
        );

        // Act
        final json = space.toJson();

        // Assert
        expect(json['units'], isNotNull);
        expect(json['units'], isA<List>());
        expect(json['units'], isEmpty);
      });

      test('should include empty list when units is null (due to constructor default)', () {
        // Arrange
        final space = SpaceModel(
          id: 's3',
          spaceName: 'Test Space with Null Units',
          ownerId: 'owner3',
          category: 'For Rent',
          location: testGeoPoint,
          units: null, // Null, should default to empty list in constructor
        );

        // Act
        final json = space.toJson();

        // Assert
        // The toJson method might convert null units to null or an empty list
        // based on `units?.map((u) => u).toList()`. If units is null, it results in null.
        // If the constructor defaults `units = units ?? const []`, then `toJson` would see an empty list.
        // Current SpaceModel constructor: `units = units ?? const []`
        // Current toJson: `'units': units?.map((u) => u).toList()`
        // So, if units is initialised to `const []` by constructor, then `units?.map` will produce `[]`.
        expect(json['units'], isNotNull);
        expect(json['units'], isA<List>());
        expect(json['units'], isEmpty);
      });
    });

    group('fromJson() with units', () {
      test('should populate units when units list is present in JSON', () {
        // Arrange
        final unitsList = [{'unitId': 'u1', 'floor': 1, 'unitNumber': 'A101', 'status': 'vacant'}];
        final jsonData = {
          'id': 's1',
          'spaceName': 'Test Space from JSON',
          'ownerId': 'owner1',
          'category': 'For Rent',
          'location': testGeoPoint,
          'units': unitsList,
          // Add other required fields for fromJson if any, e.g., isAvailable
          'isAvailable': true,
          'likes': 0,
        };

        // Act
        final space = SpaceModel.fromJson(jsonData);

        // Assert
        expect(space.units, isNotNull);
        expect(space.units, isA<List<Map<String, dynamic>>>());
        expect(space.units, equals(unitsList));
      });

      test('should populate units as empty list when units list is empty in JSON', () {
        // Arrange
        final jsonData = {
          'id': 's2',
          'spaceName': 'Test Space from JSON with Empty Units',
          'ownerId': 'owner2',
          'category': 'For Sale',
          'location': testGeoPoint,
          'units': [], // Empty list in JSON
          'isAvailable': true,
          'likes': 0,
        };

        // Act
        final space = SpaceModel.fromJson(jsonData);

        // Assert
        expect(space.units, isNotNull);
        expect(space.units, isA<List<Map<String, dynamic>>>());
        expect(space.units, isEmpty);
      });

      test('should populate units as empty list when units field is null or missing in JSON', () {
        // Arrange
        final jsonDataMissingUnits = {
          'id': 's3',
          'spaceName': 'Test Space from JSON Missing Units',
          'ownerId': 'owner3',
          'category': 'For Rent',
          'location': testGeoPoint,
          // units field is missing
          'isAvailable': true,
          'likes': 0,
        };
         final jsonDataNullUnits = {
          'id': 's4',
          'spaceName': 'Test Space from JSON Null Units',
          'ownerId': 'owner4',
          'category': 'For Rent',
          'location': testGeoPoint,
          'units': null, // units field is null
          'isAvailable': true,
          'likes': 0,
        };

        // Act
        final spaceMissing = SpaceModel.fromJson(jsonDataMissingUnits);
        final spaceNull = SpaceModel.fromJson(jsonDataNullUnits);

        // Assert
        // Current fromJson: `units: data['units'] != null ? List<Map<String, dynamic>>.from(data['units']) : const []`
        expect(spaceMissing.units, isNotNull);
        expect(spaceMissing.units, isA<List<Map<String, dynamic>>>());
        expect(spaceMissing.units, isEmpty);

        expect(spaceNull.units, isNotNull);
        expect(spaceNull.units, isA<List<Map<String, dynamic>>>());
        expect(spaceNull.units, isEmpty);
      });
    });

    group('copyWith() with units', () {
      final initialUnits = [{'unitId': 'u1', 'floor': 1}];
      final space = SpaceModel(
        id: 's1',
        spaceName: 'Initial Space',
        ownerId: 'owner1',
        category: 'For Rent',
        location: testGeoPoint,
        units: initialUnits,
      );

      test('should update units when new units list is provided', () {
        // Arrange
        final newUnitsList = [{'unitId': 'u2', 'floor': 2, 'status': 'occupied'}];

        // Act
        final updatedSpace = space.copyWith(units: newUnitsList);

        // Assert
        expect(updatedSpace.units, isNotNull);
        expect(updatedSpace.units, equals(newUnitsList));
        expect(updatedSpace.id, equals(space.id)); // Ensure other fields are copied
        expect(updatedSpace.spaceName, equals(space.spaceName));
      });

      test('should keep original units when no units list is provided in copyWith', () {
        // Act
        final updatedSpace = space.copyWith(spaceName: 'Updated Name Only');

        // Assert
        expect(updatedSpace.units, isNotNull);
        expect(updatedSpace.units, equals(initialUnits));
        expect(updatedSpace.spaceName, equals('Updated Name Only'));
      });

       test('should update units to empty list when an empty list is provided', () {
        // Arrange
        final newUnitsList = <Map<String, dynamic>>[];

        // Act
        final updatedSpace = space.copyWith(units: newUnitsList);

        // Assert
        expect(updatedSpace.units, isNotNull);
        expect(updatedSpace.units, isEmpty);
      });

      test('should update units to null then default to empty list if constructor default is applied post copyWith', () {
        // Note: copyWith passes the value directly. If `units: null` is passed to copyWith,
        // the new SpaceModel instance's constructor will handle `null` and default it to `const []`.
        // Arrange

        // Act
        final updatedSpace = space.copyWith(units: null);

        // Assert
        expect(updatedSpace.units, isNotNull);
        expect(updatedSpace.units, isEmpty); // Due to constructor `units = units ?? const []`
      });
    });
  });
}
