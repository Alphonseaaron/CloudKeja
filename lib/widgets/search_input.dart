import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';
import 'package:cloudkeja/screens/search/search_screen.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Get the global input decoration theme
    final inputDecorationTheme = theme.inputDecorationTheme;

    return GestureDetector(
      onTap: () {
        // Navigate to SearchScreen, consider using Get.toNamed for named routes
        Get.to(() => const SearchScreen());
      },
      child: Hero(
        tag: 'textfield', // Changed tag to 'textfield' for Hero animation
        transitionOnUserGestures: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // M3 standard padding
          child: Material( // Use Material for elevation, shape, and inkwell effects if needed
            elevation: inputDecorationTheme.focusColor != null ? 0 : 1.0, // Subtle elevation, or use themed shadow
            // Use the fillColor from the inputDecorationTheme for background consistency
            color: inputDecorationTheme.fillColor ?? colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: inputDecorationTheme.border is OutlineInputBorder
                ? (inputDecorationTheme.border as OutlineInputBorder).borderRadius
                : BorderRadius.circular(8.0), // Fallback, should match theme
            child: AbsorbPointer( // To make the TextField below non-interactive
              child: TextField(
                enabled: false, // Visually looks like a text field but not interactive
                decoration: InputDecoration(
                  // Most properties will be inherited from inputDecorationTheme
                  // Override specific properties if needed:
                  hintText: 'Search here...',
                  // fillColor is inherited from Material widget's color property above
                  // filled is inherited
                  // border is inherited
                  // contentPadding is inherited

                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0), // Adjusted padding
                    child: SvgPicture.asset(
                      'assets/icons/search.svg',
                      colorFilter: ColorFilter.mode(
                        // Use a color that contrasts well with the input's fill color
                        inputDecorationTheme.hintStyle?.color ?? colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                      width: 20, // Typical icon size
                      height: 20,
                    ),
                  ),
                  // Ensure the hintStyle color also matches what's expected
                  hintStyle: inputDecorationTheme.hintStyle?.copyWith(
                     color: inputDecorationTheme.hintStyle?.color ?? colorScheme.onSurfaceVariant.withOpacity(0.7)
                  )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
