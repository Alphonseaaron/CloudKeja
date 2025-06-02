import 'package:flutter/cupertino.dart';

class CustomCupertinoBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomCupertinoBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  // Define items with their icons. Labels are implicitly handled by CupertinoTabBar if not provided.
  // For explicit labels, use the `label` property within BottomNavigationBarItem.
  // However, standard Cupertino tab bars often just use icons.
  static final List<BottomNavigationBarItem> _tabBarItems = [
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.home),
      activeIcon: Icon(CupertinoIcons.house_fill), // Example active icon
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.map), // Using non-filled for inactive
      activeIcon: Icon(CupertinoIcons.map_fill),
      label: 'Map',
    ),
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.bell),
      activeIcon: Icon(CupertinoIcons.bell_fill),
      label: 'Notifications',
    ),
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.settings),
      activeIcon: Icon(CupertinoIcons.settings_solid), // Example active icon
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return CupertinoTabBar(
      items: _tabBarItems,
      currentIndex: currentIndex,
      onTap: onTap,
      activeColor: cupertinoTheme.primaryColor,
      inactiveColor: CupertinoColors.inactiveGray, // Standard inactive color
      // backgroundColor: cupertinoTheme.barBackgroundColor.withOpacity(0.95), // Standard semi-transparent background
      // border: Border( // Standard top border
      //   top: BorderSide(
      //     color: CupertinoColors.separator.resolveFrom(context),
      //     width: 0.5,
      //   ),
      // ),
      // Theming for a "floating" style like the Material version:
      // To make it "floating", we would wrap CupertinoTabBar in a Padding/Container
      // and apply decoration to that container. CupertinoTabBar itself doesn't have
      // margin or shadow properties directly.
      // For this task, we will use a standard appearance.
      // If a floating look is strictly needed, the structure would be:
      // Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       color: cupertinoTheme.barBackgroundColor.withOpacity(0.9),
      //       borderRadius: BorderRadius.circular(24),
      //       boxShadow: [
      //         BoxShadow(
      //           color: CupertinoColors.systemGrey.withOpacity(0.2),
      //           spreadRadius: 1,
      //           blurRadius: 8,
      //           offset: const Offset(0, 2),
      //         ),
      //       ],
      //     ),
      //     child: ClipRRect( // ClipRRect to ensure TabBar respects container's border radius
      //       borderRadius: BorderRadius.circular(24),
      //       child: CupertinoTabBar(...)
      //     )
      //   )
      // )
      // For now, returning a standard CupertinoTabBar:
       backgroundColor: cupertinoTheme.barBackgroundColor, // Default, can be slightly transparent by theme
       border: Border(
         top: BorderSide(
           color: CupertinoColors.separator.resolveFrom(context),
           width: 0.0, // Standard is 0.0 for no visible line or 0.5 for a thin line
         ),
       ),
    );
  }
}
