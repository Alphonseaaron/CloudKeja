import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for Cupertino
import 'package:provider/provider.dart'; // Added for Provider
import 'package:cloudkeja/services/platform_service.dart'; // Added for PlatformService
import 'package:shimmer/shimmer.dart';

// LoadingThemeData class is not used by getSearchLoadingScreen directly.
// If it were to be made adaptive, it would require its own refactoring.
/*
class LoadingThemeData {
  late Color shimmerBaseColor, shimmerHighlightColor;
  LoadingThemeData(
      {this.shimmerBaseColor = const Color(0xFFF5F5F5),
      this.shimmerHighlightColor = const Color(0xFFE0E0E0)});

  static get light => LoadingThemeData(
      shimmerBaseColor: const Color(0xFFF5F5F5),
      shimmerHighlightColor: const Color(0xFFE0E0E0));
  static get dark => LoadingThemeData(
      shimmerBaseColor: const Color(0xFF1a1a1a),
      shimmerHighlightColor: const Color(0xFF454545));
}
*/

class LoadingEffect {
  static Widget getSearchLoadingScreen(BuildContext context, {int itemCount = 7}) {
    final platformService = Provider.of<PlatformService>(context, listen: false);
    final bool isCupertino = platformService.useCupertino;

    Color shimmerBaseColor;
    Color shimmerHighlightColor;
    Color placeholderColor;
    Color itemBackgroundColor;
    Border? itemBorder; // Nullable for Cupertino standard look

    if (isCupertino) {
      final cupertinoTheme = CupertinoTheme.of(context);
      shimmerBaseColor = CupertinoColors.systemGrey5.resolveFrom(context);
      shimmerHighlightColor = CupertinoColors.systemGrey4.resolveFrom(context);
      placeholderColor = CupertinoColors.systemGrey3.resolveFrom(context);
      itemBackgroundColor = cupertinoTheme.barBackgroundColor.withOpacity(0.8); // Typical list item bg
      // Optional: Add a bottom border to mimic CupertinoListTile separation
      itemBorder = Border(bottom: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5));
    } else {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      shimmerBaseColor = colorScheme.surfaceVariant.withOpacity(0.5);
      shimmerHighlightColor = colorScheme.surfaceVariant;
      placeholderColor = colorScheme.onSurface.withOpacity(0.1);
      itemBackgroundColor = theme.cardTheme.color ?? colorScheme.surface;
      itemBorder = Border.all(color: colorScheme.outline.withOpacity(0.2));
    }

    Widget singleLoadingItemContent;

    if (isCupertino) {
      singleLoadingItemContent = Container(
        height: 88, // Adjusted height for typical Cupertino list item with subtitle
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: itemBackgroundColor,
          border: itemBorder, // Apply bottom border for separation
        ),
        child: Row(
          children: <Widget>[
            Container( // Image Placeholder
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container( // Line 1
                    height: 12,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 6.0),
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container( // Line 2
                    height: 10,
                    width: MediaQuery.of(context).size.width * 0.5, // Shorter line
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Optional: Trailing placeholder for an icon like chevron or favorite
            // Icon(CupertinoIcons.heart, color: placeholderColor, size: 22),
          ],
        ),
      );
    } else { // Material version (existing structure, but using adaptive colors)
      singleLoadingItemContent = Container(
        height: 96,
        padding: const EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: itemBorder, // Material border
          color: itemBackgroundColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container( // Image Placeholder
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(flex: 3, child: Container(height: 10, decoration: BoxDecoration(color: placeholderColor, borderRadius: BorderRadius.circular(4)))),
                    const Spacer(flex: 1),
                    Icon(Icons.favorite_border, color: placeholderColor, size: 20),
                  ]),
                  Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: placeholderColor, borderRadius: BorderRadius.circular(4))),
                  Row(children: <Widget>[
                    Expanded(flex: 2, child: Container(height: 10, decoration: BoxDecoration(color: placeholderColor, borderRadius: BorderRadius.circular(4)))),
                    const Spacer(flex: 1),
                    Container(height: 10, width: 40, decoration: BoxDecoration(color: placeholderColor, borderRadius: BorderRadius.circular(4))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget singleLoadingItem = Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: singleLoadingItemContent,
    );

    return ListView.separated(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: isCupertino ? 0 : 16.0), // No horizontal padding for full-width Cupertino items
      itemBuilder: (context, index) => singleLoadingItem,
      separatorBuilder: (context, index) => isCupertino ? const SizedBox.shrink() : const SizedBox(height: 12), // No separator if items have their own
    );
  }
}
