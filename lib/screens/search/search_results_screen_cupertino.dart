import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For Hero, Material used for transition
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/property_filter_state_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/search/property_filters_screen_cupertino.dart';
import 'package:cloudkeja/screens/search/search_screen_router.dart'; // Router to navigate back
import 'package:cloudkeja/widgets/space_tile.dart'; // Adaptive router
import 'package:intl/intl.dart'; // For currency formatting
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';
import 'package:get/route_manager.dart'; // For Get.off

class SearchResultsScreenCupertino extends StatefulWidget {
  final String searchText;

  const SearchResultsScreenCupertino({
    Key? key,
    required this.searchText,
  }) : super(key: key);

  @override
  State<SearchResultsScreenCupertino> createState() => _SearchResultsScreenCupertinoState();
}

class _SearchResultsScreenCupertinoState extends State<SearchResultsScreenCupertino> {
  PropertyFilterStateModel _activeFilters = PropertyFilterStateModel.initial();
  late Future<List<SpaceModel>> _searchResultsFuture;
  final GlobalKey _filterButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        WalkthroughService.startShowcaseIfNeeded(
          context: context,
          walkthroughKey: 'tenantPropertySearchFilters_v1_cupertino', // Cupertino specific key
          showcaseGlobalKeys: [_filterButtonKey],
        );
      }
    });
  }

  void _fetchSearchResults() {
    print('Fetching Cupertino search results for: "${widget.searchText}" with filters: ${_activeFilters.toString()}');
    if (mounted) {
      setState(() {
        _searchResultsFuture = Provider.of<PostProvider>(context, listen: false)
            .searchSpaces(widget.searchText /*, filters: _activeFilters */); // TODO: Pass filters
      });
    }
  }

  String _formatPriceCupertino(double value, BuildContext context) {
    if (value >= PropertyFilterStateModel.maxPriceRange) return 'KES ${NumberFormat.compactCurrency(locale: 'en_US', symbol: '', decimalDigits: 0).format(PropertyFilterStateModel.maxPriceRange)}+';
    return 'KES ${NumberFormat.compactCurrency(locale: 'en_US', symbol: '', decimalDigits: 0).format(value)}';
  }

  Widget _buildCupertinoActiveFiltersSummary(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final List<Widget> filterButtons = [];

    if (_activeFilters.priceRange != null &&
        (_activeFilters.priceRange!.start > PropertyFilterStateModel.minPriceRange || _activeFilters.priceRange!.end < PropertyFilterStateModel.maxPriceRange )) {
      filterButtons.add(_buildFilterChipButton(context, '${_formatPriceCupertino(_activeFilters.priceRange!.start, context)} - ${_formatPriceCupertino(_activeFilters.priceRange!.end, context)}', () => setState(() { _activeFilters = _activeFilters.copyWith(clearPriceRange: true); _fetchSearchResults(); })));
    }
    for (String type in _activeFilters.selectedPropertyTypes) {
      filterButtons.add(_buildFilterChipButton(context, type, () => setState(() { _activeFilters = _activeFilters.copyWith(selectedPropertyTypes: List.from(_activeFilters.selectedPropertyTypes)..remove(type)); _fetchSearchResults(); })));
    }
    if (_activeFilters.selectedBedrooms != null && _activeFilters.selectedBedrooms! > 0) {
      String bedLabel = _activeFilters.selectedBedrooms == PropertyFilterStateModel.maxBedrooms ? '${PropertyFilterStateModel.maxBedrooms}+ Beds' : '${_activeFilters.selectedBedrooms} Bed(s)';
      filterButtons.add(_buildFilterChipButton(context, bedLabel, () => setState(() { _activeFilters = _activeFilters.copyWith(clearSelectedBedrooms: true); _fetchSearchResults(); })));
    }
    if (_activeFilters.selectedBathrooms != null && _activeFilters.selectedBathrooms! > 0) {
      String bathLabel = _activeFilters.selectedBathrooms == PropertyFilterStateModel.maxBathrooms ? '${PropertyFilterStateModel.maxBathrooms}+ Baths' : '${_activeFilters.selectedBathrooms} Bath(s)';
      filterButtons.add(_buildFilterChipButton(context, bathLabel, () => setState(() { _activeFilters = _activeFilters.copyWith(clearSelectedBathrooms: true); _fetchSearchResults(); })));
    }
    for (String amenity in _activeFilters.selectedAmenities) {
      filterButtons.add(_buildFilterChipButton(context, amenity, () => setState(() { _activeFilters = _activeFilters.copyWith(selectedAmenities: List.from(_activeFilters.selectedAmenities)..remove(amenity)); _fetchSearchResults(); })));
    }

    if (filterButtons.isEmpty) return const SizedBox.shrink();

    filterButtons.add(CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      minSize: 0,
      color: CupertinoColors.destructiveRed.withOpacity(0.15),
      onPressed: () => setState(() { _activeFilters = PropertyFilterStateModel.initial(); _fetchSearchResults(); }),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Clear All', style: TextStyle(color: CupertinoColors.destructiveRed.resolveFrom(context), fontSize: 12)),
        const SizedBox(width: 4),
        Icon(CupertinoIcons.clear_circled_solid, color: CupertinoColors.destructiveRed.resolveFrom(context), size: 14),
      ]),
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: filterButtons.map((btn) => Padding(padding: const EdgeInsets.only(right: 8.0), child: btn)).toList()),
      ),
    );
  }

  Widget _buildFilterChipButton(BuildContext context, String label, VoidCallback onClear) {
    final cupertinoTheme = CupertinoTheme.of(context);
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      minSize: 0, // Make button compact
      color: cupertinoTheme.primaryColor.withOpacity(0.1), // Subtle background
      onPressed: onClear, // Tapping the button itself clears it
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: cupertinoTheme.primaryColor, fontSize: 12)),
          const SizedBox(width: 4),
          Icon(CupertinoIcons.clear_circled_solid, color: cupertinoTheme.primaryColor.withOpacity(0.7), size: 14),
        ],
      ),
    );
  }

  void _showFeedbackAlert(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    bool hasActiveFilters = !_activeFilters.isDefault;

    // Showcase styles for Cupertino
    final TextStyle? showcaseTitleStyle = cupertinoTheme.textTheme.navTitleTextStyle.copyWith(color: CupertinoColors.white, fontWeight: FontWeight.bold);
    final TextStyle? showcaseDescStyle = cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.white.withOpacity(0.9));
    final Color showcaseBgColor = cupertinoTheme.primaryColor.withOpacity(0.95);


    return ShowCaseWidget(
      onFinish: () { /* Showcase handled */ },
      builder: Builder(builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Results for "${widget.searchText}"', style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 17)), // Adjusted size
            trailing: Showcase(
              key: _filterButtonKey,
              title: 'Refine Your Search',
              description: 'Tap here to filter results by price, type, amenities, etc.',
              titleTextStyle: showcaseTitleStyle,
              descTextStyle: showcaseDescStyle,
              showcaseBackgroundColor: showcaseBgColor,
              overlayColor: CupertinoColors.black.withOpacity(0.7),
              contentPadding: const EdgeInsets.all(12),
              layerLink: LayerLink(),
              tooltipBorderRadius: BorderRadius.circular(10),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.slider_horizontal_3, color: hasActiveFilters ? cupertinoTheme.primaryColor : CupertinoColors.label.resolveFrom(context)),
                onPressed: () async {
                  final result = await Navigator.of(context).push<PropertyFilterStateModel>(
                    CupertinoPageRoute(builder: (ctx) => PropertyFiltersScreenCupertino(initialFilters: _activeFilters)),
                  );
                  if (result != null) {
                    setState(() => _activeFilters = result);
                    _fetchSearchResults();
                     if (mounted) _showFeedbackAlert('Filters Applied', 'Search results updated.');
                  }
                },
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.off(() => const SearchScreenRouter()), // Use router
                  child: Hero(
                    tag: 'search_field_hero_cupertino', // Ensure this tag matches with SearchScreenCupertino
                    transitionOnUserGestures: true,
                    // Material is used for Hero child to ensure transition properties work as expected
                    // The child itself is styled like a Cupertino field
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.search, color: CupertinoColors.secondaryLabel.resolveFrom(context), size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(widget.searchText, style: cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasActiveFilters) _buildCupertinoActiveFiltersSummary(context),
                if (hasActiveFilters) Divider(height: 0.5, color: CupertinoColors.separator.resolveFrom(context)),
                Expanded(
                  child: FutureBuilder<List<SpaceModel>>(
                    future: _searchResultsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CupertinoActivityIndicator(radius: 15));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${snapshot.error}', style: TextStyle(color: CupertinoColors.destructiveRed.resolveFrom(context)))));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('No results found for "${widget.searchText}".\nTry adjusting your search or filters.', textAlign: TextAlign.center, style: cupertinoTheme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)))));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: SpaceTile(space: snapshot.data![index]), // SpaceTile is adaptive
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
