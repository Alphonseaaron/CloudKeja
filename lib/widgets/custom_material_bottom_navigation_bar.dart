import 'package:flutter/material.dart';

class CustomMaterialBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomMaterialBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  // Define items with their icons and labels
  static final List<Map<String, dynamic>> _navBarItemsData = [
    {'icon': Icons.home_outlined, 'selectedIcon': Icons.home, 'label': 'Home'},
    {'icon': Icons.map_outlined, 'selectedIcon': Icons.map, 'label': 'Map'},
    {'icon': Icons.notifications_none_outlined, 'selectedIcon': Icons.notifications, 'label': 'Notifications'},
    {'icon': Icons.settings_outlined, 'selectedIcon': Icons.settings, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navBarTheme = theme.navigationBarTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.symmetric(vertical: 5),
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
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Colors.transparent, // Container provides background
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
