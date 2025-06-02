import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor will be replaced
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart'; // For wishlist check
import 'package:cloudkeja/providers/wishlist_provider.dart'; // For wishlist action
import 'package:cloudkeja/screens/details/details.dart';
import 'package:cloudkeja/screens/landlord/edit_space_screen.dart';
import 'package:provider/provider.dart'; // To use Provider

class SpaceTileMaterial extends StatefulWidget { // Renamed to SpaceTileMaterial
  const SpaceTileMaterial({Key? key, required this.space, this.isOwner = false})
      : super(key: key);
  final SpaceModel space;
  final bool isOwner;

  @override
  State<SpaceTileMaterial> createState() => _SpaceTileMaterialState();
}

class _SpaceTileMaterialState extends State<SpaceTileMaterial> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    // Initialize _isLiked based on current user's wishlist
    // Use addPostFrameCallback to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user != null && authProvider.user!.wishlist != null) {
          setState(() {
            _isLiked = authProvider.user!.wishlist!.contains(widget.space.id);
          });
        }
      }
    });
  }

  Future<void> _toggleWishlist() async {
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

    // Show loading or disable button if necessary
    await wishlistProvider.addToWishlist(widget.space.id!, _isLiked);

    // Update local state and potentially AuthProvider's user model
    // This assumes addToWishlist in WishlistProvider might not update AuthProvider's user state directly for all widgets
    if (mounted) {
      setState(() {
        _isLiked = !_isLiked;
        // Also update the AuthProvider's user model if it's not automatically synced by WishlistProvider
        if (_isLiked) {
          authProvider.user!.wishlist ??= [];
          authProvider.user!.wishlist!.add(widget.space.id);
        } else {
          authProvider.user!.wishlist!.remove(widget.space.id);
        }
      });
       // Optionally, trigger a refresh of user data in AuthProvider if needed elsewhere
      // authProvider.getCurrentUser();
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final cardTheme = theme.cardTheme;

    // Fallback to default CardTheme values if not fully specified
    final cardShape = cardTheme.shape as RoundedRectangleBorder? ??
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));
    final cardBorderRadius = (cardShape.borderRadius as BorderRadius? ?? BorderRadius.circular(12.0));

    return GestureDetector(
      onTap: () {
        Get.to(() => widget.isOwner
            ? EditSpaceScreen(space: widget.space)
            : Details(space: widget.space));
      },
      child: Card(
        // Card will use CardTheme for color, elevation, shape, margin
        // margin: cardTheme.margin ?? const EdgeInsets.only(bottom: 10), // Using Card's default margin or specific
        margin: const EdgeInsets.only(bottom: 12, left:4, right: 4), // Common margin for tiles
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Inner padding for card content
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25, // Roughly 1/4 of screen width
                height: 90, // Slightly increased height
                child: ClipRRect(
                  borderRadius: cardBorderRadius, // Match card's border radius
                  child: Image.network(
                    widget.space.images?.first ?? 'https://via.placeholder.com/150', // Placeholder
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
                      child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12), // Spacing

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                  children: [
                    Text(
                      widget.space.spaceName ?? 'Unnamed Space',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        // color: colorScheme.onSurface (default from textTheme)
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.space.address ?? 'No address',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                       maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KES ${widget.space.price?.toStringAsFixed(0) ?? 'N/A'}',
                      style: textTheme.titleSmall?.copyWith( // Using titleSmall for price emphasis
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8), // Spacing before icon

              // Wishlist Icon Button
              // No need for Stack if icon is at the end of the Row
              if (!widget.isOwner) // Only show wishlist icon if not owner
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                  ),
                  iconSize: 22, // Slightly smaller
                  padding: EdgeInsets.zero, // Remove default padding if too large
                  constraints: const BoxConstraints(), // Remove default constraints if too large
                  tooltip: _isLiked ? 'Remove from wishlist' : 'Add to wishlist',
                  onPressed: _toggleWishlist,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
