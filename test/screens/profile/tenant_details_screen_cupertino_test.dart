import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/location_model.dart'; // Assuming this exists for SpaceModel.location
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/providers/tenancy_provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/profile/tenant_details_screen_cupertino.dart';
import 'package:get/get.dart'; // For Get.to used in dialogs/navigation

// Mocks (assuming these are defined as in previous steps or in a shared mock file)
class MockAuthProvider extends Mock implements AuthProvider {}
class MockPaymentProvider extends Mock implements PaymentProvider {}
class MockPlatformService extends Mock implements PlatformService {}
// Mock TenancyProvider if TenantDetailsScreenCupertino fetches tenancy info directly
class MockTenancyProvider extends Mock implements TenancyProvider {}


// Testable SpaceModel
final mockSpace = SpaceModel(
  id: 'space123',
  spaceName: 'Cozy Apartment in Downtown',
  address: '123 Main St, Anytown',
  price: 25000,
  rentTime: 30, // days
  images: ['https://via.placeholder.com/300x200.png?text=Cozy+Apartment'],
  location: const Location(latitude: 34.052235, longitude: -118.243683), // Example coordinates
  userId: 'user1',
  isCheckedIn: true, // Assuming user is checked in for this test
  // Add other necessary fields that TenantDetailsScreenCupertino might use
);

Widget createTenantDetailsTestableWidget({
  required SpaceModel space,
  required MockAuthProvider mockAuthProvider,
  required MockPaymentProvider mockPaymentProvider,
  required MockPlatformService mockPlatformService,
  // required MockTenancyProvider mockTenancyProvider, // If needed
}) {
  // Mock current user for FirebaseAuth.instance.currentUser!.uid
  // This is tricky without direct Firebase mocking. Assume AuthProvider can provide it or it's handled.
  // For now, we'll rely on the PaymentProvider mock to not fail due to UID.
  when(mockAuthProvider.user).thenReturn(UserModel(userId: 'testUid123', phone: '0712345678'));


  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
      ChangeNotifierProvider<PaymentProvider>.value(value: mockPaymentProvider),
      Provider<PlatformService>.value(value: mockPlatformService),
      // ChangeNotifierProvider<TenancyProvider>.value(value: mockTenancyProvider), // If used
    ],
    child: GetMaterialApp( // Using GetMaterialApp for Get.to and Get.snackbar (though snackbar should be replaced)
      home: CupertinoApp( // CupertinoApp for Cupertino theming
        home: TenantDetailsScreenCupertino(space: space),
      ),
    ),
  );
}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockPaymentProvider mockPaymentProvider;
  late MockPlatformService mockPlatformService;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockPaymentProvider = MockPaymentProvider();
    mockPlatformService = MockPlatformService();
    when(mockPlatformService.useCupertino).thenReturn(true); // Ensure Cupertino mode
  });

  group('TenantDetailsScreenCupertino Tests', () {
    testWidgets('Renders initial UI elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTenantDetailsTestableWidget(
        space: mockSpace,
        mockAuthProvider: mockAuthProvider,
        mockPaymentProvider: mockPaymentProvider,
        mockPlatformService: mockPlatformService,
      ));
      await tester.pumpAndSettle();


      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.text(mockSpace.spaceName!), findsOneWidget); // Title in Nav Bar

      // Check for key sections/widgets by the text they display or type
      // These finds are for elements within the private sub-widgets.
      // We find them through their text content as a proxy.
      expect(find.text('Checked in'), findsOneWidget);
      expect(find.text('Total due Amount: '), findsOneWidget);
      expect(find.text('KES ${mockSpace.price!.toStringAsFixed(0)}'), findsOneWidget);
      expect(find.widgetWithText(CupertinoButton, 'Make Payment'), findsOneWidget);
      expect(find.text('Check in'), findsOneWidget); // From _DateFieldCupertino
      expect(find.text('Check out'), findsOneWidget); // From _DateFieldCupertino
      expect(find.widgetWithText(CupertinoButton, 'Checkout Now'), findsOneWidget);
      expect(find.text((mockSpace.rentTime ?? 0).toString()), findsOneWidget); // Days from _DaysWidgetCupertino
      expect(find.text('Total stay'), findsOneWidget);
      expect(find.text('Rent Repayment History'), findsOneWidget);
    });

    testWidgets('Make Payment button is present and tappable', (WidgetTester tester) async {
       await tester.pumpWidget(createTenantDetailsTestableWidget(
        space: mockSpace,
        mockAuthProvider: mockAuthProvider,
        mockPaymentProvider: mockPaymentProvider,
        mockPlatformService: mockPlatformService,
      ));
      await tester.pumpAndSettle();

      final makePaymentButton = find.widgetWithText(CupertinoButton, 'Make Payment');
      expect(makePaymentButton, findsOneWidget);
      await tester.tap(makePaymentButton);
      await tester.pumpAndSettle();
      // Verifies dialog is shown (UserPaymentDialogCupertinoContent would be inside)
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Make Payment'), findsNWidgets(2)); // Dialog title + button text
    });

    testWidgets('Checkout Now button shows action sheet', (WidgetTester tester) async {
      when(mockPaymentProvider.checkOut(any, any)).thenAnswer((_) async {}); // Mock checkout

      await tester.pumpWidget(createTenantDetailsTestableWidget(
        space: mockSpace,
        mockAuthProvider: mockAuthProvider,
        mockPaymentProvider: mockPaymentProvider,
        mockPlatformService: mockPlatformService,
      ));
      await tester.pumpAndSettle();

      final checkoutButton = find.widgetWithText(CupertinoButton, 'Checkout Now');
      expect(checkoutButton, findsOneWidget);
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      expect(find.text('Confirm Checkout'), findsOneWidget);
    });
  });

  // Example test for a sub-widget (can be expanded for others)
  group('_DateFieldCupertino (indirectly via TenantDetailsScreenCupertino)', () {
    testWidgets('displays title and formatted date', (WidgetTester tester) async {
      await tester.pumpWidget(createTenantDetailsTestableWidget(
        space: mockSpace, // mockSpace has rentTime = 30
        mockAuthProvider: mockAuthProvider,
        mockPaymentProvider: mockPaymentProvider,
        mockPlatformService: mockPlatformService,
      ));
      await tester.pumpAndSettle();

      // Test for "Check in" date field
      expect(find.text('Check in'), findsOneWidget);
      expect(find.text(DateFormat('dd MMM yyyy').format(DateTime.now())), findsOneWidget);

      // Test for "Check out" date field
      expect(find.text('Check out'), findsOneWidget);
      expect(find.text(DateFormat('dd MMM yyyy').format(DateTime.now().add(Duration(days: mockSpace.rentTime ?? 30)))), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.calendar), findsNWidgets(2)); // One for each DateField
    });
  });
   group('_RentRepaymentHistoryCupertino (indirectly via TenantDetailsScreenCupertino)', () {
    testWidgets('displays title, header, and mock items', (WidgetTester tester) async {
      await tester.pumpWidget(createTenantDetailsTestableWidget(
        space: mockSpace,
        mockAuthProvider: mockAuthProvider,
        mockPaymentProvider: mockPaymentProvider,
        mockPlatformService: mockPlatformService,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Rent Repayment History'), findsOneWidget);
      // Header row
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Due date'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      // Mock items (as implemented in _RentRepaymentHistoryCupertino)
      expect(find.text('May, 2022'), findsOneWidget);
      expect(find.text('06/May/2022'), findsOneWidget);
      expect(find.text('Paid'), findsNWidgets(3)); // 3 mock items are "Paid"
    });
  });
}
