import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloudkeja/widgets/filters/property_filters_modal.dart';
import 'package:cloudkeja/models/property_filter_state_model.dart';
import 'package:cloudkeja/config/app_config.dart'; // For kListingCategories and kPropertyTypes

void main() {
  group('PropertyFiltersModal Widget Tests', () {
    // Helper to build the modal and capture its result
    Future<PropertyFilterStateModel?> pumpAndShowModal(
      WidgetTester tester,
      PropertyFilterStateModel initialFilters,
    ) async {
      PropertyFilterStateModel? resultFilters;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  child: const Text('Show Filters'),
                  onPressed: () async {
                    resultFilters = await showModalBottomSheet<PropertyFilterStateModel>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => PropertyFiltersModal(initialFilters: initialFilters),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Filters'));
      await tester.pumpAndSettle(); // Wait for modal to appear and animations to finish.
      return resultFilters; // Will be updated once the modal is popped.
    }

    testWidgets('Initial State: "Any" listing category is selected by default', (WidgetTester tester) async {
      await pumpAndShowModal(tester, PropertyFilterStateModel.initial());

      expect(find.text('Listing Type'), findsOneWidget);

      // Check which ChoiceChip is selected. "Any" should be selected.
      final Finder anyChipFinder = find.widgetWithText(ChoiceChip, 'Any');
      final ChoiceChip anyChipWidget = tester.widget(anyChipFinder);
      expect(anyChipWidget.selected, isTrue, reason: '"Any" chip should be selected initially.');

      final Finder forRentChipFinder = find.widgetWithText(ChoiceChip, 'For Rent');
      final ChoiceChip forRentChipWidget = tester.widget(forRentChipFinder);
      expect(forRentChipWidget.selected, isFalse, reason: '"For Rent" chip should NOT be selected initially.');

      final Finder forSaleChipFinder = find.widgetWithText(ChoiceChip, 'For Sale');
      final ChoiceChip forSaleChipWidget = tester.widget(forSaleChipFinder);
      expect(forSaleChipWidget.selected, isFalse, reason: '"For Sale" chip should NOT be selected initially.');

      // Close the modal (optional, good for cleanup)
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
    });

    testWidgets('Selecting "For Rent" updates selectedListingCategory on Apply', (WidgetTester tester) async {
      PropertyFilterStateModel? poppedFilters;
      final initialFilters = PropertyFilterStateModel.initial();

      // Re-pump widget here to capture poppedFilters in this scope
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  child: const Text('Show Filters'),
                  onPressed: () async {
                    poppedFilters = await showModalBottomSheet<PropertyFilterStateModel>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => PropertyFiltersModal(initialFilters: initialFilters),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Filters'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'For Rent'));
      await tester.pumpAndSettle(); // Allow UI to update for selection

      // Verify 'For Rent' chip is selected
      final ChoiceChip forRentChipWidget = tester.widget(find.widgetWithText(ChoiceChip, 'For Rent'));
      expect(forRentChipWidget.selected, isTrue);
      final ChoiceChip anyChipWidget = tester.widget(find.widgetWithText(ChoiceChip, 'Any'));
      expect(anyChipWidget.selected, isFalse);

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle(); // Modal is dismissed

      expect(poppedFilters, isNotNull);
      expect(poppedFilters!.selectedListingCategory, 'For Rent');
    });

    testWidgets('Selecting "For Sale" updates selectedListingCategory on Apply', (WidgetTester tester) async {
      PropertyFilterStateModel? poppedFilters;
      final initialFilters = PropertyFilterStateModel.initial();
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (BuildContext context) {
        return ElevatedButton(child: const Text('Show Filters'), onPressed: () async {
          poppedFilters = await showModalBottomSheet<PropertyFilterStateModel>(context: context, isScrollControlled: true, builder: (_) => PropertyFiltersModal(initialFilters: initialFilters));
        });
      }))));
      await tester.tap(find.text('Show Filters'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'For Sale'));
      await tester.pumpAndSettle();

      final ChoiceChip forSaleChipWidget = tester.widget(find.widgetWithText(ChoiceChip, 'For Sale'));
      expect(forSaleChipWidget.selected, isTrue);

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(poppedFilters, isNotNull);
      expect(poppedFilters!.selectedListingCategory, 'For Sale');
    });

    testWidgets('Selecting "For Rent" then "Any" results in null selectedListingCategory on Apply', (WidgetTester tester) async {
      PropertyFilterStateModel? poppedFilters;
      final initialFilters = PropertyFilterStateModel.initial();
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (BuildContext context) {
        return ElevatedButton(child: const Text('Show Filters'), onPressed: () async {
          poppedFilters = await showModalBottomSheet<PropertyFilterStateModel>(context: context, isScrollControlled: true, builder: (_) => PropertyFiltersModal(initialFilters: initialFilters));
        });
      }))));
      await tester.tap(find.text('Show Filters'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'For Rent'));
      await tester.pumpAndSettle();
      ChoiceChip forRentChipWidget = tester.widget(find.widgetWithText(ChoiceChip, 'For Rent'));
      expect(forRentChipWidget.selected, isTrue, reason: "For Rent should be selected");


      await tester.tap(find.widgetWithText(ChoiceChip, 'Any'));
      await tester.pumpAndSettle();
      final ChoiceChip anyChipWidget = tester.widget(find.widgetWithText(ChoiceChip, 'Any'));
      expect(anyChipWidget.selected, isTrue, reason: "Any should now be selected");
      forRentChipWidget = tester.widget(find.widgetWithText(ChoiceChip, 'For Rent')); // Re-fetch
      expect(forRentChipWidget.selected, isFalse, reason: "For Rent should be deselected");


      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(poppedFilters, isNotNull);
      expect(poppedFilters!.selectedListingCategory, isNull);
    });

    testWidgets('Reset Button: resets selectedListingCategory to "Any" and clears from popped model', (WidgetTester tester) async {
      PropertyFilterStateModel? poppedFilters;
      // Start with "For Sale" selected
      final initialFilters = PropertyFilterStateModel(selectedListingCategory: 'For Sale');
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (BuildContext context) {
        return ElevatedButton(child: const Text('Show Filters'), onPressed: () async {
          poppedFilters = await showModalBottomSheet<PropertyFilterStateModel>(context: context, isScrollControlled: true, builder: (_) => PropertyFiltersModal(initialFilters: initialFilters));
        });
      }))));
      await tester.tap(find.text('Show Filters'));
      await tester.pumpAndSettle();

      // Verify "For Sale" is initially selected in the modal
      ChoiceChip forSaleChipWidget = tester.widget(find.widgetWithText(ChoiceChip, 'For Sale'));
      expect(forSaleChipWidget.selected, isTrue, reason: "For Sale should be initially selected in modal");

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Verify "Any" is now selected
      final ChoiceChip anyChipWidget = tester.widget(find.widgetWithText(ChoiceChip, 'Any'));
      expect(anyChipWidget.selected, isTrue, reason: "Any should be selected after Reset");
      forSaleChipWidget = tester.widget(find.widgetWithText(ChoiceChip, 'For Sale')); // Re-fetch
      expect(forSaleChipWidget.selected, isFalse, reason: "For Sale should be deselected after Reset");


      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(poppedFilters, isNotNull);
      expect(poppedFilters!.selectedListingCategory, isNull); // Reset to initial default
      expect(poppedFilters!.isDefault, isTrue, reason: "Filters should be default after reset and apply");
    });

    testWidgets('Interaction: sets Listing Type and a Property Type, both applied', (WidgetTester tester) async {
      PropertyFilterStateModel? poppedFilters;
      final initialFilters = PropertyFilterStateModel.initial();
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (BuildContext context) {
        return ElevatedButton(child: const Text('Show Filters'), onPressed: () async {
          poppedFilters = await showModalBottomSheet<PropertyFilterStateModel>(context: context, isScrollControlled: true, builder: (_) => PropertyFiltersModal(initialFilters: initialFilters));
        });
      }))));
      await tester.tap(find.text('Show Filters'));
      await tester.pumpAndSettle();

      // Select "For Sale"
      await tester.tap(find.widgetWithText(ChoiceChip, 'For Sale'));
      await tester.pumpAndSettle();

      // Select a property type (e.g., 'House')
      // Assuming kPropertyTypes includes 'House' and MultiSelectChipField is working
      final String propertyTypeToSelect = kPropertyTypes.contains('House') ? 'House' : kPropertyTypes.first;
      await tester.tap(find.text(propertyTypeToSelect));
      await tester.pumpAndSettle();


      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(poppedFilters, isNotNull);
      expect(poppedFilters!.selectedListingCategory, 'For Sale');
      expect(poppedFilters!.selectedPropertyTypes, contains(propertyTypeToSelect));
    });
  });
}
