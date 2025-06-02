import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Not used
import 'package:provider/provider.dart';

import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/wishlist_provider.dart';

class DetailsAppBar extends StatefulWidget {
  final SpaceModel space;

  const DetailsAppBar({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<DetailsAppBar> createState() => _DetailsAppBarState();
}

class _DetailsAppBarState extends State<DetailsAppBar> {
  _handleNavigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  // isLiked is called in build, so it needs to be able to listen to changes
  // if AuthProvider notifies listeners when user.wishlist changes.
  // For simplicity, assuming it's updated via setState after action.
  bool _isLiked() {
    // Ensure user and wishlist are not null before checking
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    return user?.wishlist?.contains(widget.space.id) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define a consistent style for icon containers on images
    BoxDecoration iconContainerDecoration = BoxDecoration(
      color: colorScheme.surface.withOpacity(0.60), // Use surface with opacity
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 3,
          offset: const Offset(0, 1),
        )
      ]
    );

    Color iconColorOnImage = colorScheme.onSurface; // Icon color for on-surface (with opacity)

    return SizedBox(
      height: 400, // This height is specific to the design
      child: Stack(
        children: [
          // Image Carousel
          if (widget.space.images != null && widget.space.images!.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 400.0,
                autoPlay: widget.space.images!.length > 1, // Autoplay only if more than one image
                viewportFraction: 1.0, // Each image takes full viewport
              ),
              items: widget.space.images!.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.network(
                      imageUrl, // Use the current imageUrl from the map
                      fit: BoxFit.cover,
                      height: 400.0, // Ensure image fills the carousel height
                      width: MediaQuery.of(context).size.width, // Ensure image fills width
                      // Optional: Add loadingBuilder and errorBuilder for Image.network
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            color: colorScheme.onSurface.withOpacity(0.5),
                            size: 50,
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            )
          else
            Container(
              height: 400,
              color: colorScheme.surfaceVariant, // Placeholder background
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  size: 60,
                ),
              ),
            ),

          // Overlayed UI (Back button and Like button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Standard padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => _handleNavigateBack(context),
                    customBorder: const CircleBorder(), // Make ripple effect circular
                    child: Container(
                      padding: const EdgeInsets.all(8), // Padding inside the container
                      decoration: iconContainerDecoration,
                      child: Icon(
                        Icons.arrow_back_ios_new, // Material Design back icon
                        color: iconColorOnImage,
                        size: 20, // Standard icon size
                      ),
                    ),
                  ),

                  // Like Button
                  InkWell(
                    onTap: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

                      if (authProvider.user == null) { // Guard against null user
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Please log in to add to wishlist', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error)
                        );
                        return;
                      }

                      bool currentlyLiked = _isLiked();
                      await wishlistProvider.addToWishlist(widget.space.id!, currentlyLiked);

                      // Optimistically update the UI or wait for provider to notify
                      // For direct feedback, manually update the local state if AuthProvider doesn't auto-update UI
                      if (mounted) {
                        setState(() {
                          if (currentlyLiked) {
                            authProvider.user!.wishlist!.remove(widget.space.id);
                          } else {
                            // Ensure wishlist is initialized
                            authProvider.user!.wishlist ??= [];
                            authProvider.user!.wishlist!.add(widget.space.id);
                          }
                        });
                      }
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: iconContainerDecoration,
                      child: Icon(
                        _isLiked() ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked() ? colorScheme.primary : iconColorOnImage,
                        size: 24, // Standard icon size
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
