import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/models/property_filter_state_model.dart';
import 'package:cloudkeja/widgets/filters/property_filters_modal.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/search/search_screen_router.dart'; // Use router for search
import 'package:cloudkeja/widgets/space_tile.dart'; // Adaptive router
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';
import 'package:get/route_manager.dart'; // For Get.off


class SearchResultsScreenMaterial extends StatefulWidget {
  final String searchText;

  const SearchResultsScreenMaterial({
    Key? key,
    required this.searchText,
  }) : super(key: key);

  @override
  State<SearchResultsScreenMaterial> createState() => _SearchResultsScreenMaterialState();
}

class _SearchResultsScreenMaterialState extends State<SearchResultsScreenMaterial> {
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
          walkthroughKey: 'tenantPropertySearchFilters_v1_material', // Material specific key
          showcaseGlobalKeys: [_filterButtonKey],
        );
      }
    });
  }

  void _fetchSearchResults() {
    // TODO: Update PostProvider.searchSpaces to accept _activeFilters
    print('Fetching Material search results for: "${widget.searchText}" with filters: ${_activeFilters.toString()}');
    if (mounted) {
      setState(() {
        _searchResultsFuture = Provider.of<PostProvider>(context, listen: false)
            .searchSpaces(widget.searchText /*, filters: _activeFilters */);
      });
    }
  }

  String _formatPrice(double value, BuildContext context) { // Pass context for theme
    if (value >= PropertyFilterStateModel.maxPriceRange) return 'KES ${NumberFormat.compactCurrency(locale: 'en_US', symbol: '', decimalDigits: 0).format(PropertyFilterStateModel.maxPriceRange)}+';
    return 'KES ${NumberFormat.compactCurrency(locale: 'en_US', symbol: '', decimalDigits: 0).format(value)}';
  }

  Widget _buildActiveFiltersSummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<Widget> filterChips = [];

    if (_activeFilters.priceRange != null &&
        (_activeFilters.priceRange!.start > PropertyFilterStateModel.minPriceRange || _activeFilters.priceRange!.end < PropertyFilterStateModel.maxPriceRange )) {
      filterChips.add(Chip(
        label: Text('${_formatPrice(_activeFilters.priceRange!.start, context)} - ${_formatPrice(_activeFilters.priceRange!.end, context)}'),
        onDeleted: () => setState(() { _activeFilters = _activeFilters.copyWith(clearPriceRange: true); _fetchSearchResults(); }),
      ));
    }
    for (String type in _activeFilters.selectedPropertyTypes) {
      filterChips.add(Chip(label: Text(type), onDeleted: () => setState(() { _activeFilters = _activeFilters.copyWith(selectedPropertyTypes: List.from(_activeFilters.selectedPropertyTypes)..remove(type)); _fetchSearchResults(); })));
    }
    if (_activeFilters.selectedBedrooms != null && _activeFilters.selectedBedrooms! > 0) {
      String bedLabel = _activeFilters.selectedBedrooms == PropertyFilterStateModel.maxBedrooms ? '${PropertyFilterStateModel.maxBedrooms}+ Beds' : '${_activeFilters.selectedBedrooms} Bed(s)';
      filterChips.add(Chip(label: Text(bedLabel), onDeleted: () => setState(() { _activeFilters = _activeFilters.copyWith(clearSelectedBedrooms: true); _fetchSearchResults(); })));
    }
    if (_activeFilters.selectedBathrooms != null && _activeFilters.selectedBathrooms! > 0) {
      String bathLabel = _activeFilters.selectedBathrooms == PropertyFilterStateModel.maxBathrooms ? '${PropertyFilterStateModel.maxBathrooms}+ Baths' : '${_activeFilters.selectedBathrooms} Bath(s)';
      filterChips.add(Chip(label: Text(bathLabel), onDeleted: () => setState(() { _activeFilters = _activeFilters.copyWith(clearSelectedBathrooms: true); _fetchSearchResults(); })));
    }
    for (String amenity in _activeFilters.selectedAmenities) {
      filterChips.add(Chip(label: Text(amenity), onDeleted: () => setState(() { _activeFilters = _activeFilters.copyWith(selectedAmenities: List.from(_activeFilters.selectedAmenities)..remove(amenity)); _fetchSearchResults(); })));
    }

    if (filterChips.isEmpty) return const SizedBox.shrink();

    filterChips.add(Chip(
      label: const Text('Clear All'),
      backgroundColor: colorScheme.errorContainer,
      labelStyle: TextStyle(color: colorScheme.onErrorContainer),
      deleteIconColor: colorScheme.onErrorContainer,
      onDeleted: () => setState(() { _activeFilters = PropertyFilterStateModel.initial(); _fetchSearchResults(); }),
      deleteIcon: const Icon(Icons.close, size: 16),
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(spacing: 8.0, children: filterChips),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final inputDecorationTheme = theme.inputDecorationTheme;
    bool hasActiveFilters = !_activeFilters.isDefault;

    return ShowCaseWidget(
      onFinish: () { /* Showcase handled */ },
      builder: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: Text('Results for "${widget.searchText}"', style: textTheme.titleMedium),
            actions: [
              Showcase(
                key: _filterButtonKey,
                title: 'Refine Your Search',
                description: 'Tap the Filter icon to narrow down results by price, type, amenities, and more!',
                titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
                descTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9)),
                showcaseBackgroundColor: colorScheme.primary,
                overlayColor: Colors.black.withOpacity(0.6),
                contentPadding: const EdgeInsets.all(12),
                child: IconButton(
                  icon: Icon(Icons.filter_list_rounded, color: hasActiveFilters ? colorScheme.primary : colorScheme.onSurface),
                  tooltip: 'Filter Results',
                  onPressed: () async {
                    final result = await showModalBottomSheet<PropertyFilterStateModel>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => PropertyFiltersModal(initialFilters: _activeFilters),
                    );
                    if (result != null) {
                      setState(() => _activeFilters = result);
                      _fetchSearchResults();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Filters applied!', style: TextStyle(color: colorScheme.onSurface)), backgroundColor: colorScheme.surfaceVariant, duration: const Duration(seconds: 2))
                         );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.off(() => const SearchScreenRouter()), // Use router
                  child: Hero(
                    tag: 'search_field_hero', // Ensure this tag matches with SearchScreenMaterial
                    transitionOnUserGestures: true,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: AbsorbPointer(
                          child: TextFormField(
                            initialValue: widget.searchText,
                            enabled: false, // Makes it non-interactive
                            decoration: InputDecoration( // Themed decoration
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: SvgPicture.asset('assets/icons/search.svg',
                                  colorFilter: ColorFilter.mode(inputDecorationTheme.hintStyle?.color ?? colorScheme.onSurfaceVariant, BlendMode.srcIn),
                                  width: 20, height: 20),
                              ),
                              hintText: "Search...", // Fallback hint
                              fillColor: inputDecorationTheme.fillColor ?? colorScheme.surfaceVariant.withOpacity(0.5),
                              filled: inputDecorationTheme.filled ?? true,
                              border: inputDecorationTheme.border ?? const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                              disabledBorder: inputDecorationTheme.disabledBorder ?? inputDecorationTheme.border ?? const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                            ),
                            style: textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasActiveFilters) _buildActiveFiltersSummary(context),
                if (hasActiveFilters) Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
                Expanded(
                  child: FutureBuilder<List<SpaceModel>>(
                    future: _searchResultsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Skeletonizer(
                          enabled: true,
                          effect: ShimmerEffect(baseColor: colorScheme.surfaceVariant.withOpacity(0.4), highlightColor: colorScheme.surfaceVariant.withOpacity(0.8)),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: 5,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: SpaceTile(space: SpaceModel.empty(), isOwner: false), // SpaceTile is adaptive
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${snapshot.error}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error))));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('No results found for "${widget.searchText}".\nTry adjusting your search or filters.', textAlign: TextAlign.center, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)))));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) => SpaceTile(space: snapshot.data![index]), // SpaceTile is adaptive
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
