import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloudkeja/widgets/custom_cupertino_bottom_navigation_bar.dart';

// Helper to capture onTap calls
class TapCallbackHolder {
  int? lastIndex;
  void call(int index) {
    lastIndex = index;
  }
}

Widget createTestableCupertinoBottomNavBar({
  required int currentIndex,
  required ValueChanged<int> onTap,
}) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      bottomNavigationBar: CustomCupertinoBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
      child: const Center(child: Text('Content')),
    ),
  );
}

void main() {
  testWidgets('CustomCupertinoBottomNavigationBar renders CupertinoTabBar with correct items', (WidgetTester tester) async {
    final tapCallbackHolder = TapCallbackHolder();
    await tester.pumpWidget(createTestableCupertinoBottomNavBar(
      currentIndex: 0,
      onTap: tapCallbackHolder.call,
    ));

    expect(find.byType(CupertinoTabBar), findsOneWidget);

    // Check for the 4 items by their icons (assuming these are the default icons)
    expect(find.byIcon(CupertinoIcons.home), findsOneWidget); // Item 0
    expect(find.byIcon(CupertinoIcons.map), findsOneWidget);    // Item 1 (inactive state icon)
    expect(find.byIcon(CupertinoIcons.bell), findsOneWidget);   // Item 2
    expect(find.byIcon(CupertinoIcons.settings), findsOneWidget); // Item 3

    // Verify number of items based on the internal static list length if possible,
    // or by finding multiple Icon widgets.
    // The CustomCupertinoBottomNavigationBar._tabBarItems has 4 items.
    final tabBar = tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar));
    expect(tabBar.items.length, 4);
  });

  testWidgets('CustomCupertinoBottomNavigationBar calls onTap with correct index', (WidgetTester tester) async {
    final tapCallbackHolder = TapCallbackHolder();
    await tester.pumpWidget(createTestableCupertinoBottomNavBar(
      currentIndex: 0,
      onTap: tapCallbackHolder.call,
    ));

    // Tap on the 'Map' icon (second item, index 1)
    await tester.tap(find.byIcon(CupertinoIcons.map));
    await tester.pump(); // Allow UI to update if needed

    expect(tapCallbackHolder.lastIndex, 1);

    // Tap on the 'Settings' icon (fourth item, index 3)
    await tester.tap(find.byIcon(CupertinoIcons.settings));
    await tester.pump();

    expect(tapCallbackHolder.lastIndex, 3);
  });

  testWidgets('CustomCupertinoBottomNavigationBar applies activeColor to current item', (WidgetTester tester) async {
    const int currentIndex = 1; // Map tab
     await tester.pumpWidget(createTestableCupertinoBottomNavBar(
      currentIndex: currentIndex,
      onTap: (_) {},
    ));

    final tabBar = tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar));
    final cupertinoTheme = CupertinoTheme.of(tester.element(find.byType(CupertinoApp))); // Get theme from context

    // Check activeColor of the TabBar
    expect(tabBar.activeColor, cupertinoTheme.primaryColor);
    expect(tabBar.currentIndex, currentIndex);

    // It's hard to verify the exact color of the icon widget directly without keys or more complex finders.
    // However, we've confirmed the CupertinoTabBar's activeColor property is set
    // and that it respects the currentIndex.
    // The active icon (CupertinoIcons.map_fill) should be used for the current index.
    expect(find.byIcon(CupertinoIcons.map_fill), findsOneWidget); // Active icon for Map
    expect(find.byIcon(CupertinoIcons.home), findsOneWidget); // Inactive icon for Home
  });

  testWidgets('CustomCupertinoBottomNavigationBar applies inactiveColor to other items', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableCupertinoBottomNavBar(
      currentIndex: 0, // Home is active
      onTap: (_) {},
    ));

    final tabBar = tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar));

    // Check inactiveColor of the TabBar
    expect(tabBar.inactiveColor, CupertinoColors.inactiveGray);

    // The 'Map' icon (index 1) should be inactive
    // It's hard to check the color of the Icon widget itself easily.
    // We trust that CupertinoTabBar uses its inactiveColor property correctly.
    // We can check that the non-active icons are the non-_fill versions
    expect(find.byIcon(CupertinoIcons.map), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.bell), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.settings), findsOneWidget);

    // Active icon for Home should be present
    expect(find.byIcon(CupertinoIcons.house_fill), findsOneWidget);
  });
}
