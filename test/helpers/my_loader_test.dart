import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/my_loader.dart';
import 'package:cloudkeja/services/platform_service.dart';

class MockPlatformService extends Mock implements PlatformService {}

Widget createLoaderTestWidget({
  required MockPlatformService mockPlatformService,
  required bool useCupertinoApp,
}) {
  Widget child = const MyLoader(); // MyLoader is the widget under test
  Widget appWrapper;

  if (useCupertinoApp) {
    appWrapper = CupertinoApp(
      home: CupertinoPageScaffold(body: Center(child: child)),
      // Optional: Add theme if MyLoader's CupertinoActivityIndicator was themed explicitly
      // theme: const CupertinoThemeData(primaryColor: CupertinoColors.systemGreen),
    );
  } else {
    appWrapper = MaterialApp(
      home: Scaffold(body: Center(child: child)),
      // Optional: Add theme if MyLoader's CircularProgressIndicator was themed explicitly
      // theme: ThemeData(progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.blue)),
    );
  }

  return ChangeNotifierProvider<PlatformService>.value(
    value: mockPlatformService,
    child: appWrapper,
  );
}

void main() {
  late MockPlatformService mockPlatformService;

  setUp(() {
    mockPlatformService = MockPlatformService();
  });

  testWidgets('MyLoader renders CircularProgressIndicator when useCupertino is false', (WidgetTester tester) async {
    when(mockPlatformService.useCupertino).thenReturn(false);

    await tester.pumpWidget(createLoaderTestWidget(
      mockPlatformService: mockPlatformService,
      useCupertinoApp: false,
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('MyLoader renders CupertinoActivityIndicator when useCupertino is true', (WidgetTester tester) async {
    when(mockPlatformService.useCupertino).thenReturn(true);

    await tester.pumpWidget(createLoaderTestWidget(
      mockPlatformService: mockPlatformService,
      useCupertinoApp: true,
    ));

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // Optional: Test for color if MyLoader was updated to explicitly set colors
  // testWidgets('MyLoader applies theme color for Material CircularProgressIndicator', (WidgetTester tester) async {
  //   when(mockPlatformService.useCupertino).thenReturn(false);
  //   const testColor = Colors.red;

  //   await tester.pumpWidget(
  //     ChangeNotifierProvider<PlatformService>.value(
  //       value: mockPlatformService,
  //       child: MaterialApp(
  //         theme: ThemeData(progressIndicatorTheme: ProgressIndicatorThemeData(color: testColor)),
  //         home: const Scaffold(body: Center(child: MyLoader())),
  //       ),
  //     ),
  //   );

  //   final indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
  //   // This assumes MyLoader is modified to use Theme.of(context).progressIndicatorTheme.color
  //   // If MyLoader uses Theme.of(context).colorScheme.primary, test that instead.
  //   // The current MyLoader implementation does not explicitly set color, so it uses defaults.
  //   // expect(indicator.valueColor, isA<Animation<Color?>>()); // Default color is an animation.
  //   // To test specific color, MyLoader must be changed or this test needs to check default theme color.
  // });

  // testWidgets('MyLoader applies theme color for CupertinoActivityIndicator', (WidgetTester tester) async {
  //   when(mockPlatformService.useCupertino).thenReturn(true);
  //   const testColor = CupertinoColors.activeGreen;

  //   await tester.pumpWidget(
  //     ChangeNotifierProvider<PlatformService>.value(
  //       value: mockPlatformService,
  //       child: CupertinoApp(
  //         theme: const CupertinoThemeData(primaryColor: testColor), // Assuming indicator uses primaryColor
  //         home: const CupertinoPageScaffold(child: Center(child: MyLoader())),
  //       ),
  //     ),
  //   );

  //   final indicator = tester.widget<CupertinoActivityIndicator>(find.byType(CupertinoActivityIndicator));
  //   // Default CupertinoActivityIndicator color is based on brightness.
  //   // If MyLoader was changed to explicitly use `CupertinoTheme.of(context).primaryColor`,
  //   // then we could check for `testColor`.
  //   // expect(indicator.color, testColor); // This would only pass if MyLoader explicitly sets it.
  // });
}
