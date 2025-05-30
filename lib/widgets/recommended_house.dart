import 'package:flutter/material.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart'; // For wishlist check
import 'package:cloudkeja/providers/wishlist_provider.dart'; // For wishlist action
import 'package:cloudkeja/screens/details/details.dart';
import 'package:provider/provider.dart'; // For Provider
import 'package:get/route_manager.dart'; // Added for Get.to()

// Note: CircleIconButton is not imported as its usage will be replaced.
// import 'package:cloudkeja/widgets/circle_icon_button.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor will be replaced

class RecommendedHouse extends StatelessWidget {
  final List<SpaceModel> spaces;

  const RecommendedHouse({Key? key, required this.spaces}) : super(key: key);

  // Modified _navigateToDetails to use Get.to()
  // Removed BuildContext from parameters as Get.to() doesn't require it directly here.
  void _navigateToDetails(SpaceModel space) {
    Get.to(() => Details(space: space));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Outer padding for the entire horizontal list section
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: SizedBox(
        height: 310, // Adjusted height to accommodate card and potential labels
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final space = spaces[index];
            // Pass the space directly to _navigateToDetails
            return _RecommendedHouseCard(space: space, onTapped: () => _navigateToDetails(space));
          },
          separatorBuilder: (_, index) => const SizedBox(width: 16), // Standard spacing
          itemCount: spaces.length,
        ),
      ),
    );
  }
}

class _RecommendedHouseCard extends StatefulWidget {
  final SpaceModel space;
  final VoidCallback onTapped;

  const _RecommendedHouseCard({Key? key, required this.space, required this.onTapped}) : super(key: key);

  @override
  State<_RecommendedHouseCard> createState() => _RecommendedHouseCardState();
}

class _RecommendedHouseCardState extends State<_RecommendedHouseCard> {
  bool _isFavorited = false; // Local state for favorite icon

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user != null && authProvider.user!.wishlist != null) {
          setState(() {
            _isFavorited = authProvider.user!.wishlist!.contains(widget.space.id);
          });
        }
      }
    });
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to manage your wishlist.', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    await wishlistProvider.addToWishlist(widget.space.id!, _isFavorited);

    if (mounted) {
      setState(() {
        _isFavorited = !_isFavorited;
        if (_isFavorited) {
          authProvider.user!.wishlist ??= [];
          authProvider.user!.wishlist!.add(widget.space.id);
        } else {
          authProvider.user!.wishlist!.remove(widget.space.id);
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final cardTheme = theme.cardTheme;

    final cardShape = cardTheme.shape as RoundedRectangleBorder? ??
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));
    final cardBorderRadius = (cardShape.borderRadius as BorderRadius? ?? BorderRadius.circular(12.0));

    return GestureDetector(
      onTap: widget.onTapped,
      child: Card(
        // Card properties from theme (elevation, shape, background color)
        // margin: cardTheme.margin ?? const EdgeInsets.symmetric(horizontal: 8), // Use Card's default or override
        clipBehavior: Clip.antiAlias, // Important for clipping image and content to card shape
        child: SizedBox(
          width: 240, // Fixed width for horizontal scroll items
          height: 300, // Fixed height
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  widget.space.images?.first ?? 'https://via.placeholder.com/230x300', // Placeholder
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator(
                       value: loadingProgress.expectedTotalBytes != null
                               ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                               : null,
                    ));
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colorScheme.surfaceVariant,
                    child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant.withOpacity(0.7), size: 48),
                  ),
                ),
              ),

              // Favorite/Bookmark Icon Button
              Positioned(
                right: 8,
                top: 8,
                child: Container( // Optional container for better visibility if needed
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.5), // Semi-transparent background
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorited ? Icons.bookmark : Icons.bookmark_border,
                      // Using bookmark as "mark.svg" might imply this
                    ),
                    color: _isFavorited ? colorScheme.primary : Colors.white, // Icon color
                    iconSize: 22,
                    onPressed: _toggleFavorite,
                    tooltip: _isFavorited ? 'Remove from bookmarks' : 'Add to bookmarks',
                  ),
                ),
              ),

              // Bottom Info Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    // Gradient for better text readability on image
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.0), // Transparent at top of gradient
                        Colors.black.withOpacity(0.6), // Darker at bottom where text is
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    // If no gradient, use a solid translucent color:
                    // color: colorScheme.surfaceVariant.withOpacity(0.85),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Important for Column in Stack
                    children: [
                      Text(
                        widget.space.spaceName ?? 'Unnamed Space',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white, // Text on dark overlay
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.space.address ?? 'No address',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9), // Text on dark overlay
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'KES ${widget.space.price?.toStringAsFixed(0) ?? 'N/A'}',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary, // Use primary for price, or white if on dark overlay
                          // color: Colors.white, // Alternative for on dark overlay
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
