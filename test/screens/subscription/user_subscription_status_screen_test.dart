import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/subscription_provider.dart';
import 'package:cloudkeja/screens/subscription/user_subscription_status_screen.dart';
import 'package:cloudkeja/screens/subscription/subscription_plans_screen.dart'; // For routeName

// Generate mocks for AuthProvider and SubscriptionProvider
@GenerateMocks([AuthProvider, SubscriptionProvider])
import 'user_subscription_status_screen_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAuthProvider mockAuthProvider;
  late MockSubscriptionProvider mockSubscriptionProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockSubscriptionProvider = MockSubscriptionProvider();
  });

  // Helper function to pump the widget with necessary providers
  Future<void> pumpUserSubscriptionStatusScreen(
    WidgetTester tester, {
    UserModel? currentUser,
    Map<String, dynamic>? planDetails,
  }) async {
    // Mock AuthProvider
    when(mockAuthProvider.user).thenReturn(currentUser); // Directly return the user model

    // Mock SubscriptionProvider
    if (currentUser?.subscriptionTier != null && planDetails != null) {
      when(mockSubscriptionProvider.getPlanById(currentUser!.subscriptionTier!))
          .thenReturn(planDetails);
    } else if (currentUser?.subscriptionTier != null) {
      // Default mock if planDetails not provided but tier exists
      when(mockSubscriptionProvider.getPlanById(currentUser!.subscriptionTier!))
          .thenReturn({
            'id': currentUser.subscriptionTier!,
            'name': 'Default Mock Plan',
            'propertyLimit': 1,
            'adminUserLimit': 1,
          });
    }


    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ChangeNotifierProvider<SubscriptionProvider>.value(
            value: mockSubscriptionProvider,
          ),
        ],
        child: MaterialApp(
          home: const UserSubscriptionStatusScreen(),
          // Define routes if your screen uses Navigator.pushNamed
          routes: {
            SubscriptionPlansScreen.routeName: (context) => const Scaffold(body: Text('Mock Subscription Plans Screen')),
          },
        ),
      ),
    );
  }

  group('UserSubscriptionStatusScreen Widget Tests', () {
    final testUser = UserModel(
      userId: 'user1',
      name: 'Test User',
      email: 'test@example.com',
      subscriptionTier: 'premium_test',
      subscriptionExpiryDate: Timestamp.fromDate(DateTime(2024, 12, 31)),
      propertyCount: 5,
      adminUserCount: 2,
    );

    final testPlanDetails = {
      'id': 'premium_test',
      'name': 'Premium Test Plan',
      'propertyLimit': 10,
      'adminUserLimit': 3,
      'price': 2000,
      'features': ['P Feature 1', 'P Feature 2'],
    };

    testWidgets('displays user subscription details correctly', (WidgetTester tester) async {
      await pumpUserSubscriptionStatusScreen(
        tester,
        currentUser: testUser,
        planDetails: testPlanDetails,
      );
      await tester.pumpAndSettle();

      // Verify tier name
      expect(find.text('Premium Test Plan', skipOffstage: false), findsOneWidget);
      // Verify expiry date (formatted)
      expect(find.text('31 Dec 2024, 12:00 AM', skipOffstage: false), findsOneWidget); // Format might vary slightly based on intl
      // Verify property usage
      expect(find.text('5 / 10 properties', skipOffstage: false), findsOneWidget);
      // Verify admin user usage
      expect(find.text('2 / 3 users', skipOffstage: false), findsOneWidget);
    });

    testWidgets('displays "Unlimited" for limits if -1', (WidgetTester tester) async {
       final unlimitedUser = UserModel(
        userId: 'userUnlimited',
        subscriptionTier: 'enterprise_test',
        propertyCount: 50,
        adminUserCount: 10,
      );
      final unlimitedPlan = {
        'id': 'enterprise_test', 'name': 'Enterprise Unlimited',
        'propertyLimit': -1, 'adminUserLimit': -1,
      };
      await pumpUserSubscriptionStatusScreen(
        tester,
        currentUser: unlimitedUser,
        planDetails: unlimitedPlan,
      );
      await tester.pumpAndSettle();

      expect(find.text('50 / Unlimited properties', skipOffstage: false), findsOneWidget);
      expect(find.text('10 / Unlimited users', skipOffstage: false), findsOneWidget);
    });


    testWidgets('displays N/A for expiry date if null', (WidgetTester tester) async {
      final userNoExpiry = testUser.copyWith(subscriptionExpiryDate: null);
      await pumpUserSubscriptionStatusScreen(
        tester,
        currentUser: userNoExpiry,
        planDetails: testPlanDetails,
      );
      await tester.pumpAndSettle();
      expect(find.text('N/A (or Lifetime)', skipOffstage: false), findsOneWidget);
    });

    testWidgets('displays loading or prompt if user is null', (WidgetTester tester) async {
      await pumpUserSubscriptionStatusScreen(tester, currentUser: null);
      // Don't pumpAndSettle if it's a loading state that doesn't settle.
      await tester.pump();

      expect(find.text('Loading user data...'), findsOneWidget);
      // Or, if it shows a "Login" prompt or similar for null user.
      // This depends on the exact implementation of the loading/null user state.
    });

    testWidgets('tapping "Manage Subscription" button navigates to SubscriptionPlansScreen', (WidgetTester tester) async {
      await pumpUserSubscriptionStatusScreen(
        tester,
        currentUser: testUser,
        planDetails: testPlanDetails,
      );
      await tester.pumpAndSettle();

      final manageButton = find.widgetWithText(ElevatedButton, 'Manage Subscription');
      expect(manageButton, findsOneWidget);

      await tester.tap(manageButton);
      await tester.pumpAndSettle(); // Allow navigation to complete

      // Verify navigation (e.g., by checking for a widget unique to SubscriptionPlansScreen)
      // For this test, we've added a mock route that shows a Scaffold with specific text.
      expect(find.text('Mock Subscription Plans Screen'), findsOneWidget);
    });
  });
}
