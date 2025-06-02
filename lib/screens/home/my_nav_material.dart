import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/location_provider.dart';
import 'package:cloudkeja/screens/home/home.dart'; // Updated import to HomeScreen router
// import 'package:cloudkeja/screens/maps_screen/maps_screen.dart'; // Replaced by MapsRouter
import 'package:cloudkeja/screens/maps/maps_router.dart'; // Import MapsRouter
// import 'package:cloudkeja/screens/notifications/notifications_screen.dart'; // Replaced by NotificationsRouter
import 'package:cloudkeja/screens/notifications/notifications_router.dart'; // Import router
import 'package:cloudkeja/screens/settings/settings_screen.dart';

class MyNavMaterial extends StatefulWidget { // Renamed from MainPage
  const MyNavMaterial({Key? key}) : super(key: key); // Renamed constructor

  @override
  State<MyNavMaterial> createState() => _MyNavMaterialState(); // Renamed state class
}

class _MyNavMaterialState extends State<MyNavMaterial> { // Renamed state class
  // Define the pages for the navigation bar
  final List<Widget> _pages = const [
    HomeScreen(), // Changed to HomeScreen router
    MapsRouter(), // Use MapsRouter
    NotificationsRouter(), // Use NotificationsRouter
    SettingsScreen(),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch initial data here instead of in the build method
    // Ensure this doesn't trigger multiple times unnecessarily if MyNavMaterial itself is rebuilt.
    // Using addPostFrameCallback to ensure context is available for Provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check if the widget is still in the tree
        Provider.of<LocationProvider>(context, listen: false).getCurrentLocation();
        Provider.of<AuthProvider>(context, listen: false).getCurrentUser();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The Scaffold's background color will come from AppTheme.lightTheme.scaffoldBackgroundColor
    return Scaffold(
      body: IndexedStack( // Use IndexedStack to preserve state of pages
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        // Theming for colors and selected/unselected items will be handled by
        // the global NavigationBarThemeData in AppTheme.
      ),
    );
  }
}
