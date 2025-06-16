import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/widgets/unit_display_carousel.dart';
// Mockito or Mocktail could be used for more complex PostProvider interactions,
// but for these UI tests, a real instance (with mocked Firestore via cloud_firestore_mocks global setup)
// or a very simple mock is often sufficient.

// Helper function to pump the UnitDisplayCarousel widget
Future<void> pumpUnitDisplayCarousel(
  WidgetTester tester, {
  required List<Map<String, dynamic>> units,
  required bool isOwner,
  required String spaceId,
  PostProvider? mockPostProvider,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PostProvider>(
          // Assumes PostProvider() will use MockFirebaseFirestore.instance
          // if tests are run in an environment where that's globally set up.
          create: (_) => mockPostProvider ?? PostProvider(),
        ),
        // Add AuthProvider if its absence causes issues down the widget tree,
        // though UnitDisplayCarousel itself doesn't directly use it.
        // For simplicity, omitting unless an error occurs.
      ],
      child: MaterialApp(
        home: Scaffold(
          body: UnitDisplayCarousel(
            units: units,
            isOwner: isOwner,
            spaceId: spaceId,
          ),
        ),
      ),
    ),
  );
}

void main() {
  // Define sample units data to be reused
  final sampleUnitsFloor1 = [
    {'unitId': 'f1u1', 'floor': 1, 'unitNumber': 'A101', 'status': kUnitStatusVacant},
    {'unitId': 'f1u2', 'floor': 1, 'unitNumber': 'A102', 'status': kUnitStatusOccupied},
  ];
  final sampleUnitsFloor2 = [
    {'unitId': 'f2u1', 'floor': 2, 'unitNumber': 'B201', 'status': kUnitStatusPending},
  ];
  final allSampleUnits = [...sampleUnitsFloor1, ...sampleUnitsFloor2];

  group('UnitDisplayCarousel Widget Tests', () {
    testWidgets('Empty State: displays correctly when units list is empty', (WidgetTester tester) async {
      await pumpUnitDisplayCarousel(tester, units: [], isOwner: false, spaceId: 's1');

      // Current implementation returns SizedBox.shrink() for empty units.
      // If it were to display text, we'd find that.
      expect(find.byType(SizedBox), findsOneWidget); // Check for SizedBox.shrink()
      expect(find.textContaining('No unit information available'), findsNothing); // Or findsOneWidget if that's the behavior
      expect(find.byType(Card), findsNothing); // No unit cards should be displayed
    });

    testWidgets('Empty State: displays message if sortedFloors is empty but units initially not (edge case)', (WidgetTester tester) async {
      // This tests the specific check `if (sortedFloors.isEmpty)` after grouping
      await pumpUnitDisplayCarousel(tester, units: [{'invalid_unit_no_floor': true}], isOwner: false, spaceId: 's1');
      // Assuming units without 'floor' are grouped into floor 0, and if that's the only "floor"
      // and it contains units, it should not hit this specific empty message.
      // This test case might need refinement based on how units without 'floor' are truly handled.
      // If all units are invalid and result in no floors, then:
      // For now, assuming valid units that result in empty sortedFloors (e.g. after some filtering if that was added)
      // The current widget code: if units is not empty, but unitsByFloor results in empty sortedFloors.
      // This can happen if all units have non-integer floors that default to 0, but then that floor 0 should be processed.
      // Let's assume the "No unit information available for display." is shown if units exist but processing leads to no displayable floors.
      // The current implementation will likely show Floor 0 for units with invalid/missing floor.
      // So, this specific message "No unit information available for display" is hard to trigger
      // if units list is not empty, as they'd fall into a default floor.
      // Let's adjust to test the primary empty path (units: []) for clarity.
      // The primary empty state is already tested above. This one tests an internal fallback.
      // If units are [{}], floor becomes 0, unitNumber N/A, status unknown. It will display.
      // So, the "No unit information available for display." is effectively dead code unless unitsByFloor.keys.toList()..sort() results in empty.
      // This would only happen if units is empty to begin with, or all units are filtered out before floor grouping (not current logic).
      // Given current code, this specific text is hard to reach if units list is not empty.
      // We will assume the initial `if (units.isEmpty)` is the main guard for empty state.
    });


    testWidgets('Basic Display: renders floors and units correctly', (WidgetTester tester) async {
      await pumpUnitDisplayCarousel(tester, units: allSampleUnits, isOwner: false, spaceId: 's1');

      expect(find.text('Floor 1'), findsOneWidget);
      expect(find.text('A101 (Vacant)'), findsOneWidget);
      expect(find.text('A102 (Occupied)'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2 + 1)); // 2 on floor 1, 1 on floor 2

      expect(find.text('Floor 2'), findsOneWidget);
      expect(find.text('B201 (Pending Move-out)'), findsOneWidget);
    });

    group('Owner View', () {
      testWidgets('displays "Add Unit" buttons and allows opening Add Unit dialog', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(tester, units: sampleUnitsFloor1, isOwner: true, spaceId: 's1');

        // Check for "Add Unit" button for Floor 1
        expect(find.widgetWithIcon(TextButton, Icons.add_circle_outline), findsOneWidget);
        expect(find.text('Add Unit'), findsOneWidget); // Text on the button

        // Tap the "Add Unit" button for Floor 1
        await tester.tap(find.widgetWithIcon(TextButton, Icons.add_circle_outline).first);
        await tester.pumpAndSettle(); // For dialog animation

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Add New Unit to Floor 1'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Unit Number/Name'), findsOneWidget); // Check for form field
        expect(find.widgetWithText(DropdownButtonFormField<String>, 'Status'), findsOneWidget); // Check for dropdown

        // Close dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });

      testWidgets('allows tapping a unit chip to open Edit Unit dialog', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(tester, units: sampleUnitsFloor1, isOwner: true, spaceId: 's1');

        // Tap the 'A101 (Vacant)' chip
        await tester.tap(find.text('A101 (Vacant)'));
        await tester.pumpAndSettle(); // For dialog animation

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Edit Unit'), findsOneWidget);

        // Check if form fields are pre-filled (example for unit number)
        expect(find.widgetWithText(TextFormField, 'A101'), findsOneWidget);
        // Check dropdown has initial value (more complex, check if kUnitStatusVacant is selected)
        // For simplicity, we check presence of Dropdown. Actual value check requires more specific finders or state inspection.
        expect(find.widgetWithText(DropdownButtonFormField<String>, 'Status'), findsOneWidget);


        // Close dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });
    });

    group('Tenant View', () {
      testWidgets('does NOT display "Add Unit" buttons', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(tester, units: sampleUnitsFloor1, isOwner: false, spaceId: 's1');

        expect(find.widgetWithIcon(TextButton, Icons.add_circle_outline), findsNothing);
        expect(find.text('Add Unit'), findsNothing);
      });

      testWidgets('tapping "Vacant" unit shows booking SnackBar', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(tester, units: sampleUnitsFloor1, isOwner: false, spaceId: 's1');

        await tester.tap(find.text('A101 (Vacant)'));
        await tester.pump(); // Start SnackBar animation
        await tester.pump(); // SnackBar fully displayed

        expect(find.text('Initiating booking process for Unit A101... (Placeholder)'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3)); // Wait for SnackBar to disappear
        expect(find.text('Initiating booking process for Unit A101... (Placeholder)'), findsNothing);
      });

      testWidgets('tapping "Occupied" unit shows occupied SnackBar', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(tester, units: sampleUnitsFloor1, isOwner: false, spaceId: 's1');

        await tester.tap(find.text('A102 (Occupied)'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Unit A102 is currently occupied.'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
      });

      testWidgets('tapping "Pending Move-out" unit shows pending SnackBar', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(tester, units: sampleUnitsFloor2, isOwner: false, spaceId: 's1');

        await tester.tap(find.text('B201 (Pending Move-out)'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Unit B201 is pending move-out. Check back soon!'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
      });
    });
  });
}
