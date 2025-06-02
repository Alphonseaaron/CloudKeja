import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For ScaffoldMessenger, though CupertinoAlertDialog is preferred
import 'package:get/route_manager.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/wishlist_provider.dart';
import 'package:cloudkeja/screens/details/details.dart';
import 'package:cloudkeja/screens/landlord/edit_space_screen.dart';
import 'package:provider/provider.dart';

class SpaceTileCupertino extends StatefulWidget {
  const SpaceTileCupertino({Key? key, required this.space, this.isOwner = false})
      : super(key: key);
  final SpaceModel space;
  final bool isOwner;

  @override
  State<SpaceTileCupertino> createState() => _SpaceTileCupertinoState();
}

class _SpaceTileCupertinoState extends State<SpaceTileCupertino> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
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
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please log in to manage your wishlist.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    await wishlistProvider.addToWishlist(widget.space.id!, _isLiked);

    if (mounted) {
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          authProvider.user!.wishlist ??= [];
          authProvider.user!.wishlist!.add(widget.space.id);
        } else {
          authProvider.user!.wishlist!.remove(widget.space.id);
        }
      });
      // authProvider.getCurrentUser(); // Optional: if state needs global refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // For fallback colors if needed, or CupertinoTheme
    final cupertinoTheme = CupertinoTheme.of(context);

    return GestureDetector(
      onTap: () {
        Get.to(() => widget.isOwner
            ? EditSpaceScreen(space: widget.space)
            : Details(space: widget.space));
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.only(bottom: 12, left:4, right: 4),
        decoration: BoxDecoration(
          color: cupertinoTheme.scaffoldBackgroundColor, // Standard iOS list item background
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              height: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // iOS style rounded corners
                child: Image.network(
                  widget.space.images?.first ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CupertinoActivityIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: CupertinoColors.systemGrey5.resolveFrom(context),
                    child: Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey.resolveFrom(context)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.space.spaceName ?? 'Unnamed Space',
                    style: cupertinoTheme.textTheme.textStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17, // Typical iOS title size
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.space.address ?? 'No address',
                    style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith( // Subdued style
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'KES ${widget.space.price?.toStringAsFixed(0) ?? 'N/A'}',
                    style: cupertinoTheme.textTheme.textStyle.copyWith(
                      color: cupertinoTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Wishlist Icon Button
            if (!widget.isOwner)
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0, // Remove default minSize to make it smaller
                child: Icon(
                  _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: _isLiked ? cupertinoTheme.primaryColor : CupertinoColors.systemGrey.resolveFrom(context),
                  size: 24,
                ),
                onPressed: _toggleWishlist,
              ),
          ],
        ),
      ),
    );
  }
}
