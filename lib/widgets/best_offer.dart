import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/wishlist_provider.dart';
import 'package:cloudkeja/screens/details/details.dart';
import 'package:cloudkeja/screens/home/view_all_screen.dart';
import 'package:provider/provider.dart';

// CircleIconButton is no longer imported.

class BestOffer extends StatelessWidget {
  final List<SpaceModel> spaces;

  const BestOffer({Key? key, required this.spaces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best Offer',
                // Use an appropriate text style from the theme, e.g., titleLarge or titleMedium
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  // color is inherited from theme's onBackground/onSurface
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(() => const ViewAllScreen());
                },
                child: Text(
                  'See All',
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary, // Make it look like a link
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Consistent spacing
          // Using ListView.builder for potentially long lists for better performance
          ListView.builder(
            shrinkWrap: true, // Important when ListView is inside a Column
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              final space = spaces[index];
              // Each item in the list is now an instance of _BestOfferItemCard
              return _BestOfferItemCard(space: space);
            },
          ),
        ],
      ),
    );
  }
}

// Extracted individual item card as a StatefulWidget to manage its own favorite state
class _BestOfferItemCard extends StatefulWidget {
  final SpaceModel space;

  const _BestOfferItemCard({Key? key, required this.space}) : super(key: key);

  @override
  _BestOfferItemCardState createState() => _BestOfferItemCardState();
}

class _BestOfferItemCardState extends State<_BestOfferItemCard> {
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;


    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to manage your wishlist.', style: TextStyle(color: colorScheme.onError)),
          backgroundColor: colorScheme.error,
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
      onTap: () {
        Get.to(() => Details(space: widget.space));
      },
      child: Card(
        // Inherits styling from CardTheme (color, elevation, shape)
        margin: const EdgeInsets.only(bottom: 12.0), // Spacing between cards
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                height: 80,
                child: ClipRRect(
                  borderRadius: cardBorderRadius, // Match card's border radius
                  child: Image.network(
                    widget.space.images?.first ?? 'https://via.placeholder.com/100', // Placeholder
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
              const SizedBox(width: 12),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.space.spaceName ?? 'Unnamed Space',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.space.address ?? 'No address',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
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

              // Favorite Icon Button
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
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
