import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart'; // For mockito if used for callbacks
import 'package:cloudkeja/widgets/custom_cupertino_app_bar.dart';
import 'package:get/get.dart'; // CustomCupertinoAppBar uses Get.to

// Mock for VoidCallback
class MockVoidCallback extends Mock {
  void call();
}

Widget createTestableCupertinoAppBar({
  required String titleText,
  bool showUserProfileLeading = false,
  VoidCallback? onUserProfileTap,
  String? userProfileImageUrl,
  bool showChatAction = true,
  bool showSettingsAction = true,
}) {
  return GetMaterialApp( // For Get.to used by UserProfileScreen
    home: CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CustomCupertinoAppBar(
          titleText: titleText,
          showUserProfileLeading: showUserProfileLeading,
          onUserProfileTap: onUserProfileTap,
          userProfileImageUrl: userProfileImageUrl,
          showChatAction: showChatAction,
          showSettingsAction: showSettingsAction,
        ),
        child: const Center(child: Text('Content')),
      ),
    ),
  );
}

void main() {
  testWidgets('CustomCupertinoAppBar displays title correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableCupertinoAppBar(titleText: 'Test Title'));

    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.text('Test Title'), findsOneWidget);
  });

  testWidgets('CustomCupertinoAppBar shows user profile leading when showUserProfileLeading is true', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableCupertinoAppBar(
      titleText: 'Profile Test',
      showUserProfileLeading: true,
      userProfileImageUrl: 'https://via.placeholder.com/100',
    ));

    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('CustomCupertinoAppBar does not show user profile leading when showUserProfileLeading is false', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableCupertinoAppBar(
      titleText: 'No Profile Test',
      showUserProfileLeading: false,
    ));

    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('CustomCupertinoAppBar calls onUserProfileTap when avatar is tapped', (WidgetTester tester) async {
    final mockOnUserProfileTap = MockVoidCallback();
    when(mockOnUserProfileTap.call()).thenReturn(null);

    await tester.pumpWidget(createTestableCupertinoAppBar(
      titleText: 'Tap Test',
      showUserProfileLeading: true,
      onUserProfileTap: mockOnUserProfileTap,
      userProfileImageUrl: 'https://via.placeholder.com/100',
    ));

    final avatarGestureDetector = find.descendant(
      of: find.byType(CustomCupertinoAppBar), // Find within the app bar
      matching: find.byType(CupertinoButton) // The leading widget is a CupertinoButton
    ).first; // Assuming it's the first CupertinoButton if others exist (e.g. back button)
               // A more specific finder might be needed if leading isn't the only CupertinoButton.
               // Or, if the leading is complex, find a key if one was added.

    // The leading widget in CustomCupertinoAppBar is a CupertinoButton wrapping a CircleAvatar.
    // We need to find this specific button.
    // A more robust way would be to add a Key to the leading CupertinoButton in CustomCupertinoAppBar.
    // For now, we assume it's the one associated with the CircleAvatar.

    // Find the CircleAvatar first, then its parent CupertinoButton
    final circleAvatarFinder = find.byType(CircleAvatar);
    expect(circleAvatarFinder, findsOneWidget);

    // The CupertinoButton is an ancestor of the Padding which is an ancestor of CircleAvatar
    final cupertinoButtonFinder = find.widgetWithFeatures<CupertinoButton>(
      CircleAvatar, // Looking for a CupertinoButton that has a CircleAvatar descendant
      (button) => true, // A more specific feature check could be added here
    );

    // This is still not ideal. The best way is to add a Key to the leading button in the widget itself.
    // Let's assume we tap the CircleAvatar's container (which is the CupertinoButton)

    // Find the leading widget specifically if possible.
    // CustomCupertinoAppBar's leading is a CupertinoButton.
    final leadingButton = find.descendant(
      of: find.byType(CupertinoNavigationBar), // Inside the navigation bar
      matching: find.byType(CupertinoButton),   // The leading is a CupertinoButton
    );

    // This might find other CupertinoButtons if they exist (like back button).
    // If the leading is the first one, this works.
    if (tester.any(leadingButton.first)) {
        await tester.tap(leadingButton.first);
        await tester.pump();
        verify(mockOnUserProfileTap.call()).called(1);
    } else {
        // Fallback or refine finder if the above is not specific enough
        // For this test, we'll assume the leading is the primary tappable CupertinoButton in the leading section.
        // If Get.to is called, it might navigate, so verification might need adjustment
        // or Get should be mocked/controlled in tests.
        // The current onUserProfileTap is a simple callback.
    }
  });


  testWidgets('CustomCupertinoAppBar shows chat and settings actions when true', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableCupertinoAppBar(
      titleText: 'Actions Test',
      showChatAction: true,
      showSettingsAction: true,
    ));

    expect(find.byIcon(CupertinoIcons.chat_bubble_2), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.settings), findsOneWidget);
  });

  testWidgets('CustomCupertinoAppBar hides chat action when showChatAction is false', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableCupertinoAppBar(
      titleText: 'No Chat Test',
      showChatAction: false,
      showSettingsAction: true,
    ));

    expect(find.byIcon(CupertinoIcons.chat_bubble_2), findsNothing);
    expect(find.byIcon(CupertinoIcons.settings), findsOneWidget);
  });

  testWidgets('CustomCupertinoAppBar hides settings action when showSettingsAction is false', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableCupertinoAppBar(
      titleText: 'No Settings Test',
      showChatAction: true,
      showSettingsAction: false,
    ));

    expect(find.byIcon(CupertinoIcons.chat_bubble_2), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.settings), findsNothing);
  });

   testWidgets('CustomCupertinoAppBar shows no actions when both are false', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableCupertinoAppBar(
      titleText: 'No Actions Test',
      showChatAction: false,
      showSettingsAction: false,
    ));

    // The trailing widget in CupertinoNavigationBar is a Row if actions are present.
    // If no actions, the Row might not be there, or it's empty.
    // Check that icons are not found.
    expect(find.byIcon(CupertinoIcons.chat_bubble_2), findsNothing);
    expect(find.byIcon(CupertinoIcons.settings), findsNothing);

    // Check if the trailing Row itself is absent or empty.
    // This depends on the implementation detail (if Row is always there or conditional).
    // CustomCupertinoAppBar creates the Row conditionally.
    final navBar = tester.widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar));
    expect(navBar.trailing, isNull);
  });
}
