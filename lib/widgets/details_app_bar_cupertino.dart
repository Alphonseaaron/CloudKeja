import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For ScaffoldMessenger, NetworkImage, Icons (placeholder if image fails)
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/wishlist_provider.dart';

class DetailsAppBarCupertino extends StatefulWidget {
  final SpaceModel space;

  const DetailsAppBarCupertino({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<DetailsAppBarCupertino> createState() => _DetailsAppBarCupertinoState();
}

class _DetailsAppBarCupertinoState extends State<DetailsAppBarCupertino> {
  
  bool _isLiked() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    return user?.wishlist?.contains(widget.space.id) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final Brightness brightness = CupertinoTheme.brightnessOf(context);
    final bool isDarkMode = brightness == Brightness.dark;

    // Define a consistent style for icon containers on images for Cupertino
    BoxDecoration iconContainerDecoration = BoxDecoration(
      color: isDarkMode 
          ? CupertinoColors.black.withOpacity(0.5) 
          : CupertinoColors.white.withOpacity(0.7),
      shape: BoxShape.circle,
    );

    Color iconColorOnImage = isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return SizedBox(
      height: 400, // Matching Material version's height
      child: Stack(
        children: [
          // Image Carousel
          if (widget.space.images != null && widget.space.images!.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 400.0,
                autoPlay: widget.space.images!.length > 1,
                viewportFraction: 1.0,
                // Remove Material's default indicator dots or style them neutrally if possible
                // For now, assuming default or no indicator is acceptable.
              ),
              items: widget.space.images!.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 400.0,
                      width: MediaQuery.of(context).size.width,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CupertinoActivityIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            CupertinoIcons.photo_fill_on_rectangle_fill, // Placeholder icon
                            color: CupertinoColors.secondaryLabel.resolveFrom(context),
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
              color: CupertinoColors.systemGrey5.resolveFrom(context), // Placeholder background
              child: Center(
                child: Icon(
                  CupertinoIcons.photo_camera_solid,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                  size: 60,
                ),
              ),
            ),

          // Overlayed UI (Back button and Like button)
          Positioned( // Positioned within Stack, SafeArea applied by parent scaffold usually
            top: MediaQuery.of(context).padding.top + 12.0, // Respect status bar
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: iconContainerDecoration,
                    child: Icon(
                      CupertinoIcons.back,
                      color: iconColorOnImage,
                      size: 22,
                    ),
                  ),
                ),

                // Like Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

                    if (authProvider.user == null) {
                      showCupertinoDialog(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: const Text('Login Required'),
                          content: const Text('Please log in to add to wishlist.'),
                          actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
                        )
                      );
                      return;
                    }

                    bool currentlyLiked = _isLiked();
                    await wishlistProvider.addToWishlist(widget.space.id!, currentlyLiked);
                    
                    if (mounted) {
                      setState(() { // To update icon state immediately
                        if (currentlyLiked) {
                          authProvider.user!.wishlist!.remove(widget.space.id);
                        } else {
                          authProvider.user!.wishlist ??= [];
                          authProvider.user!.wishlist!.add(widget.space.id);
                        }
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: iconContainerDecoration,
                    child: Icon(
                      _isLiked() ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      color: _isLiked() ? cupertinoTheme.primaryColor : iconColorOnImage,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
