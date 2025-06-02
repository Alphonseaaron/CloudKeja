import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/loading_effect.dart'; // Replaced by Skeletonizer
import 'package:cloudkeja/models/space_model.dart'; // For displaying results
import 'package:cloudkeja/models/property_filter_state_model.dart'; // For filter state
// import 'package:cloudkeja/widgets/filters/property_filters_modal.dart'; // The Material modal
import 'package:cloudkeja/config/app_config.dart'; // For kBedroomOptions, kBathroomOptions
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/services/platform_service.dart'; // Import PlatformService
import 'package:cloudkeja/screens/search/property_filters_screen_cupertino.dart'; // Import Cupertino filters screen
import 'package:cloudkeja/widgets/filters/property_filters_modal.dart'; // Import Material modal (still needed for Material path)
import 'package:cloudkeja/screens/search/search_screen.dart'; // To navigate back to search input
import 'package:cloudkeja/widgets/space_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchText;
  // Optionally, pass initial filters if search can be pre-filtered
  // final PropertyFilterStateModel? initialFilters;

  const SearchResultsScreen({
    Key? key,
    required this.searchText,
    // this.initialFilters,
  }) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  PropertyFilterStateModel _activeFilters = PropertyFilterStateModel.initial();
  late Future<List<SpaceModel>> _searchResultsFuture;

  final GlobalKey _filterButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // if (widget.initialFilters != null) {
    //   _activeFilters = widget.initialFilters!;
    // }
    _fetchSearchResults();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WalkthroughService.startShowcaseIfNeeded(
        context: context,
        walkthroughKey: 'tenantPropertySearchFilters_v1',
        showcaseGlobalKeys: [_filterButtonKey],
      );
    });
  }

  void _fetchSearchResults() {
    // TODO: In future, PostProvider.searchSpaces should accept _activeFilters
    // For now, it only takes searchText. The print statement simulates applying filters.
    print('Fetching search results for: "${widget.searchText}" with filters: ${_activeFilters.toString()}');
    setState(() {
      _searchResultsFuture = Provider.of<PostProvider>(context, listen: false)
          .searchSpaces(widget.searchText /*, filters: _activeFilters */);
    });
  }

  String _formatPrice(double value) {
    if (value >= 500000) return 'KES 500K+'; // Using the max from filter modal for consistency
    return 'KES ${NumberFormat.compactCurrency(locale: 'en_US', symbol: '', decimalDigits: 0).format(value)}';
  }

  Widget _buildActiveFiltersSummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<Widget> filterChips = [];

    // Price Range
    if (_activeFilters.priceRange != null) {
      filterChips.add(Chip(
        label: Text('${_formatPrice(_activeFilters.priceRange!.start)} - ${_formatPrice(_activeFilters.priceRange!.end)}'),
        onDeleted: () {
          setState(() {
            _activeFilters = _activeFilters.copyWith(clearPriceRange: true);
            _fetchSearchResults(); // Re-fetch
          });
        },
      ));
    }

    // Property Types
    for (String type in _activeFilters.selectedPropertyTypes) {
      filterChips.add(Chip(
        label: Text(type),
        onDeleted: () {
          setState(() {
            _activeFilters = _activeFilters.copyWith(
              selectedPropertyTypes: List.from(_activeFilters.selectedPropertyTypes)..remove(type),
            );
            _fetchSearchResults();
          });
        },
      ));
    }

    // Bedrooms
    if (_activeFilters.selectedBedrooms != null && _activeFilters.selectedBedrooms! > 0) {
       String bedLabel = _activeFilters.selectedBedrooms == 5
          ? '5+ Beds'
          : '${_activeFilters.selectedBedrooms} Bed(s)';
      filterChips.add(Chip(
        label: Text(bedLabel),
        onDeleted: () {
          setState(() {
            _activeFilters = _activeFilters.copyWith(clearSelectedBedrooms: true);
            _fetchSearchResults();
          });
        },
      ));
    }

    // Bathrooms
    if (_activeFilters.selectedBathrooms != null && _activeFilters.selectedBathrooms! > 0) {
      String bathLabel = _activeFilters.selectedBathrooms == 3
          ? '3+ Baths'
          : '${_activeFilters.selectedBathrooms} Bath(s)';
      filterChips.add(Chip(
        label: Text(bathLabel),
        onDeleted: () {
          setState(() {
            _activeFilters = _activeFilters.copyWith(clearSelectedBathrooms: true);
            _fetchSearchResults();
          });
        },
      ));
    }

    // Amenities
    for (String amenity in _activeFilters.selectedAmenities) {
      filterChips.add(Chip(
        label: Text(amenity),
        onDeleted: () {
          setState(() {
            _activeFilters = _activeFilters.copyWith(
              selectedAmenities: List.from(_activeFilters.selectedAmenities)..remove(amenity),
            );
            _fetchSearchResults();
          });
        },
      ));
    }

    if (filterChips.isEmpty) {
      return const SizedBox.shrink(); // No filters active, show nothing
    }

    // Add "Clear All" chip
    filterChips.add(Chip(
      label: const Text('Clear All'),
      backgroundColor: colorScheme.errorContainer,
      labelStyle: TextStyle(color: colorScheme.onErrorContainer),
      deleteIconColor: colorScheme.onErrorContainer,
      onDeleted: () { // Using onDeleted for the action as well, or make it a regular chip + onTap
        setState(() {
          _activeFilters = PropertyFilterStateModel.initial();
          _fetchSearchResults();
        });
      },
      deleteIcon: const Icon(Icons.close, size: 16), // Show a close icon to imply clearing
    ));


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0, // Not really used for horizontal scroll
          children: filterChips,
        ),
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
      onFinish: () {
        // Not calling markAsSeen here, modal will handle it.
        debugPrint('Filter button showcase finished on SearchResultsScreen.');
      },
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
                descTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.8)),
                showcaseBackgroundColor: colorScheme.primary,
                overlayColor: Colors.black.withOpacity(0.6),
                contentPadding: const EdgeInsets.all(12),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: hasActiveFilters ? colorScheme.primary : colorScheme.onSurface,
                  ),
                  tooltip: 'Filter Results',
                  onPressed: () async {
                    PropertyFilterStateModel? result;
                    if (PlatformService.useCupertino) {
                      result = await Navigator.of(context).push<PropertyFilterStateModel>(
                        CupertinoPageRoute(builder: (ctx) => PropertyFiltersScreenCupertino(initialFilters: _activeFilters)),
                      );
                    } else {
                      result = await showModalBottomSheet<PropertyFilterStateModel>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => PropertyFiltersModal(initialFilters: _activeFilters),
                      );
                    }

                    if (result != null) {
                      setState(() {
                        _activeFilters = result;
                      });
                      _fetchSearchResults(); // Trigger re-fetch
                      if (mounted) { // Check mounted before showing SnackBar (Material context)
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Filters applied!'), duration: Duration(seconds: 1))
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
                // Non-interactive display of the search query
                GestureDetector(
                  onTap: () => Get.off(() => const SearchScreen()), // Navigate back to interactive search
                  child: Hero(
                    tag: 'textfield',
                    transitionOnUserGestures: true,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: AbsorbPointer(
                          child: TextFormField(
                            initialValue: widget.searchText,
                            enabled: false,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: SvgPicture.asset(
                                  'assets/icons/search.svg',
                                  colorFilter: ColorFilter.mode(
                                    inputDecorationTheme.hintStyle?.color ?? colorScheme.onSurfaceVariant,
                                    BlendMode.srcIn,
                                  ),
                                  width: 20, height: 20,
                                ),
                              ),
                              disabledBorder: inputDecorationTheme.border ?? const OutlineInputBorder(borderSide: BorderSide.none),
                            ),
                            style: textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Display Active Filters Summary
                if (hasActiveFilters) _buildActiveFiltersSummary(context),
                if (hasActiveFilters) Divider(height:1, color: theme.dividerColor.withOpacity(0.5)),


                // Search results list
                Expanded(
                  child: FutureBuilder<List<SpaceModel>>(
                    future: _searchResultsFuture, // Use state variable for future
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Skeletonizer(
                          enabled: true,
                           effect: ShimmerEffect(
                            baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                            highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: 5,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              // Using SpaceTile.empty() if it exists, or a generic placeholder
                              child: SpaceTile(space: SpaceModel.empty(), isOwner: false),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Error: ${snapshot.error}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No results found for "${widget.searchText}" with the selected filters.\nTry adjusting your search or filters.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return SpaceTile(space: snapshot.data![index]);
                        },
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
                isScrollControlled: true, // Allows modal to be taller
                backgroundColor: Colors.transparent,
                builder: (ctx) => PropertyFiltersModal(initialFilters: _activeFilters),
              );
              if (result != null) {
                setState(() {
                  _activeFilters = result;
                });
                _fetchSearchResults(); // Trigger re-fetch
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Filters applied! (Backend filtering is placeholder)', duration: Duration(seconds: 1),))
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Non-interactive display of the search query
            GestureDetector(
              onTap: () => Get.off(() => const SearchScreen()), // Navigate back to interactive search
              child: Hero(
                tag: 'textfield',
                transitionOnUserGestures: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: AbsorbPointer(
                      child: TextFormField(
                        initialValue: widget.searchText,
                        enabled: false,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: SvgPicture.asset(
                              'assets/icons/search.svg',
                              colorFilter: ColorFilter.mode(
                                inputDecorationTheme.hintStyle?.color ?? colorScheme.onSurfaceVariant,
                                BlendMode.srcIn,
                              ),
                              width: 20, height: 20,
                            ),
                          ),
                          disabledBorder: inputDecorationTheme.border ?? const OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Display Active Filters Summary
            if (hasActiveFilters) _buildActiveFiltersSummary(context),
            if (hasActiveFilters) Divider(height:1, color: theme.dividerColor.withOpacity(0.5)),


            // Search results list
            Expanded(
              child: FutureBuilder<List<SpaceModel>>(
                future: _searchResultsFuture, // Use state variable for future
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Skeletonizer(
                      enabled: true,
                       effect: ShimmerEffect(
                        baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                        highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: 5,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          // Using SpaceTile.empty() if it exists, or a generic placeholder
                          child: SpaceTile(space: SpaceModel.empty(), isOwner: false),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error: ${snapshot.error}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No results found for "${widget.searchText}" with the selected filters.\nTry adjusting your search or filters.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return SpaceTile(space: snapshot.data![index]);
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Ensure SpaceModel.empty() is available for skeletonizer
// Example:
// extension EmptySpaceModel on SpaceModel {
//   static SpaceModel empty() {
//     return SpaceModel(
//       id: 'skel', spaceName: 'Loading...', address: 'Loading...', price: 0, images: [''],
//       // ... other required fields
//     );
//   }
// }
