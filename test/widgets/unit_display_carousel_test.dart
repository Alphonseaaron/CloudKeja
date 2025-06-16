import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/widgets/unit_display_carousel.dart';
import 'package:mocktail/mocktail.dart';

// Mock PostProvider using mocktail
class MockPostProvider extends Mock implements PostProvider {}

// Helper function to pump the UnitDisplayCarousel widget
Future<void> pumpUnitDisplayCarousel(
  WidgetTester tester, {
  required List<Map<String, dynamic>> units,
  required bool isOwner,
  required String spaceId,
  PostProvider? postProvider,
}) async {
  final effectivePostProvider = postProvider ?? MockPostProvider();
  if (postProvider == null) {
      when(() => effectivePostProvider.addUnitToSpace(any(), any())).thenAnswer((_) async {});
      when(() => effectivePostProvider.updateUnitInSpace(any(), any(), any())).thenAnswer((_) async {});
      when(() => effectivePostProvider.deleteUnitFromSpace(any(), any())).thenAnswer((_) async {});
  }

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PostProvider>.value(
          value: effectivePostProvider,
        ),
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
  final sampleUnitsFloor1 = [
    {'unitId': 'f1u1', 'floor': 1, 'unitNumber': 'A101', 'status': kUnitStatusVacant},
    {'unitId': 'f1u2', 'floor': 1, 'unitNumber': 'A102', 'status': kUnitStatusOccupied},
  ];
  final sampleUnitsFloor2 = [
    {'unitId': 'f2u1', 'floor': 2, 'unitNumber': 'B201', 'status': kUnitStatusPending},
  ];
  final allSampleUnits = [...sampleUnitsFloor1, ...sampleUnitsFloor2];

  late MockPostProvider mockPostProvider;

  setUp(() {
    mockPostProvider = MockPostProvider();
    when(() => mockPostProvider.addUnitToSpace(any(), any())).thenAnswer((_) async {});
    when(() => mockPostProvider.updateUnitInSpace(any(), any(), any())).thenAnswer((_) async {});
    when(() => mockPostProvider.deleteUnitFromSpace(any(), any())).thenAnswer((_) async {});
  });

  group('UnitDisplayCarousel Widget Tests', () {
    testWidgets('Empty State: displays correctly when units list is empty', (WidgetTester tester) async {
      await pumpUnitDisplayCarousel(tester, units: [], isOwner: false, spaceId: 's1', postProvider: mockPostProvider);
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('Basic Display: renders floors and units correctly', (WidgetTester tester) async {
      await pumpUnitDisplayCarousel(tester, units: allSampleUnits, isOwner: false, spaceId: 's1', postProvider: mockPostProvider);
      expect(find.text('Floor 1'), findsOneWidget);
      expect(find.text('A101 (Vacant)'), findsOneWidget);
      expect(find.text('A102 (Occupied)'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(3));
      expect(find.text('Floor 2'), findsOneWidget);
      expect(find.text('B201 (Pending Move-out)'), findsOneWidget);
    });

    group('Delete Functionality (Owner View)', () {
      final testSpaceId = 'spaceDeleteTest';
      final testUnit = {'unitId': 'del_u1', 'floor': 1, 'unitNumber': 'D101', 'status': 'vacant'};
      final List<Map<String, dynamic>> unitsForDeleteTest = [testUnit];

      testWidgets('Delete button appears in Edit Unit dialog and opens confirmation', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(
          tester,
          units: unitsForDeleteTest,
          isOwner: true,
          spaceId: testSpaceId,
          postProvider: mockPostProvider,
        );

        await tester.tap(find.widgetWithText(Chip, 'D101 (Vacant)'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Unit'), findsOneWidget);
        final deleteButtonFinder = find.widgetWithText(TextButton, 'Delete');
        expect(deleteButtonFinder, findsOneWidget);

        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Confirm Delete'), findsOneWidget);
        expect(find.text('Are you sure you want to delete unit "D101"? This cannot be undone.'), findsOneWidget);

        await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
        await tester.pumpAndSettle();

        expect(find.text('Confirm Delete'), findsNothing);
        expect(find.text('Edit Unit'), findsOneWidget);
      });

      testWidgets('Full delete flow: calls provider, closes dialogs, shows SnackBar', (WidgetTester tester) async {
        when(() => mockPostProvider.deleteUnitFromSpace(testSpaceId, 'del_u1')).thenAnswer((_) async {});

        await pumpUnitDisplayCarousel(
          tester,
          units: unitsForDeleteTest,
          isOwner: true,
          spaceId: testSpaceId,
          postProvider: mockPostProvider,
        );

        await tester.tap(find.widgetWithText(Chip, 'D101 (Vacant)'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
        await tester.pumpAndSettle();

        verify(() => mockPostProvider.deleteUnitFromSpace(testSpaceId, 'del_u1')).called(1);
        expect(find.text('Confirm Delete'), findsNothing);
        expect(find.text('Edit Unit'), findsNothing);

        expect(find.text('Unit "D101" deleted successfully.'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3)); // Wait for SnackBar to clear
        await tester.pumpAndSettle();
      });

      testWidgets('Delete button is NOT present in Add Unit dialog', (WidgetTester tester) async {
        final List<Map<String, dynamic>> unitsWithOneFloor = [
          {'unitId': 'temp', 'floor': 1, 'unitNumber': 'Temp', 'status': 'vacant'}
        ];
        await pumpUnitDisplayCarousel(
          tester,
          units: unitsWithOneFloor,
          isOwner: true,
          spaceId: testSpaceId,
          postProvider: mockPostProvider,
        );

        await tester.tap(find.widgetWithText(TextButton, 'Add Unit'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Add New Unit to Floor 1'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Delete'), findsNothing);
      });

      testWidgets('Shows error SnackBar if deleteUnitFromSpace fails', (WidgetTester tester) async {
        when(() => mockPostProvider.deleteUnitFromSpace(testSpaceId, 'del_u1')).thenThrow(Exception('Firestore error'));

        await pumpUnitDisplayCarousel(
          tester,
          units: unitsForDeleteTest,
          isOwner: true,
          spaceId: testSpaceId,
          postProvider: mockPostProvider,
        );

        await tester.tap(find.widgetWithText(Chip, 'D101 (Vacant)'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
        await tester.pumpAndSettle();

        verify(() => mockPostProvider.deleteUnitFromSpace(testSpaceId, 'del_u1')).called(1);
        expect(find.text('Confirm Delete'), findsNothing);

        expect(find.text('Error deleting unit: Exception: Firestore error'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      });
    });

    group('Tenant View Interactions', () {
        testWidgets('tapping "Vacant" unit shows booking SnackBar', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(tester, units: sampleUnitsFloor1, isOwner: false, spaceId: 's1', postProvider: mockPostProvider);

        await tester.tap(find.text('A101 (Vacant)'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Initiating booking process for Unit A101... (Placeholder)'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        expect(find.text('Initiating booking process for Unit A101... (Placeholder)'), findsNothing);
      });

      testWidgets('tapping "Occupied" unit shows occupied SnackBar', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(tester, units: sampleUnitsFloor1, isOwner: false, spaceId: 's1', postProvider: mockPostProvider);

        await tester.tap(find.text('A102 (Occupied)'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Unit A102 is currently occupied.'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
      });

      testWidgets('tapping "Pending Move-out" unit shows pending SnackBar', (WidgetTester tester) async {
        await pumpUnitDisplayCarousel(tester, units: sampleUnitsFloor2, isOwner: false, spaceId: 's1', postProvider: mockPostProvider);

        await tester.tap(find.text('B201 (Pending Move-out)'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Unit B201 is pending move-out. Check back soon!'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
      });
    });
  });
}
