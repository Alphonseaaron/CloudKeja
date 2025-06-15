import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloudkeja/helpers/my_ratings.dart';
import 'package:cloudkeja/services/platform_service.dart';

class MockPlatformService extends Mock implements PlatformService {}

Widget createRatingsTestWidget({
  required double rating,
  required MockPlatformService mockPlatformService,
  required bool useCupertinoApp, // To decide wrapper
}) {
  Widget child = Ratings(rating: rating);
  Widget appWrapper;

  if (useCupertinoApp) {
    appWrapper = CupertinoApp(
      home: CupertinoPageScaffold(body: child),
      // Need theme for primaryColor if Cupertino is active
      theme: const CupertinoThemeData(primaryColor: CupertinoColors.systemBlue),
    );
  } else {
    appWrapper = MaterialApp(
      home: Scaffold(body: child),
      // Need theme for Colors.amber if Material is active
      theme: ThemeData(primarySwatch: Colors.amber),
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

  testWidgets('Ratings widget uses Material icons and colors when useCupertino is false', (WidgetTester tester) async {
    when(mockPlatformService.useCupertino).thenReturn(false);

    await tester.pumpWidget(createRatingsTestWidget(
      rating: 3.5,
      mockPlatformService: mockPlatformService,
      useCupertinoApp: false,
    ));

    final ratingBar = tester.widget<RatingBar>(find.byType(RatingBar));
    final ratingWidget = ratingBar.ratingWidget;

    // Check icon types and colors by finding them
    // This is a bit indirect. A more robust way would be to inspect the IconData and color of the widgets.
    expect(find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.star && widget.color == Colors.amber), findsOneWidget); // Finds 'full'
    expect(find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.star_half && widget.color == Colors.amber), findsOneWidget); // Finds 'half'
    expect(find.byWidgetPredicate((widget) => widget is Icon && widget.icon == Icons.star_border && widget.color == Colors.amber), findsOneWidget); // Finds 'empty'

    // Verify RatingWidget properties directly
    expect((ratingWidget.full as Icon).icon, Icons.star);
    expect((ratingWidget.full as Icon).color, Colors.amber);
    expect((ratingWidget.half as Icon).icon, Icons.star_half);
    expect((ratingWidget.half as Icon).color, Colors.amber);
    expect((ratingWidget.empty as Icon).icon, Icons.star_border);
    expect((ratingWidget.empty as Icon).color, Colors.amber);
  });

  testWidgets('Ratings widget uses Cupertino icons and colors when useCupertino is true', (WidgetTester tester) async {
    when(mockPlatformService.useCupertino).thenReturn(true);

    await tester.pumpWidget(createRatingsTestWidget(
      rating: 3.5,
      mockPlatformService: mockPlatformService,
      useCupertinoApp: true,
    ));

    final ratingBar = tester.widget<RatingBar>(find.byType(RatingBar));
    final ratingWidget = ratingBar.ratingWidget;

    // Get the primary color from the CupertinoTheme used in the test wrapper
    final cupertinoPrimaryColor = CupertinoTheme.of(tester.element(find.byType(Ratings))).primaryColor;


    // Verify RatingWidget properties directly
    expect((ratingWidget.full as Icon).icon, CupertinoIcons.star_fill);
    expect((ratingWidget.full as Icon).color, cupertinoPrimaryColor);
    expect((ratingWidget.half as Icon).icon, CupertinoIcons.star_lefthalf_fill);
    expect((ratingWidget.half as Icon).color, cupertinoPrimaryColor);
    expect((ratingWidget.empty as Icon).icon, CupertinoIcons.star);
    // The empty star in Ratings widget implementation uses primaryColor.withOpacity(0.4)
    expect((ratingWidget.empty as Icon).color, cupertinoPrimaryColor.withOpacity(0.4));

    // Also check by finding (less direct, but good for confirmation)
    expect(find.byWidgetPredicate((widget) => widget is Icon && widget.icon == CupertinoIcons.star_fill && widget.color == cupertinoPrimaryColor), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is Icon && widget.icon == CupertinoIcons.star_lefthalf_fill && widget.color == cupertinoPrimaryColor), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is Icon && widget.icon == CupertinoIcons.star && widget.color == cupertinoPrimaryColor.withOpacity(0.4)), findsOneWidget);
  });
}
