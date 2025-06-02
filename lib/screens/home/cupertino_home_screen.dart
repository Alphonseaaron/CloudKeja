import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart'; // Added for ShowCaseWidget
import 'package:cloudkeja/services/walkthrough_service.dart'; // Added for WalkthroughService
import 'package:get/get.dart';

import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/config/app_config.dart'; // For kPropertyCategories
import 'package:cloudkeja/screens/search/search_screen.dart'; // Router for search
import 'package:cloudkeja/screens/search_sp/search_sp_screen.dart'; // Router for SP search
import 'package:cloudkeja/screens/details/details.dart'; // For navigation to Details (will be router later)
import 'package:cloudkeja/screens/home/view_all_screen.dart'; // For "See All"
import 'package:cloudkeja/screens/settings/settings_screen.dart'; // Import for Settings
import 'package:intl/intl.dart'; // For currency formatting


class CupertinoHomeScreen extends StatefulWidget {
  const CupertinoHomeScreen({super.key});

  @override
  State<CupertinoHomeScreen> createState() => _CupertinoHomeScreenState();
}

class _CupertinoHomeScreenState extends State<CupertinoHomeScreen> {
  bool _isLoading = true;
  List<SpaceModel> _spaces = [];
  String? _errorMessage;
  UserModel? _currentUser;
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Recommended', 'Newest', 'Popular', 'Nearby'];

  // GlobalKeys for ShowcaseView
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _categoriesKey = GlobalKey();
  final GlobalKey _serviceProviderCtaKey = GlobalKey();
  final GlobalKey _recommendedSectionKey = GlobalKey();
  final GlobalKey _bestOfferSectionKey = GlobalKey();
  late List<GlobalKey> _showcaseKeys;

  @override
  void initState() {
    super.initState();
    _showcaseKeys = [
      _searchKey,
      _categoriesKey,
      _serviceProviderCtaKey,
      _recommendedSectionKey,
      _bestOfferSectionKey,
    ];
    _loadInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) { // Ensure context is still valid
        WalkthroughService.startShowcaseIfNeeded(
          context: context,
          walkthroughKey: 'homeScreenWalkthroughCupertino',
          showcaseGlobalKeys: _showcaseKeys,
        );
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Fetch current user for welcome message
      _currentUser = await Provider.of<AuthProvider>(context, listen: false).getCurrentUser();
      // Fetch spaces
      final spaces = await Provider.of<PostProvider>(context, listen: false).getSpaces();
      if (!mounted) return;
      setState(() {
        _spaces = spaces;
        // _isLoading = false; // Keep true until all data is loaded or set false if this is the last one
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        // _isLoading = false;
      });
    } finally {
       if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildWelcomeText(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    String userName = _currentUser?.name?.split(' ').first ?? 'Guest'; // Get first name or 'Guest'

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $userName!',
            // Using navLargeTitleTextStyle for a prominent greeting
            style: theme.textTheme.navLargeTitleTextStyle.copyWith(
              fontWeight: FontWeight.bold, // Ensure it's bold
              color: theme.textTheme.navLargeTitleTextStyle.color ?? CupertinoColors.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find your perfect space.',
            style: theme.textTheme.textStyle.copyWith(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoCategories(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    // Defined styles will be passed to Showcase widget props later
    return Showcase(
      key: _categoriesKey,
      title: 'Property Categories',
      description: 'Browse properties by different categories like Recommended, Newest, etc.',
      // titleTextStyle, descTextStyle, etc. will be passed from build method's ShowCaseWidget wrapper if not overridden here
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: SizedBox(
          height: 36, // Standard height for segmented control like elements
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final bool isSelected = _selectedCategoryIndex == index;
              return Padding(
                padding: EdgeInsets.only(right: index == _categories.length - 1 ? 0 : 8.0), // Add spacing between buttons
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
                  color: isSelected ? theme.primaryColor : CupertinoColors.tertiarySystemFill.resolveFrom(context),
                  onPressed: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                    // ignore: avoid_print
                    print('Selected category: ${_categories[index]}');
                  },
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      fontSize: 14, // Consistent font size
                      color: isSelected ? CupertinoColors.white : theme.primaryColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCupertinoSearchInput(BuildContext context) {
    return Showcase(
      key: _searchKey,
      title: 'Search Properties',
      description: 'Tap here to search for available properties, locations, or keywords.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: GestureDetector(
          onTap: () => Get.to(() => const SearchScreen()), // Navigate to SearchScreen router
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.search, color: CupertinoColors.secondaryLabel.resolveFrom(context), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Search properties, locations...',
                  style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoSPCtaCard(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return Showcase(
      key: _serviceProviderCtaKey,
      title: 'Find Service Professionals',
      description: 'Need help with repairs or other services? Find trusted professionals here.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: CupertinoListTile(
          leadingSize: 36, 
          leading: Icon(
            CupertinoIcons.person_badge_plus_fill,
            color: theme.primaryColor,
            size: 30,
          ),
          title: Text(
            'Find a Service Pro',
            style: theme.textTheme.textStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.textStyle.color ?? CupertinoColors.label.resolveFrom(context)
            ),
          ),
          subtitle: Text(
            'Plumbers, electricians, cleaners...',
            style: theme.textTheme.tabLabelTextStyle.copyWith(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            )
          ),
          trailing: const CupertinoListTileChevron(),
          onTap: () => Get.to(() => const SearchSPScreen()), 
        ),
      ),
    );
  }

  Widget _buildCupertinoRecommended(BuildContext context, List<SpaceModel> spaces) {
    final theme = CupertinoTheme.of(context);
    if (spaces.isEmpty && !_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text(
            'No recommendations available right now.',
            style: theme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Showcase(
          key: _recommendedSectionKey,
          title: 'Recommended Properties',
          description: 'Check out these properties recommended just for you. Swipe to see more.',
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
            child: Text(
              'Recommended For You',
              style: theme.textTheme.navTitleTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.navTitleTextStyle.color ?? CupertinoColors.label.resolveFrom(context),
              )
            ),
          ),
        ),
        SizedBox(
          height: 290, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _isLoading ? 3 : spaces.length, // Show 3 skeleton items or actual items
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemBuilder: (context, index) {
              if (_isLoading) {
                return _CupertinoRecommendedItemCard(space: SpaceModel.empty(), isLoading: true);
              }
              final space = spaces[index];
              return _CupertinoRecommendedItemCard(space: space);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCupertinoBestOffers(BuildContext context, List<SpaceModel> spaces) {
     final theme = CupertinoTheme.of(context);
    if (spaces.isEmpty && !_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text(
            'No special offers available currently.',
            style: theme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Showcase(
          key: _bestOfferSectionKey,
          title: 'Best Offers',
          description: 'Discover special offers and deals on properties. Tap "See All" for more.',
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 0.0), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Best Offers',
                   style: theme.textTheme.navTitleTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.navTitleTextStyle.color ?? CupertinoColors.label.resolveFrom(context),
                  )
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('See All'),
                  onPressed: () => Get.to(() => const ViewAllScreen(title: 'Best Offers')), 
                ),
              ],
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Add horizontal padding for tiles
          itemCount: _isLoading ? 3 : (spaces.length > 5 ? 5 : spaces.length), // Show 3 skeleton or up to 5 items
          itemBuilder: (context, index) {
            if (_isLoading) {
              return _CupertinoBestOfferItemTile(space: SpaceModel.empty(), isLoading: true);
            }
            final space = spaces[index];
            return _CupertinoBestOfferItemTile(space: space);
          },
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    // Define Cupertino Showcase Styles
    final TextStyle? showcaseTitleStyle = cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
      color: CupertinoColors.white, 
      fontWeight: FontWeight.bold,
    );
    final TextStyle? showcaseDescStyle = cupertinoTheme.textTheme.textStyle.copyWith(
      color: CupertinoColors.white.withOpacity(0.9),
    );
    final Color showcaseBgColor = cupertinoTheme.primaryColor.withOpacity(0.95);
    final Color showcaseOverlayColor = CupertinoColors.black.withOpacity(0.7);
    const EdgeInsets showcaseContentPadding = EdgeInsets.all(12);
    final BorderRadius showcaseTooltipBorderRadius = BorderRadius.circular(10.0);

    return ShowCaseWidget(
      onFinish: () {
        WalkthroughService.markAsSeen('homeScreenWalkthroughCupertino');
      },
      builder: Builder(builder: (showcaseContext) { // Use Builder to get context for ShowCaseWidget.of
        // Pass styles to individual Showcase items
        // This requires modifying _build... methods or wrapping their direct calls.
        // For simplicity, I'll modify the build methods to accept Showcase props if this approach is taken.
        // Or, apply them here if the ShowCase items are built directly in this tree.

        // The current structure has _build methods returning the widget to be showcased.
        // So, the Showcase widget needs to wrap the call to these _build methods,
        // and the style props will be passed to each Showcase instance.
        // The styles defined above will be passed to each Showcase instance.

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Home'),
            trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.settings, size: 24), // Standard icon size for nav bar actions
          onPressed: () {
            Get.to(() => const SettingsScreen()); // Navigate to SettingsScreen router
          },
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator.adaptive( // Use .adaptive for Cupertino style pull-down
           onRefresh: _loadInitialData,
           child: Builder( // Builder to ensure context for CupertinoTheme.of(context) is correct if used widely
             builder: (context) {
               if (_isLoading && _spaces.isEmpty) { // Show loader only on initial empty load
                 return const Center(child: CupertinoActivityIndicator(radius: 15));
               }
               if (_errorMessage != null) {
                 return Center(
                   child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Text('Error: $_errorMessage', style: TextStyle(color: CupertinoColors.destructiveRed)),
                   ),
                 );
               }

               return ListView(
                 children: [
                   _buildWelcomeText(context),
                   _buildCupertinoSearchInput(context),
                   _buildWelcomeText(context),
                   // The _build methods are already wrapped with Showcase internally now.
                   _buildCupertinoSearchInput(context), 
                   _buildCupertinoCategories(context), 
                   _buildCupertinoSPCtaCard(context), 
                   _buildCupertinoRecommended(context, _spaces),
                   _buildCupertinoBestOffers(context, _spaces),
                   const SizedBox(height: 20), 
                 ],
               );
             }
           ),
        ),
        );
      }), 
    );
  }
}


// --- Individual Item Card Widgets ---

class _CupertinoRecommendedItemCard extends StatelessWidget {
  final SpaceModel space;
  final bool isLoading;

  const _CupertinoRecommendedItemCard({required this.space, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    if (isLoading) { // Basic skeleton for the card
      return Container(
        width: 230,
        margin: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
        decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 160, color: CupertinoColors.systemGrey4.resolveFrom(context),
              decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), color: CupertinoColors.systemGrey4.resolveFrom(context))
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 150, color: CupertinoColors.systemGrey4.resolveFrom(context), margin: const EdgeInsets.only(bottom: 4)),
                  Container(height: 12, width: 100, color: CupertinoColors.systemGrey4.resolveFrom(context), margin: const EdgeInsets.only(bottom: 6)),
                  Container(height: 14, width: 80, color: CupertinoColors.systemGrey4.resolveFrom(context)),
                ],
              ),
            )
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => Get.to(() => Details(space: space)),
      child: Container(
        width: 230, // Fixed width for horizontal scroll items
        margin: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4), // Adjusted margin for consistent spacing
        decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor, // Use scaffold for card background for a less "heavy" look
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: CupertinoColors.systemGrey4.resolveFrom(context), width: 0.5)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              child: Image.network(
                space.images?.firstWhere((img) => img.isNotEmpty, orElse: () => 'https://via.placeholder.com/230x160/CCCCCC/FFFFFF?Text=Property') ?? 'https://via.placeholder.com/230x160/CCCCCC/FFFFFF?Text=Property',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox(height:160, child: Center(child: CupertinoActivityIndicator(radius: 10,))),
                errorBuilder: (context, error, stackTrace) => const SizedBox(height:160, child: Center(child: Icon(CupertinoIcons.photo, color: CupertinoColors.secondaryLabel))),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes price to bottom
                  children: [
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           space.spaceName ?? 'Unnamed Space',
                           style: theme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                         const SizedBox(height: 2),
                         Text(
                           space.address ?? 'No address',
                           style: theme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 13),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                       ],
                    ),
                    Text(
                      'KES ${NumberFormat.compactCurrency(locale: 'en_US', symbol: '', decimalDigits: 0).format(space.price ?? 0)}',
                      style: theme.textTheme.textStyle.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoBestOfferItemTile extends StatelessWidget {
  final SpaceModel space;
  final bool isLoading;

  const _CupertinoBestOfferItemTile({required this.space, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    if (isLoading) { // Basic skeleton for the tile
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Container(width: 90, height: 70, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: CupertinoColors.systemGrey4.resolveFrom(context))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: double.infinity, color: CupertinoColors.systemGrey4.resolveFrom(context), margin: const EdgeInsets.only(bottom: 6)),
                  Container(height: 12, width: 150, color: CupertinoColors.systemGrey4.resolveFrom(context), margin: const EdgeInsets.only(bottom: 6)),
                  Container(height: 14, width: 80, color: CupertinoColors.systemGrey4.resolveFrom(context)),
                ],
              ),
            )
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => Get.to(() => Details(space: space)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0), // Padding around the tile content
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey5.resolveFrom(context), width: 0.5))
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                space.images?.firstWhere((img) => img.isNotEmpty, orElse: () => 'https://via.placeholder.com/90x70/CCCCCC/FFFFFF?Text=Offer') ?? 'https://via.placeholder.com/90x70/CCCCCC/FFFFFF?Text=Offer',
                width: 90,
                height: 70,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox(width:90, height:70, child: Center(child: CupertinoActivityIndicator(radius: 10))),
                errorBuilder: (context, error, stackTrace) => const SizedBox(width:90, height:70, child: Center(child: Icon(CupertinoIcons.photo, color: CupertinoColors.secondaryLabel))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.spaceName ?? 'Unnamed Offer',
                    style: theme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    space.address ?? 'No address',
                    style: theme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KES ${NumberFormat.compactCurrency(locale: 'en_US', symbol: '', decimalDigits: 0).format(space.price ?? 0)}',
                    style: theme.textTheme.textStyle.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 14),
                  ),
                ],
              ),
            ),
            // Optional: Favorite icon or other trailing widget
            // Icon(CupertinoIcons.heart, color: CupertinoColors.systemGrey2),
          ],
        ),
      ),
    );
  }
}
