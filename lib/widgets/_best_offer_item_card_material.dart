import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart'; // For Get.to
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/wishlist_provider.dart';
import 'package:cloudkeja/screens/details/details_router.dart'; // Use router for details

class BestOfferItemCardMaterial extends StatefulWidget {
  final SpaceModel space;

  const BestOfferItemCardMaterial({Key? key, required this.space}) : super(key: key);

  @override
  _BestOfferItemCardMaterialState createState() => _BestOfferItemCardMaterialState();
}

class _BestOfferItemCardMaterialState extends State<BestOfferItemCardMaterial> {
  bool _isFavorited = false;

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
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    final theme = Theme.of(context); // For snackbar styling
    final colorScheme = theme.colorScheme;


    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to manage your wishlist.', style: TextStyle(color: colorScheme.onError)),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating, // Consistent behavior
        ),
      );
      return;
    }

    // Optimistically update UI, then call provider
    final originalFavoriteState = _isFavorited;
    setState(() {
      _isFavorited = !_isFavorited;
    });

    try {
      await wishlistProvider.addToWishlist(widget.space.id!, originalFavoriteState); // Pass original state to provider
      // Update AuthProvider's user model if it's not automatically synced
      if (mounted) {
         final user = authProvider.user!; // User is not null here
        if (_isFavorited) {
          user.wishlist ??= [];
          if (!user.wishlist!.contains(widget.space.id)) {
            user.wishlist!.add(widget.space.id);
          }
        } else {
          user.wishlist?.remove(widget.space.id);
        }
        authProvider.notifyListeners(); // Notify if user model is directly updated
      }
    } catch (e) {
      // Revert UI on error and show error message
      if (mounted) {
        setState(() {
          _isFavorited = originalFavoriteState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update wishlist: ${e.toString()}', style: TextStyle(color: colorScheme.onError)),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      onTap: () {
        // Navigate using the DetailsRouter
        Get.to(() => DetailsRouter(space: widget.space));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        shape: cardShape, // Apply themed shape
        elevation: cardTheme.elevation ?? 1.0, // Apply themed elevation
        color: cardTheme.color ?? colorScheme.surface, // Apply themed color
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                height: 80,
                child: ClipRRect(
                  borderRadius: cardBorderRadius,
                  child: Image.network(
                    widget.space.images?.firstWhere((img) => img.isNotEmpty, orElse: () => 'https://via.placeholder.com/100x80/F0F0F0/AAAAAA?text=No+Image') ?? 'https://via.placeholder.com/100x80/F0F0F0/AAAAAA?text=No+Image',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(
                         value: loadingProgress.expectedTotalBytes != null
                               ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                               : null,
                         strokeWidth: 2.5, // Smaller stroke for tile indicator
                         color: colorScheme.primary, // Themed color
                      ));
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      child: Icon(Icons.broken_image_outlined, color: colorScheme.onSurfaceVariant.withOpacity(0.7), size: 30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.space.spaceName ?? 'Unnamed Space',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.space.address ?? 'No address',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KES ${widget.space.price?.toStringAsFixed(0) ?? 'N/A'}',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
                onPressed: _toggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
