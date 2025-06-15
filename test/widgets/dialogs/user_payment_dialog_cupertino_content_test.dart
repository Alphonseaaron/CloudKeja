import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/user_model.dart'; // For AuthProvider mock
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart'; // If mpesa_helper uses it
import 'package:cloudkeja/services/platform_service.dart'; // For MyDropDown
import 'package:cloudkeja/widgets/dialogs/user_payment_dialog_cupertino_content.dart';
import 'package:cloudkeja/helpers/my_dropdown.dart'; // The adaptive MyDropDown
import 'package:cloudkeja/helpers/mpesa_helper.dart'; // For mpesaPayment if it's directly called

// --- Mocks ---
class MockAuthProvider extends Mock implements AuthProvider {}
class MockPaymentProvider extends Mock implements PaymentProvider {} // If mpesa_helper uses it
class MockPlatformService extends Mock implements PlatformService {}
// Mock mpesaPayment if it's a top-level function and needs mocking.
// For this test, we'll assume mpesaPayment is part of MpesaHelper and might be hard to mock directly
// without a wrapper or dependency injection for MpesaHelper itself.
// We will mock AuthProvider to provide user data, and assume mpesaPayment will be called.

// Mock SpaceModel
final mockDialogSpace = SpaceModel(
  id: 'dialogSpace1',
  spaceName: 'Test Dialog Space',
  price: 12000,
  // Add other fields UserPaymentDialogCupertinoContent might use from space
);

// Mock UserModel for AuthProvider
final mockUser = UserModel(
  userId: 'testUser123',
  name: 'Test User',
  email: 'test@example.com',
  phone: '0712345678', // Crucial for mpesaPayment
);


Widget createUserPaymentDialogTestWidget({
  required SpaceModel space,
  required MockAuthProvider mockAuthProvider,
  // MockPaymentProvider mockPaymentProvider, // If MpesaHelper is refactored to use it
  required MockPlatformService mockPlatformService,
}) {
  when(mockAuthProvider.user).thenReturn(mockUser);
  when(mockPlatformService.useCupertino).thenReturn(true); // Ensure MyDropDown uses Cupertino

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
      // Provider<PaymentProvider>.value(value: mockPaymentProvider), // If needed
      Provider<PlatformService>.value(value: mockPlatformService),
    ],
    child: CupertinoApp(
      home: CupertinoPageScaffold(
        child: Center(
          // The dialog content is typically shown within an AlertDialog context.
          // For testing the content itself, we can place it directly.
          child: UserPaymentDialogCupertinoContent(space: space),
        ),
      ),
    ),
  );
}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockPlatformService mockPlatformService;
  // late MockPaymentProvider mockPaymentProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockPlatformService = MockPlatformService();
    // mockPaymentProvider = MockPaymentProvider();
  });

  testWidgets('UserPaymentDialogCupertinoContent renders initial UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(createUserPaymentDialogTestWidget(
      space: mockDialogSpace,
      mockAuthProvider: mockAuthProvider,
      mockPlatformService: mockPlatformService,
    ));

    expect(find.text('Payment For'), findsOneWidget);
    expect(find.text('Payment Using'), findsOneWidget);
    expect(find.byType(MyDropDown), findsNWidgets(2)); // Two dropdowns
    expect(find.text('Amount Due:'), findsOneWidget);
    expect(find.text('KES ${mockDialogSpace.price?.toStringAsFixed(0) ?? '0'}'), findsNWidgets(2)); // Due and Total
    expect(find.text('Total to Pay:'), findsOneWidget);
    expect(find.widgetWithText(CupertinoButton, 'Confirm & Pay'), findsOneWidget);
  });

  testWidgets('UserPaymentDialogCupertinoContent shows error if phone number is missing', (WidgetTester tester) async {
    // Mock user without a phone number
    when(mockAuthProvider.user).thenReturn(UserModel(userId: 'noPhoneUser', email: 'nophone@example.com'));

    await tester.pumpWidget(createUserPaymentDialogTestWidget(
      space: mockDialogSpace,
      mockAuthProvider: mockAuthProvider,
      mockPlatformService: mockPlatformService,
    ));

    await tester.tap(find.widgetWithText(CupertinoButton, 'Confirm & Pay'));
    await tester.pump(); // Allow state update for error message

    expect(find.text('User phone number not available.'), findsOneWidget);
  });

  testWidgets('UserPaymentDialogCupertinoContent shows error if payment options not selected', (WidgetTester tester) async {
    await tester.pumpWidget(createUserPaymentDialogTestWidget(
      space: mockDialogSpace,
      mockAuthProvider: mockAuthProvider,
      mockPlatformService: mockPlatformService,
    ));

    // Don't select options in MyDropDown widgets

    await tester.tap(find.widgetWithText(CupertinoButton, 'Confirm & Pay'));
    await tester.pump();

    expect(find.text('Please select payment amount and method.'), findsOneWidget);
  });

  // Note: Testing the actual mpesaPayment call and its success/failure states
  // is more of an integration test if mpesaPayment makes real external calls or
  // relies on platform channels.
  // For widget tests, we'd typically mock the MpesaHelper or the function itself
  // if it were injectable. Here, we test the UI reaction to states.

  testWidgets('UserPaymentDialogCupertinoContent shows loading indicator on button when processing', (WidgetTester tester) async {
    // This test assumes mpesaPayment will be delayed.
    // We can't easily mock the global mpesaPayment function without DI.
    // So, this test will show the loader briefly if the actual mpesaPayment is fast.
    // A better approach would be to inject and mock MpesaHelper.

    await tester.pumpWidget(createUserPaymentDialogTestWidget(
      space: mockDialogSpace,
      mockAuthProvider: mockAuthProvider,
      mockPlatformService: mockPlatformService,
    ));

    // Simulate selecting options for MyDropDown
    // This is complex as MyDropDown itself shows a modal.
    // We'll assume options are selected and proceed to tap "Confirm & Pay".
    // To make this testable, MyDropDown should have initial values or be controllable.
    // For now, we bypass this and directly test the loading state by setting internal state.
    // This is not ideal but a limitation if sub-widget interaction is too complex for pure widget test.

    // Directly find the state and set necessary conditions to enable payment button.
    final state = tester.state<State<UserPaymentDialogCupertinoContent>>(find.byType(UserPaymentDialogCupertinoContent));
    // ignore: invalid_use_of_protected_member
    state.setState(() {
      // Simulate that options have been selected to enable the button logic for mpesaPayment
      (state as dynamic)._selectedPaymentOption = 'Total Due Amount'; // Accessing private member for test
      (state as dynamic)._selectedPaymentMethod = 'Mpesa'; // Accessing private member for test
    });
    await tester.pump();


    // Tap the button. If mpesaPayment is not truly mocked to delay,
    // the loader might only appear for a very short time.
    await tester.tap(find.widgetWithText(CupertinoButton, 'Confirm & Pay'));
    await tester.pump(); // Start processing, isLoading should be true

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

    // It's good practice to wait for mpesaPayment to complete or mock its duration.
    // Since we can't easily mock its duration here without more setup,
    // we'll pumpAndSettle and expect the loader to disappear.
    await tester.pumpAndSettle(const Duration(seconds: 2)); // Allow time for simulated payment
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
    // Further expect error or success message/navigation based on mpesaPayment outcome.
    // If mpesaPayment is real, it will likely fail in test env.
    // The widget's own error handling for mpesaPayment should show an error message.
    expect(find.textContaining('Payment failed'), findsOneWidget); // Assuming it fails in test
  });
}
