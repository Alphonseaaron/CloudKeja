import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart'; // For Get.to
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/wishlist_provider.dart';
import 'package:cloudkeja/screens/details/details_router.dart'; // Use router for details
import 'package:cached_network_image/cached_network_image.dart'; // For image
import 'package:intl/intl.dart'; // For currency formatting

class BestOfferItemCardCupertino extends StatefulWidget {
  final SpaceModel space;

  const BestOfferItemCardCupertino({Key? key, required this.space}) : super(key: key);

  @override
  _BestOfferItemCardCupertinoState createState() => _BestOfferItemCardCupertinoState();
}

class _BestOfferItemCardCupertinoState extends State<BestOfferItemCardCupertino> {
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

  void _showFeedbackDialog(String title, String content) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
      ),
    );
  }


  Future<void> _toggleFavorite() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

    if (authProvider.user == null) {
      _showFeedbackDialog('Login Required', 'Please log in to manage your wishlist.');
      return;
    }

    final originalFavoriteState = _isFavorited;
    setState(() {
      _isFavorited = !_isFavorited;
    });

    try {
      await wishlistProvider.addToWishlist(widget.space.id!, originalFavoriteState);
       if (mounted) {
         final user = authProvider.user!;
        if (_isFavorited) {
          user.wishlist ??= [];
           if (!user.wishlist!.contains(widget.space.id)) {
            user.wishlist!.add(widget.space.id);
          }
        } else {
          user.wishlist?.remove(widget.space.id);
        }
        authProvider.notifyListeners();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorited = originalFavoriteState;
        });
        _showFeedbackDialog('Error', 'Failed to update wishlist: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return GestureDetector(
      onTap: () {
        Get.to(() => DetailsRouter(space: widget.space));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: cupertinoTheme.barBackgroundColor.withOpacity(0.8), // Subtle background
          border: Border(bottom: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90, // Typical leading image width for CupertinoListTile content
              height: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Standard Cupertino corner radius
                child: CachedNetworkImage(
                  imageUrl: widget.space.images?.firstWhere((img) => img.isNotEmpty, orElse: () => 'https://via.placeholder.com/90x70/CCCCCC/FFFFFF?text=No+Image') ?? 'https://via.placeholder.com/90x70/CCCCCC/FFFFFF?text=No+Image',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CupertinoActivityIndicator(radius: 10)),
                  errorWidget: (context, url, error) => Container(
                    color: CupertinoColors.systemGrey5.resolveFrom(context),
                    child: Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey2.resolveFrom(context), size: 30),
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
                    style: cupertinoTheme.textTheme.textStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.space.address ?? 'No address',
                    style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'KES ${NumberFormat.compactCurrency(locale: 'en_US', symbol: '', decimalDigits: 0).format(widget.space.price ?? 0)}',
                    style: cupertinoTheme.textTheme.textStyle.copyWith(
                      color: cupertinoTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0, // Allow smaller tap target if needed, default is fine
              child: Icon(
                _isFavorited ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: _isFavorited ? cupertinoTheme.primaryColor : CupertinoColors.systemGrey.resolveFrom(context),
                size: 24,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
      ),
    );
  }
}
