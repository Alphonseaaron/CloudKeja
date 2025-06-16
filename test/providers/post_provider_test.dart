import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for FieldValue etc.
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/property_filter_state_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:flutter/material.dart'; // For ChangeNotifier notifyListeners verification

// Helper class to listen to ChangeNotifier notifications
class MockListener extends ChangeNotifier {
  int count = 0;
  void call() {
    count++;
  }
}

void main() {
  late MockFirebaseFirestore mockFirestoreInstance;
  late MockFirebaseStorage mockFirebaseStorageInstance;
  late PostProvider postProvider;
  late MockListener mockListener;

  setUp(() async {
    // It's crucial that PostProvider uses the mock instance.
    // cloud_firestore_mocks works by creating an instance that then becomes
    // the one used by `FirebaseFirestore.instance` if set up correctly in test environment.
    // For this test suite, we'll create a new mock instance for each test
    // to ensure a clean state.
    mockFirestoreInstance = MockFirebaseFirestore();
    mockFirebaseStorageInstance = MockFirebaseStorage(); // Though not directly used in these specific methods

    // This is the tricky part: PostProvider uses FirebaseFirestore.instance.
    // To make PostProvider use mockFirestoreInstance, the test setup usually handles this.
    // For this subtask, we assume that FirebaseFirestore.instance IS mockFirestoreInstance.
    // This can be achieved by setting FirebaseFirestore.instance = mockFirestoreInstance
    // if the testing framework allows, or via a more robust DI setup in the app.
    // As a fallback for this self-contained test, we'll clear the collections
    // on the global mock instance before each test, assuming it's the one PostProvider uses.

    // Clear data from previous tests if any (important for MockFirebaseFirestore)
    // This simulates a fresh Firestore instance for each test.
    // Get all collections
    final collections = await mockFirestoreInstance.getCollections();
    for (final collection in collections) {
      final documents = await collection.get();
      for (final doc in documents.docs) {
        await doc.reference.delete();
      }
    }


    postProvider = PostProvider(); // This will use FirebaseFirestore.instance
                                 // which we assume is our mockFirestoreInstance.
    mockListener = MockListener();
    postProvider.addListener(mockListener.call);
  });

  tearDown(() {
    postProvider.removeListener(mockListener.call);
  });

  group('PostProvider Tests', () {
    group('searchSpaces with selectedListingCategory', () {
      // Helper to add space data to the mock Firestore instance
      Future<void> addSpaceData(String id, String name, String category, double price, {List<Map<String,dynamic>>? units}) async {
        await mockFirestoreInstance.collection('spaces').doc(id).set({
          'id': id, // Storing id also as a field for easier model hydration if needed
          'spaceName': name,
          'category': category,
          'price': price,
          'isAvailable': true,
          'spaceName_lowercase': name.toLowerCase(),
          'ownerId': 'owner-$id',
          'location': const GeoPoint(0,0),
          'units': units ?? [],
          'likes': 0,
          // Add other fields required by SpaceModel.fromJson to avoid null errors
          'description': 'Description for $name',
          'address': 'Address for $name',
          'propertyType': 'Apartment', // Default or make it a param
          'numBedrooms': 2,
          'numBathrooms': 1,
          'amenities': ['WiFi'],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      }

      test('filters by "For Rent" category', () async {
        // Arrange
        await addSpaceData('s1', 'Rental Alpha', 'For Rent', 1000);
        await addSpaceData('s2', 'Sale Beta', 'For Sale', 20000);
        await addSpaceData('s3', 'Rental Gamma', 'For Rent', 1200);

        final filters = PropertyFilterStateModel(selectedListingCategory: 'For Rent');

        // Act
        List<SpaceModel> results = await postProvider.searchSpaces(null, filters: filters);

        // Assert
        expect(results.length, 2);
        expect(results.every((space) => space.category == 'For Rent'), isTrue);
        expect(results.map((s) => s.id).toList(), containsAll(['s1', 's3']));
      });

      test('filters by "For Sale" category', () async {
        // Arrange
        await addSpaceData('s1', 'Rental Alpha', 'For Rent', 1000);
        await addSpaceData('s2', 'Sale Beta', 'For Sale', 20000);
        await addSpaceData('s3', 'Sale Delta', 'For Sale', 25000);

        final filters = PropertyFilterStateModel(selectedListingCategory: 'For Sale');

        // Act
        List<SpaceModel> results = await postProvider.searchSpaces(null, filters: filters);

        // Assert
        expect(results.length, 2);
        expect(results.every((space) => space.category == 'For Sale'), isTrue);
        expect(results.map((s) => s.id).toList(), containsAll(['s2', 's3']));
      });

      test('returns all available spaces when selectedListingCategory is null', () async {
        // Arrange
        await addSpaceData('s1', 'Rental Alpha', 'For Rent', 1000);
        await addSpaceData('s2', 'Sale Beta', 'For Sale', 20000);
        await addSpaceData('s3', 'Other Epsilon', 'Other', 500); // Assuming 'Other' is not 'For Rent' or 'For Sale'

        final filters = PropertyFilterStateModel(selectedListingCategory: null); // Or simply PropertyFilterStateModel()

        // Act
        List<SpaceModel> results = await postProvider.searchSpaces(null, filters: filters);

        // Assert
        expect(results.length, 3); // All available spaces
      });

      test('combines selectedListingCategory with price filter', () async {
        // Arrange
        await addSpaceData('s1', 'Cheap Rental', 'For Rent', 800);
        await addSpaceData('s2', 'Expensive Rental', 'For Rent', 2000);
        await addSpaceData('s3', 'Cheap Sale', 'For Sale', 900);

        final filters = PropertyFilterStateModel(
          selectedListingCategory: 'For Rent',
          priceRange: const RangeValues(0, 1000), // Max price 1000
        );

        // Act
        List<SpaceModel> results = await postProvider.searchSpaces(null, filters: filters);

        // Assert
        expect(results.length, 1);
        expect(results.first.id, 's1');
        expect(results.first.category, 'For Rent');
        expect(results.first.price, 800);
      });
    });

    group('Unit Management', () {
      const String testSpaceId = 'testSpace1';

      setUp(() async {
        // Create a base space document for unit tests
        await mockFirestoreInstance.collection('spaces').doc(testSpaceId).set({
          'id': testSpaceId,
          'spaceName': 'Space For Unit Tests',
          'ownerId': 'owner-units',
          'category': 'For Rent',
          'units': [], // Start with empty units
          'isAvailable': true,
          'spaceName_lowercase': 'space for unit tests',
          'price': 1500.0,
          'location': const GeoPoint(0,0),
           'likes': 0,
        });
         // Reset listener count for each unit test
        mockListener.count = 0;
      });

      test('addUnitToSpace adds a unit and notifies listeners', () async {
        // Arrange
        final newUnitData = {'unitId': 'u101', 'unitNumber': '101A', 'status': 'vacant', 'floor': 1};

        // Act
        await postProvider.addUnitToSpace(testSpaceId, newUnitData);

        // Assert
        final spaceDoc = await mockFirestoreInstance.collection('spaces').doc(testSpaceId).get();
        final spaceData = spaceDoc.data();
        expect(spaceData, isNotNull);
        expect(spaceData!['units'], isA<List>());
        expect(spaceData['units'], contains(newUnitData));
        expect(mockListener.count, greaterThan(0), reason: "notifyListeners should be called");

        // Also check local cache if possible (PostProvider._spaces would need to be updated)
        // This requires addUnitToSpace to correctly update _spaces.
        // final cachedSpace = postProvider.spaces.firstWhere((s) => s.id == testSpaceId, orElse: () => SpaceModel.empty());
        // expect(cachedSpace.units, contains(newUnitData)); // This check is more complex due to copyWith and deep equality.
      });

      test('updateUnitInSpace updates an existing unit and notifies listeners', () async {
        // Arrange
        final initialUnit = {'unitId': 'u202', 'unitNumber': '202B', 'status': 'occupied', 'floor': 2};
        await postProvider.addUnitToSpace(testSpaceId, initialUnit); // Add initial unit
        mockListener.count = 0; // Reset after add

        final updatedUnitData = {'unitId': 'u202', 'unitNumber': '202B (Renovated)', 'status': 'vacant', 'floor': 2};

        // Act
        await postProvider.updateUnitInSpace(testSpaceId, 'u202', updatedUnitData);

        // Assert
        final spaceDoc = await mockFirestoreInstance.collection('spaces').doc(testSpaceId).get();
        final spaceData = spaceDoc.data();
        expect(spaceData!['units'], isA<List>());
        final unitsList = spaceData['units'] as List;
        expect(unitsList.any((u) => u['unitId'] == 'u202' && u['unitNumber'] == '202B (Renovated)'), isTrue);
        expect(unitsList.any((u) => u['unitId'] == 'u202' && u['status'] == 'vacant'), isTrue);
        expect(mockListener.count, greaterThan(0));
      });

      test('updateUnitInSpace does nothing if unitId does not exist (logs debug message)', () async {
        // Arrange
        final nonExistentUnitId = 'u999';
        final updatedUnitData = {'unitId': nonExistentUnitId, 'unitNumber': '999Z', 'status': 'vacant', 'floor': 9};

        // Act
        await postProvider.updateUnitInSpace(testSpaceId, nonExistentUnitId, updatedUnitData);

        // Assert
        final spaceDoc = await mockFirestoreInstance.collection('spaces').doc(testSpaceId).get();
        final spaceData = spaceDoc.data();
        // Check that the units array does not contain the new unit, and remains as it was (empty in this setup)
        expect((spaceData!['units'] as List).any((u) => u['unitId'] == nonExistentUnitId), isFalse);
        expect(mockListener.count, isZero); // Should not notify if no change
      });


      test('deleteUnitFromSpace removes a unit and notifies listeners', () async {
        // Arrange
        final unitToDelete = {'unitId': 'u303', 'unitNumber': '303C', 'status': 'pending_move_out', 'floor': 3};
        final unitToKeep = {'unitId': 'u304', 'unitNumber': '304D', 'status': 'vacant', 'floor': 3};
        // Initialize space with these two units
        final initialSpaceDoc = await mockFirestoreInstance.collection('spaces').doc(testSpaceId).get();
        List<Map<String,dynamic>> initialUnits = List<Map<String,dynamic>>.from(initialSpaceDoc.data()!['units'] ?? []);
        initialUnits.addAll([unitToDelete, unitToKeep]);
        await mockFirestoreInstance.collection('spaces').doc(testSpaceId).update({'units': initialUnits});

        mockListener.count = 0; // Reset listener count

        // Act
        await postProvider.deleteUnitFromSpace(testSpaceId, 'u303');

        // Assert
        final spaceDoc = await mockFirestoreInstance.collection('spaces').doc(testSpaceId).get();
        final spaceData = spaceDoc.data();
        expect(spaceData!['units'], isA<List>());
        final unitsList = spaceData['units'] as List;
        expect(unitsList.any((u) => u['unitId'] == 'u303'), isFalse); // Should be deleted
        expect(unitsList.any((u) => u['unitId'] == 'u304'), isTrue);  // Should remain
        expect(mockListener.count, greaterThan(0));
      });

       test('deleteUnitFromSpace does nothing if unitId does not exist (logs debug message)', () async {
        // Arrange
        final unitToKeep = {'unitId': 'u401', 'unitNumber': '401E', 'status': 'vacant', 'floor': 4};
        // Initialize space with this unit
        final initialSpaceDoc = await mockFirestoreInstance.collection('spaces').doc(testSpaceId).get();
        List<Map<String,dynamic>> initialUnitsList = List<Map<String,dynamic>>.from(initialSpaceDoc.data()!['units'] ?? []);
        initialUnitsList.add(unitToKeep);
        await mockFirestoreInstance.collection('spaces').doc(testSpaceId).update({'units': initialUnitsList});

        mockListener.count = 0;
        final nonExistentUnitId = 'u888';

        // Act
        await postProvider.deleteUnitFromSpace(testSpaceId, nonExistentUnitId);

        // Assert
        final spaceDoc = await mockFirestoreInstance.collection('spaces').doc(testSpaceId).get();
        final spaceData = spaceDoc.data();
        final unitsList = spaceData!['units'] as List;
        expect(unitsList.length, initialUnitsList.length); // Length should be unchanged
        expect(unitsList.any((u) => u['unitId'] == unitToKeep['unitId']), isTrue);
        expect(mockListener.count, isZero); // No change, no notification
      });
    });
  });
}
