import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart'; // For PlatformService if used by underlying MyDropDown
import 'package:cloudkeja/services/platform_service.dart'; // For PlatformService if used
import 'package:cloudkeja/widgets/forms/multi_select_chip_field_cupertino.dart';
// Import the page directly for testing, assuming it can be made public or tested via a helper
import 'package:cloudkeja/widgets/forms/_cupertino_multi_select_page_route.dart';
import 'package:get/get.dart'; // MultiSelectChipFieldCupertino uses Navigator.of(context).push

// --- Mock PlatformService ---
class MockPlatformService extends Mock implements PlatformService {}

// --- Testable version of _CupertinoMultiSelectPage ---
// In a real scenario, you'd make _CupertinoMultiSelectPage public or have a testing strategy.
// For this tool, we define a public version here.
class TestableCupertinoMultiSelectPage extends StatefulWidget {
  final List<String> allOptions;
  final List<String> initiallySelectedOptions;
  final String pageTitle;

  const TestableCupertinoMultiSelectPage({
    Key? key,
    required this.allOptions,
    required this.initiallySelectedOptions,
    required this.pageTitle,
  }) : super(key: key);

  @override
  _TestableCupertinoMultiSelectPageState createState() => _TestableCupertinoMultiSelectPageState();
}

class _TestableCupertinoMultiSelectPageState extends State<TestableCupertinoMultiSelectPage> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List<String>.from(widget.initiallySelectedOptions);
  }

  void _toggleSelection(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.pageTitle),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Done'),
          onPressed: () => Navigator.of(context).pop(_selectedOptions),
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: widget.allOptions.length,
          itemBuilder: (context, index) {
            final option = widget.allOptions[index];
            final bool isSelected = _selectedOptions.contains(option);
            return CupertinoListTile(
              title: Text(option),
              onTap: () => _toggleSelection(option),
              trailing: isSelected ? Icon(CupertinoIcons.check_mark, color: CupertinoTheme.of(context).primaryColor) : null,
            );
          },
        ),
      ),
    );
  }
}


// --- Test Setup ---
Widget createMultiSelectChipFieldTestableWidget({
  required List<String> allOptions,
  required List<String> initialSelectedOptions,
  required Function(List<String>) onSelectionChanged,
  String? title,
  MockPlatformService? mockPlatformService,
}) {
  final platformService = mockPlatformService ?? MockPlatformService();
  when(platformService.useCupertino).thenReturn(true); // Ensure it uses Cupertino path for MyDropDown

  return Provider<PlatformService>.value(
    value: platformService,
    child: GetMaterialApp( // For Navigator.push used by MultiSelectChipFieldCupertino
        home: CupertinoApp(
        home: CupertinoPageScaffold(
          child: MultiSelectChipFieldCupertino(
            allOptions: allOptions,
            initialSelectedOptions: initialSelectedOptions,
            onSelectionChanged: onSelectionChanged,
            title: title,
          ),
        ),
      ),
    ),
  );
}

Widget createMultiSelectPageTestableWidget({
  required List<String> allOptions,
  required List<String> initialSelectedOptions,
  required String pageTitle,
}) {
  return CupertinoApp(
    home: TestableCupertinoMultiSelectPage(
      allOptions: allOptions,
      initialSelectedOptions: initialSelectedOptions,
      pageTitle: pageTitle,
    ),
  );
}


void main() {
  late MockPlatformService mockPlatformService;

  setUp(() {
    mockPlatformService = MockPlatformService();
    when(mockPlatformService.useCupertino).thenReturn(true);
  });

  group('MultiSelectChipFieldCupertino', () {
    final List<String> options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

    testWidgets('displays title and initial selection summary', (WidgetTester tester) async {
      await tester.pumpWidget(createMultiSelectChipFieldTestableWidget(
        allOptions: options,
        initialSelectedOptions: ['Option 1', 'Option 3'],
        onSelectionChanged: (_) {},
        title: 'Select Items',
        mockPlatformService: mockPlatformService,
      ));

      expect(find.text('Select Items'), findsOneWidget);
      expect(find.text('2 items selected'), findsOneWidget); // Or "Option 1, Option 3" based on implementation
    });

    testWidgets('displays "None selected" when initial selection is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createMultiSelectChipFieldTestableWidget(
        allOptions: options,
        initialSelectedOptions: [],
        onSelectionChanged: (_) {},
        title: 'Select Items',
        mockPlatformService: mockPlatformService,
      ));
      expect(find.text('None selected'), findsOneWidget);
    });

    testWidgets('tapping the field navigates to selection page', (WidgetTester tester) async {
      // Mock navigator
      final mockObserver = MockNavigatorObserver();
       Get.testMode = true; // Enable Get test mode for Get.to if used internally

      await tester.pumpWidget(
         Provider<PlatformService>.value(
          value: mockPlatformService,
          child: GetMaterialApp( // MultiSelectChipFieldCupertino uses Navigator.of(context).push
            home: CupertinoApp(
              home: CupertinoPageScaffold(
                child: MultiSelectChipFieldCupertino(
                  allOptions: options,
                  initialSelectedOptions: [],
                  onSelectionChanged: (_) {},
                  title: 'Test Title',
                ),
              ),
            ),
            navigatorObservers: [mockObserver],
          ),
        )
      );

      await tester.tap(find.byType(GestureDetector).first); // Tap the field
      await tester.pumpAndSettle(); // Wait for navigation

      // Verify that a new route was pushed.
      // _CupertinoMultiSelectPage is pushed by MultiSelectChipFieldCupertino
      // We can't directly find _CupertinoMultiSelectPage due to its private name.
      // So we check if *any* new route was pushed.
      verify(mockObserver.didPush(any, any));
      // And that the title of the new page is what we expect
      expect(find.text('Test Title'), findsOneWidget); // This is the page title of the selection page
    });
  });

  group('_CupertinoMultiSelectPage (via TestableCupertinoMultiSelectPage)', () {
    final List<String> options = ['Apple', 'Banana', 'Cherry', 'Date'];

    testWidgets('displays title, options, and Done button', (WidgetTester tester) async {
      await tester.pumpWidget(createMultiSelectPageTestableWidget(
        allOptions: options,
        initialSelectedOptions: ['Apple', 'Date'],
        pageTitle: 'Choose Fruits',
      ));

      expect(find.text('Choose Fruits'), findsOneWidget); // Nav bar title
      expect(find.text('Done'), findsOneWidget); // Nav bar trailing
      for (final option in options) {
        expect(find.text(option), findsOneWidget);
      }
    });

    testWidgets('shows checkmarks for initially selected items', (WidgetTester tester) async {
      await tester.pumpWidget(createMultiSelectPageTestableWidget(
        allOptions: options,
        initialSelectedOptions: ['Banana', 'Cherry'],
        pageTitle: 'Fruits',
      ));

      // Check Banana
      WidgetPredicate bananaCheck = (Widget widget) => widget is Icon && widget.icon == CupertinoIcons.check_mark;
      expect(find.descendant(of: find.widgetWithText(CupertinoListTile, 'Banana'), matching: bananaCheck), findsOneWidget);
      // Check Cherry
      expect(find.descendant(of: find.widgetWithText(CupertinoListTile, 'Cherry'), matching: bananaCheck), findsOneWidget);
      // Check Apple (not selected)
      expect(find.descendant(of: find.widgetWithText(CupertinoListTile, 'Apple'), matching: bananaCheck), findsNothing);
    });

    testWidgets('toggles selection and checkmark on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createMultiSelectPageTestableWidget(
        allOptions: options,
        initialSelectedOptions: ['Apple'],
        pageTitle: 'Fruits',
      ));

      WidgetPredicate checkMark = (Widget widget) => widget is Icon && widget.icon == CupertinoIcons.check_mark;
      // Initially Apple is selected
      expect(find.descendant(of: find.widgetWithText(CupertinoListTile, 'Apple'), matching: checkMark), findsOneWidget);
      // Banana is not selected
      expect(find.descendant(of: find.widgetWithText(CupertinoListTile, 'Banana'), matching: checkMark), findsNothing);

      // Tap Banana
      await tester.tap(find.text('Banana'));
      await tester.pump();
      // Now Banana should be selected
      expect(find.descendant(of: find.widgetWithText(CupertinoListTile, 'Banana'), matching: checkMark), findsOneWidget);

      // Tap Apple (to deselect)
      await tester.tap(find.text('Apple'));
      await tester.pump();
      // Now Apple should not be selected
      expect(find.descendant(of: find.widgetWithText(CupertinoListTile, 'Apple'), matching: checkMark), findsNothing);
    });

    testWidgets('Done button pops with selected items', (WidgetTester tester) async {
      List<String>? result;
      await tester.pumpWidget(CupertinoApp(
        home: Builder(builder: (context) {
          return CupertinoButton(
            child: const Text('Open Selector'),
            onPressed: () async {
              result = await Navigator.of(context).push<List<String>>(
                CupertinoPageRoute(builder: (_) => TestableCupertinoMultiSelectPage(
                  allOptions: options,
                  initialSelectedOptions: ['Apple'],
                  pageTitle: 'Fruits',
                )),
              );
            },
          );
        }),
      ));

      await tester.tap(find.text('Open Selector'));
      await tester.pumpAndSettle(); // Open the page

      // On the selection page, deselect Apple, select Banana and Cherry
      await tester.tap(find.text('Apple')); // Deselect
      await tester.tap(find.text('Banana')); // Select
      await tester.tap(find.text('Cherry')); // Select
      await tester.pump();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle(); // Close the page

      expect(result, isNotNull);
      expect(result, unorderedEquals(['Banana', 'Cherry']));
    });
  });
}

// Mock NavigatorObserver to verify navigation events
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
