import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({Key? key, required this.onSelected})
      : super(key: key);
  final Function(int i)? onSelected;

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  // Using simple strings for item keys, but in a real app, these might be enums or route names.
  final List<String> _bottomBarItems = [
    'home',
    'home_search', // Assuming this was for search, will use a search icon
    'notification',
    'home_mark', // Assuming this was for wishlist/bookmarks
  ];

  // Map string keys to actual Material Icons for better theme integration with NavigationBar
  // SvgPicture can still be used, but direct IconData is often simpler for NavigationBar styling.
  // For this refactor, we'll stick to SvgPicture as per original, but ensure colors are themed.
  final Map<String, String> _itemToSvgPath = {
    'home': 'assets/icons/home.svg',
    'home_search': 'assets/icons/home_search.svg', // Or a generic search icon if not specific
    'notification': 'assets/icons/notification.svg',
    'home_mark': 'assets/icons/home_mark.svg', // Or a generic bookmark/favorite icon
  };

  // Optional: provide selected icons if SVGs have distinct selected states
  // final Map<String, String> _itemToSelectedSvgPath = { ... };

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use navigationBarTheme from global theme if defined, otherwise provide defaults
    final navBarTheme = theme.navigationBarTheme;

    // These colors will be applied to the SvgPicture.
    // NavigationBar's selectedItemColor/unselectedItemColor applies to IconTheme,
    // so we need to handle SvgPicture color manually or ensure SvgTheme is set.
    final Color selectedIconColor = navBarTheme.selectedItemColor ?? colorScheme.primary;
    final Color unselectedIconColor = navBarTheme.unselectedItemColor ?? colorScheme.onSurface.withOpacity(0.65);

    return Container(
      // This container creates the "floating" effect
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Margin for floating effect
      padding: const EdgeInsets.only(bottom: 5, top: 5), // Padding for the NavigationBar itself if needed
      decoration: BoxDecoration(
        color: navBarTheme.backgroundColor ?? colorScheme.surfaceVariant, // M3 nav bars often use surfaceVariant
        borderRadius: BorderRadius.circular(24), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1), // Theme-aware shadow
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            if (widget.onSelected != null) {
              widget.onSelected!(index);
            }
          });
        },
        // Let the NavigationBarTheme handle these, or override here
        // backgroundColor: Colors.transparent, // Make container's color show through
        // indicatorColor: navBarTheme.indicatorColor ?? colorScheme.secondaryContainer,
        // height: 60, // Default is 80 for NavigationBar
        // elevation: 0, // Handled by the container's shadow

        destinations: _bottomBarItems.map((itemKey) {
          final String svgPath = _itemToSvgPath[itemKey]!;
          final bool isSelected = _bottomBarItems.indexOf(itemKey) == _selectedIndex;
          
          // String? label; // If you want labels, define them here
          // switch (itemKey) {
          //   case 'home': label = 'Home'; break;
          //   case 'home_search': label = 'Search'; break;
          //   // ... and so on
          // }

          return NavigationDestination(
            icon: SvgPicture.asset(
              svgPath,
              colorFilter: ColorFilter.mode(
                isSelected ? selectedIconColor : unselectedIconColor,
                BlendMode.srcIn,
              ),
              width: 24, // Standard icon size
              height: 24,
            ),
            // selectedIcon: SvgPicture.asset( // Optional: if you have different SVGs for selected state
            //   _itemToSelectedSvgPath[itemKey] ?? svgPath, // Fallback to normal icon
            //   colorFilter: ColorFilter.mode(selectedIconColor, BlendMode.srcIn),
            //   width: 24,
            //   height: 24,
            // ),
            label: '', // Empty label as original design had no text labels
            // If you add labels:
            // label: label ?? itemKey.capitalizeFirstLetter(), // Basic formatting
          );
        }).toList(),
      ),
    );
  }
}

// Helper extension for capitalizing first letter if using labels
// extension StringExtension on String {
//   String capitalizeFirstLetter() {
//     if (isEmpty) return this;
//     return this[0].toUpperCase() + substring(1);
//   }
// }
