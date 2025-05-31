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
  // Define items with their icons and labels (labels are not shown but good for semantics)
  // Order should match _pages in MyNavMaterial: Home, Map, Notifications, Settings
  final List<Map<String, dynamic>> _navBarItemsData = [
    {'icon': Icons.home_outlined, 'selectedIcon': Icons.home, 'label': 'Home'},
    {'icon': Icons.map_outlined, 'selectedIcon': Icons.map, 'label': 'Map'},
    {'icon': Icons.notifications_none_outlined, 'selectedIcon': Icons.notifications, 'label': 'Notifications'},
    {'icon': Icons.settings_outlined, 'selectedIcon': Icons.settings, 'label': 'Settings'},
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use navigationBarTheme from global theme if defined, otherwise provide defaults
    final navBarTheme = theme.navigationBarTheme;

    // final Color selectedIconColor = navBarTheme.selectedItemColor ?? colorScheme.primary; // No longer needed directly here
    // final Color unselectedIconColor = navBarTheme.unselectedItemColor ?? colorScheme.onSurface.withOpacity(0.65); // No longer needed

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.symmetric(vertical: 5), // Adjusted padding
      decoration: BoxDecoration(
        color: navBarTheme.backgroundColor ?? colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
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
        // backgroundColor, indicatorColor, elevation are handled by NavigationBarTheme
        // or the container's decoration for a custom "floating" look.
        // Ensure NavigationBar's own background is transparent if container provides the visual background.
        backgroundColor: Colors.transparent,
        elevation: 0, // Shadow is on the container

        destinations: _navBarItemsData.map((itemData) {
          return NavigationDestination(
            icon: Icon(itemData['icon'] as IconData),
            selectedIcon: Icon(itemData['selectedIcon'] as IconData),
            label: itemData['label'] as String,
          );
        }).toList(),
      ),
    );
  }
}
