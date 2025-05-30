import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/widgets/recommended_house.dart';
import 'package:cloudkeja/widgets/custom_app_bar.dart';
import 'package:cloudkeja/widgets/search_input.dart';
import 'package:cloudkeja/widgets/welcome_text.dart';
import 'package:cloudkeja/widgets/categories.dart';
import 'package:cloudkeja/widgets/best_offer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:get/route_manager.dart'; // Import Get
import 'package:cloudkeja/screens/search_sp/search_sp_screen.dart'; // Import SearchSPScreen
import 'package:showcaseview/showcaseview.dart';
import 'package:cloudkeja/services/walkthrough_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<SpaceModel>> _spacesFuture;
  bool _isLoading = true;

  // GlobalKeys for ShowcaseView
  final _searchKey = GlobalKey();
  final _categoriesKey = GlobalKey();
  final _recommendedSectionKey = GlobalKey();
  final _firstRecommendedItemKey = GlobalKey(); // Will target the whole RecommendedHouse widget for now
  final _bestOfferSectionKey = GlobalKey();
  final _serviceProviderCtaKey = GlobalKey();

  List<GlobalKey> _showcaseKeys = [];

  @override
  void initState() {
    super.initState();
    _showcaseKeys = [
      _searchKey,
      _categoriesKey,
      _serviceProviderCtaKey,
      _recommendedSectionKey,
      _firstRecommendedItemKey,
      _bestOfferSectionKey,
    ];
    // Ensure WalkthroughService is initialized if not already (idempotent)
    // WalkthroughService.init(); // Already called in main.dart

    // Start showcase after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
       WalkthroughService.startShowcaseIfNeeded(
        context: context,
        walkthroughKey: 'homeScreenWalkthrough',
        showcaseGlobalKeys: _showcaseKeys,
      );
    });

    _fetchSpacesData(); // Initial data fetch
  }

  Future<void> _fetchSpacesData({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() { _isLoading = true; });
    }
    // Assign future directly, FutureBuilder will handle its states
    _spacesFuture = Provider.of<PostProvider>(context, listen: false).getSpaces(forceRefresh: forceRefresh);
    try {
      await _spacesFuture; // Wait for it to complete for loading state
    } catch (e) {
      // Error is handled by FutureBuilder, but can log here if needed
      print("Error fetching spaces: $e");
    } finally {
       if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }


  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0), // Added top padding
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildServiceProviderCTACard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Card(
        // Card uses CardTheme from AppTheme (elevation, shape, color)
        clipBehavior: Clip.antiAlias, // Ensures InkWell ripple effect respects card shape
        child: InkWell(
          onTap: () => Get.to(() => const SearchSPScreen()),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.handyman_outlined, // Example icon
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find a Service Pro',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Plumbers, electricians, cleaners, and more.',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, color: colorScheme.onSurfaceVariant.withOpacity(0.7), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme; // Added for convenience

    // Common showcase text styles
    final TextStyle? showcaseTitleStyle = textTheme.titleLarge?.copyWith(
      color: colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );
    final TextStyle? showcaseDescStyle = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onPrimary.withOpacity(0.9),
    );
    final Color showcaseBgColor = colorScheme.primary.withOpacity(0.95);
    final Color showcaseOverlayColor = colorScheme.scrim.withOpacity(0.7);
    const EdgeInsets showcaseContentPadding = EdgeInsets.all(12);

    final _mockSpaces = List.generate(3, (index) => SpaceModel.empty());

    return ShowCaseWidget(
      onFinish: () {
        WalkthroughService.markAsSeen('homeScreenWalkthrough');
      },
      builder: Builder(builder: (context) { // Important: Use Builder to get context that is a descendant of ShowCaseWidget
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: const CustomAppBar(),
          body: Skeletonizer(
            enabled: _isLoading,
            effect: ShimmerEffect(
              baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
              highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
            ),
            child: RefreshIndicator(
              onRefresh: () => _fetchSpacesData(forceRefresh: true),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16.0), // Add padding at the bottom of the list
                children: [
                  const WelcomeText(),
                  Showcase(
                    key: _searchKey,
                    title: 'Search Properties',
                    description: 'Tap here to search for available properties based on your preferences.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: showcaseBgColor,
                    overlayColor: showcaseOverlayColor,
                    contentPadding: showcaseContentPadding,
                    child: const SearchInput(),
                  ),

                  Showcase(
                    key: _categoriesKey,
                    title: 'Property Categories',
                    description: 'Browse properties by categories like Apartments, Villas, etc.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: showcaseBgColor,
                    overlayColor: showcaseOverlayColor,
                    contentPadding: showcaseContentPadding,
                    child: Column( // Wrap title and Categories in a Column for single showcase item
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Categories'),
                        const Categories(),
                      ],
                    ),
                  ),

                  Showcase(
                    key: _serviceProviderCtaKey,
                    title: 'Find Service Professionals',
                    description: 'Need a plumber, electrician, or cleaner? Find them here!',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: showcaseBgColor, // Consider colorScheme.secondary for variety
                    overlayColor: showcaseOverlayColor,
                    contentPadding: showcaseContentPadding,
                    child: _buildServiceProviderCTACard(context),
                  ),

                  Showcase(
                    key: _recommendedSectionKey,
                    title: 'Recommended For You',
                    description: 'Check out these personalized recommendations.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: showcaseBgColor,
                    overlayColor: showcaseOverlayColor,
                    contentPadding: showcaseContentPadding,
                    child: _buildSectionTitle(context, 'Recommended For You'),
                  ),
                  FutureBuilder<List<SpaceModel>>(
                    future: _spacesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Error: ${snapshot.error}', style: TextStyle(color: colorScheme.error))));
                      }
                      final spacesToShow = _isLoading ? _mockSpaces : (snapshot.data ?? []);
                      if (spacesToShow.isEmpty && !_isLoading) {
                         return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('No recommendations available right now.', style: theme.textTheme.bodyMedium)));
                      }
                      // Wrap the RecommendedHouse with Showcase, using the _firstRecommendedItemKey
                      // This will highlight the entire "RecommendedHouse" widget collection.
                      return Showcase(
                        key: _firstRecommendedItemKey,
                        title: 'Explore Listings',
                        description: 'Tap on any listing to see more details.',
                        titleTextStyle: showcaseTitleStyle,
                        descTextStyle: showcaseDescStyle,
                        showcaseBackgroundColor: showcaseBgColor,
                        overlayColor: showcaseOverlayColor,
                        contentPadding: showcaseContentPadding,
                        child: RecommendedHouse(spaces: spacesToShow),
                      );
                    },
                  ),

                  Showcase(
                    key: _bestOfferSectionKey,
                    title: 'Best Offers',
                    description: 'Discover properties with special offers and deals.',
                    titleTextStyle: showcaseTitleStyle,
                    descTextStyle: showcaseDescStyle,
                    showcaseBackgroundColor: showcaseBgColor, // Consider colorScheme.tertiary for variety
                    overlayColor: showcaseOverlayColor,
                    contentPadding: showcaseContentPadding,
                    child: _buildSectionTitle(context, 'Best Offers'),
                  ),
                  FutureBuilder<List<SpaceModel>>(
                    future: _spacesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const SizedBox.shrink();
                      }
                      final spacesToShow = _isLoading ? _mockSpaces : (snapshot.data ?? []);
                       if (spacesToShow.isEmpty && !_isLoading) {
                         return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('No special offers available currently.', style: theme.textTheme.bodyMedium)));
                      }
                      // Note: BestOffer is not individually showcased here to keep the number of steps manageable.
                      // If BestOffer itself should be a showcase item, it would need its own key and Showcase wrapper.
                      return BestOffer(spaces: spacesToShow);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Extension for SpaceModel to create an empty model for skeletonizer
// Ensure this is defined, or SpaceModel has a similar static factory
extension EmptySpaceModel on SpaceModel { // Keep this if SpaceModel.empty() is not part of the original SpaceModel
  static SpaceModel empty() {
    return SpaceModel(
      id: 'skeleton_${DateTime.now().millisecondsSinceEpoch}',
      spaceName: 'Loading Property Name...',
      address: 'Loading address details...',
      price: 0.0,
      images: ['https://via.placeholder.com/300/F0F0F0/AAAAAA?text=Loading...'],
      description: 'Loading description of property features and details...',
      isAvailable: true,
      ownerId: 'skeleton_owner',
      category: 'Category',
      propertyType: 'Property Type',
      numBedrooms: 0,
      numBathrooms: 0,
      amenities: List.generate(3, (index) => 'Amenity...'),
    );
  }
}
