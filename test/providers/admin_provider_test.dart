import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
// Assuming UserModel is in 'package:cloudkeja/models/user_model.dart' if needed for context,
// but tests will primarily focus on what AdminProvider writes to Firestore.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminProvider Tests', () {
    late AdminProvider adminProvider;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      // To test AdminProvider, it needs to use our fakeFirestore instance.
      // AdminProvider internally creates `_firestore = FirebaseFirestore.instance`.
      // For FakeFirebaseFirestore to work here, it typically overrides the static `FirebaseFirestore.instance`.
      // If AdminProvider were refactored for DI: AdminProvider(firestore: fakeFirestore)
      // For now, we rely on FakeFirebaseFirestore's behavior of overriding the static instance.
      adminProvider = AdminProvider();
    });

    group('updateUserSubscriptionTier', () {
      const testUserId = 'user123';
      const newTierId = 'premium';
      final expiryDate = Timestamp.fromDate(DateTime.now().add(const Duration(days: 30)));
      final nullExpiryDate = null;

      test('should update subscriptionTier and subscriptionExpiryDate correctly', () async {
        // Arrange: Add a dummy user document so update doesn't fail on non-existent doc
        await fakeFirestore.collection('users').doc(testUserId).set({'name': 'Initial User'});

        // Act
        await adminProvider.updateUserSubscriptionTier(testUserId, newTierId, expiryDate);

        // Assert
        final userDoc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(userDoc.exists, isTrue);
        expect(userDoc.data()?['subscriptionTier'], newTierId);
        expect(userDoc.data()?['subscriptionExpiryDate'], expiryDate);
        expect(userDoc.data()?['updatedAt'], isA<Timestamp>()); // Check if updatedAt is set
      });

      test('should update subscriptionTier and set subscriptionExpiryDate to null correctly', () async {
        // Arrange
        await fakeFirestore.collection('users').doc(testUserId).set({'name': 'Initial User', 'subscriptionExpiryDate': expiryDate});

        // Act
        await adminProvider.updateUserSubscriptionTier(testUserId, newTierId, nullExpiryDate);

        // Assert
        final userDoc = await fakeFirestore.collection('users').doc(testUserId).get();
        expect(userDoc.exists, isTrue);
        expect(userDoc.data()?['subscriptionTier'], newTierId);
        expect(userDoc.data()?['subscriptionExpiryDate'], isNull);
        expect(userDoc.data()?['updatedAt'], isA<Timestamp>());
      });
    });

    group('updateLandlordAdminUserCount', () {
      const landlordUserId = 'landlordUser456';
      const newAdminCount = 5;

      test('should update adminUserCount correctly for valid count', () async {
        // Arrange
        await fakeFirestore.collection('users').doc(landlordUserId).set({'name': 'Landlord User', 'isLandlord': true});

        // Act
        await adminProvider.updateLandlordAdminUserCount(landlordUserId, newAdminCount);

        // Assert
        final userDoc = await fakeFirestore.collection('users').doc(landlordUserId).get();
        expect(userDoc.exists, isTrue);
        expect(userDoc.data()?['adminUserCount'], newAdminCount);
        expect(userDoc.data()?['updatedAt'], isA<Timestamp>());
      });

      test('should throw ArgumentError if newAdminUserCount is less than 1', () async {
        // Arrange
        const invalidAdminCount = 0;

        // Act & Assert
        expect(
          () async => await adminProvider.updateLandlordAdminUserCount(landlordUserId, invalidAdminCount),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError if newAdminUserCount is negative', () async {
        // Arrange
        const invalidAdminCount = -1;

        // Act & Assert
        expect(
          () async => await adminProvider.updateLandlordAdminUserCount(landlordUserId, invalidAdminCount),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('update should not occur if count is invalid', () async {
        // Arrange
        await fakeFirestore.collection('users').doc(landlordUserId).set({'name': 'Landlord User', 'isLandlord': true, 'adminUserCount': 2});
        const invalidAdminCount = 0;

        // Act
        try {
          await adminProvider.updateLandlordAdminUserCount(landlordUserId, invalidAdminCount);
        } catch (e) {
          // Expected error
        }

        // Assert: Check that adminUserCount remains unchanged
        final userDoc = await fakeFirestore.collection('users').doc(landlordUserId).get();
        expect(userDoc.data()?['adminUserCount'], 2); // Should still be the initial value
      });
    });
  });
}
