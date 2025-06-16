import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart';
import 'package:cloudkeja/screens/subscription/subscription_plans_screen.dart';

// Generate mocks for SubscriptionProvider
@GenerateMocks([SubscriptionProvider])
import 'subscription_plans_screen_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockSubscriptionProvider mockSubscriptionProvider;

  setUp(() {
    mockSubscriptionProvider = MockSubscriptionProvider();
  });

  // Helper function to pump the widget with necessary providers
  Future<void> pumpSubscriptionPlansScreen(WidgetTester tester) async {
    // Define some mock plans
    final mockPlans = [
      {
        'id': 'starter_test',
        'name': 'Test Starter Plan',
        'price': 0,
        'propertyLimit': 1,
        'adminUserLimit': 1,
        'features': ['Feature 1S', 'Feature 2S'],
      },
      {
        'id': 'premium_test',
        'name': 'Test Premium Plan',
        'price': 1000,
        'propertyLimit': 10,
        'adminUserLimit': 5,
        'features': ['Feature 1P', 'Feature 2P', 'Feature 3P'],
      },
    ];

    when(mockSubscriptionProvider.getSubscriptionPlans()).thenReturn(mockPlans);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SubscriptionProvider>.value(
            value: mockSubscriptionProvider,
          ),
        ],
        child: const MaterialApp(
          home: SubscriptionPlansScreen(),
        ),
      ),
    );
  }

  group('SubscriptionPlansScreen Widget Tests', () {
    testWidgets('displays subscription plans and their details', (WidgetTester tester) async {
      await pumpSubscriptionPlansScreen(tester);
      await tester.pumpAndSettle(); // Allow UI to build

      // Verify plan names are displayed
      expect(find.text('Test Starter Plan'), findsOneWidget);
      expect(find.text('Test Premium Plan'), findsOneWidget);

      // Verify prices (assuming KES prefix as in screen)
      expect(find.text('Price: KES 0'), findsOneWidget);
      expect(find.text('Price: KES 1000'), findsOneWidget);

      // Verify a feature from each plan
      expect(find.text('Feature 1S'), findsOneWidget);
      expect(find.text('Feature 1P'), findsOneWidget);

      // Verify limits
      expect(find.text('Property Limit: 1'), findsOneWidget);
      expect(find.text('Admin User Limit: 1', skipOffstage: false), findsOneWidget); // SkipOffstage for the second card

      expect(find.text('Property Limit: 10'), findsOneWidget);
      expect(find.text('Admin User Limit: 5', skipOffstage: false), findsOneWidget);

      // Verify "Choose Plan" buttons exist (one for each plan)
      expect(find.widgetWithText(ElevatedButton, 'Choose Plan'), findsNWidgets(2));
    });

    testWidgets('tapping "Choose Plan" button shows SnackBar', (WidgetTester tester) async {
      await pumpSubscriptionPlansScreen(tester);
      await tester.pumpAndSettle();

      // Find the first "Choose Plan" button and tap it
      final choosePlanButton = find.widgetWithText(ElevatedButton, 'Choose Plan').first;
      await tester.tap(choosePlanButton);
      await tester.pump(); // Pump to show SnackBar animation started
      await tester.pump(); // Pump again to ensure SnackBar is visible

      // Verify SnackBar is shown with the plan name
      // SnackBar content might be dynamic, check for part of it or the presence of SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Selected: Test Starter Plan'), findsOneWidget);

      // Wait for SnackBar to disappear to avoid interference with next tests if any
      await tester.pump(const Duration(seconds: 3)); // Default SnackBar duration + buffer
    });
  });
}
