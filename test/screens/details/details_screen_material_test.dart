import 'dart:io'; // For File in StubAuthProvider, though not used in these tests
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For GeoPoint in SpaceModel

import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/details/details_screen_material.dart';
import 'package:cloudkeja/widgets/unit_display_carousel.dart';

// Simple stub for testing isOwner
class StubAuthProvider extends ChangeNotifier implements AuthProvider {
  UserModel? _currentUser;

  StubAuthProvider({UserModel? user}) : _currentUser = user;

  @override
  UserModel? get user => _currentUser;

  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> registerUser(Map<String, dynamic> userData, String password) async {}
  @override
  bool get isLoading => false;
  @override
  String? get currentUserId => _currentUser?.userId;
  @override
  Future<UserModel?> getOwnerDetails(String ownerId) async => _currentUser?.userId == ownerId ? _currentUser : null;
  @override
  Future<void> logout() async { _currentUser = null; notifyListeners(); }
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  Future<void> updateUserProfile(UserModel userModel, File? imageFile) async {}
  @override
  Stream<UserModel?> get userStream => Stream.value(_currentUser);
  @override
  Future<List<UserModel>> getAllLandlords() async => [];
  @override
  Future<List<UserModel>> getAllUsers() async => [];
  @override
  Future<void> toggleUserRole(String userId, String currentRole) async {}
  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {}
}


Future<void> pumpMaterialDetailsScreen(
  WidgetTester tester,
  SpaceModel space,
  {UserModel? currentUser}
) async {
  final authProvider = StubAuthProvider(user: currentUser);
  final postProvider = PostProvider(); // Assumes it uses mocked Firestore from global test setup

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<PostProvider>.value(value: postProvider),
      ],
      child: MaterialApp(
        home: DetailsScreenMaterial(space: space),
        // Define routes if chat navigation is tested, though not primary focus here
        // routes: { ChatRoom.routeName: (_) => Scaffold(body: Text('Mock Chat Room')),},
      ),
    ),
  );
}

// Helper to create a SpaceModel with common defaults for testing
SpaceModel createTestSpace({
  String id = 'testSpace1',
  String ownerId = 'owner1',
  List<Map<String, dynamic>>? units,
  String spaceName = 'Test Space',
}) {
  return SpaceModel(
    id: id,
    spaceName: spaceName,
    ownerId: ownerId,
    units: units,
    // Add other required fields with default values
    address: '123 Test St',
    category: 'For Rent',
    description: 'A nice test space',
    price: 1000,
    location: const GeoPoint(0, 0),
    images: ['http://example.com/image.png'],
    propertyType: 'Apartment',
    numBedrooms: 2,
    numBathrooms: 1,
    amenities: ['WiFi'],
    isAvailable: true,
    likes: 0,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  );
}


void main() {
  group('DetailsScreenMaterial Tests', () {
    testWidgets('Displays unit counts correctly', (WidgetTester tester) async {
      final spaceWithUnits = createTestSpace(units: [
        {'unitId': 'u1', 'status': 'vacant', 'unitNumber': '101', 'floor': 1},
        {'unitId': 'u2', 'status': 'occupied', 'unitNumber': '102', 'floor': 1},
        {'unitId': 'u3', 'status': 'pending_move_out', 'unitNumber': '103', 'floor': 1},
        {'unitId': 'u4', 'status': 'vacant', 'unitNumber': '201', 'floor': 2},
      ]);
      await pumpMaterialDetailsScreen(tester, spaceWithUnits);

      expect(find.text('Unit Information'), findsOneWidget);
      expect(find.text('Total Units: 4'), findsOneWidget);
      // Available = vacant + pending_move_out = 2 + 1 = 3
      expect(find.text('Available Units (Vacant or Pending): 3'), findsOneWidget);
      expect(find.text('Strictly Vacant Units: 2'), findsOneWidget);
    });

    testWidgets('Displays "No unit information" when units list is empty', (WidgetTester tester) async {
      final spaceNoUnits = createTestSpace(units: []);
      await pumpMaterialDetailsScreen(tester, spaceNoUnits);

      expect(find.text('Unit Information'), findsOneWidget);
      expect(find.text('No unit information available for this property.'), findsOneWidget);
    });

    testWidgets('Displays "No unit information" when units is null', (WidgetTester tester) async {
      final spaceNullUnits = createTestSpace(units: null);
      await pumpMaterialDetailsScreen(tester, spaceNullUnits);

      expect(find.text('Unit Information'), findsOneWidget);
      expect(find.text('No unit information available for this property.'), findsOneWidget);
    });

    testWidgets('UnitDisplayCarousel is present and receives correct props (isOwner: true)', (WidgetTester tester) async {
      final space = createTestSpace(id: 'space123', ownerId: 'ownerABC', units: [{'unitId': 'u1'}]);
      final currentUser = UserModel(userId: 'ownerABC', email: 'owner@example.com', name: 'Owner User');

      await pumpMaterialDetailsScreen(tester, space, currentUser: currentUser);

      final carouselFinder = find.byType(UnitDisplayCarousel);
      expect(carouselFinder, findsOneWidget);

      final UnitDisplayCarousel carouselWidget = tester.widget(carouselFinder);
      expect(carouselWidget.isOwner, isTrue);
      expect(carouselWidget.spaceId, 'space123');
      expect(carouselWidget.units, space.units);
    });

    testWidgets('UnitDisplayCarousel is present and receives correct props (isOwner: false)', (WidgetTester tester) async {
      final space = createTestSpace(id: 'space456', ownerId: 'ownerXYZ', units: [{'unitId': 'u2'}]);
      final currentUser = UserModel(userId: 'tenant123', email: 'tenant@example.com', name: 'Tenant User');

      await pumpMaterialDetailsScreen(tester, space, currentUser: currentUser);

      final carouselFinder = find.byType(UnitDisplayCarousel);
      expect(carouselFinder, findsOneWidget);

      final UnitDisplayCarousel carouselWidget = tester.widget(carouselFinder);
      expect(carouselWidget.isOwner, isFalse);
      expect(carouselWidget.spaceId, 'space456');
       expect(carouselWidget.units, space.units);
    });
  });
}
