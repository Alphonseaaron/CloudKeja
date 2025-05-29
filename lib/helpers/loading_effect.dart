import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// LoadingThemeData is not used by getSearchLoadingScreen directly and can be removed if not used elsewhere.
// For now, I will comment it out as the task is to make getSearchLoadingScreen theme-aware.
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
  static Widget getSearchLoadingScreen(BuildContext context, {int itemCount = 7}) { // Reduced item count for typical screen
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define theme-aware colors for shimmer and placeholders
    final shimmerBaseColor = colorScheme.surfaceVariant.withOpacity(0.5); // More subtle base
    final shimmerHighlightColor = colorScheme.surfaceVariant; // Slightly more opaque highlight
    final placeholderColor = colorScheme.onSurface.withOpacity(0.1); // For static placeholder shapes
    final borderColor = colorScheme.outline.withOpacity(0.2); // Subtle border

    Widget singleLoadingItem = Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: Container(
        height: 96, // Original height
        padding: const EdgeInsets.all(12), // Slightly reduced padding
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Consistent with CardTheme
          border: Border.all(color: borderColor),
          color: theme.cardTheme.color ?? colorScheme.surface, // Use card background or surface
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container( // Image Placeholder
              height: 64, // Adjusted size
              width: 64,  // Adjusted size
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(8), // Rounded corners for placeholder
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute space better
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Line 1 & Icon
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 10, // Slightly thicker lines
                          decoration: BoxDecoration(
                            color: placeholderColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1), // Space before icon
                      Icon(
                        Icons.favorite_border, // Standard Material icon
                        color: placeholderColor, // Themed icon color
                        size: 20, // Slightly smaller
                      ),
                    ],
                  ),
                  // Line 2
                  Container(
                    height: 10,
                    width: double.infinity, // Takes full available width of its parent
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Line 3 & Small box
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: placeholderColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      Container(
                        height: 10,
                        width: 40, // Adjusted width
                        decoration: BoxDecoration(
                          color: placeholderColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return ListView.separated(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Standard padding
      itemBuilder: (context, index) => singleLoadingItem,
      separatorBuilder: (context, index) => const SizedBox(height: 12), // Spacing between shimmer items
    );
  }
}
