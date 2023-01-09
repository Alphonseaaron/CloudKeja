import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/location_provider.dart';
import 'package:cloudkeja/screens/home/home.dart';
import 'package:cloudkeja/screens/maps_screen/maps_screen.dart';
import 'package:cloudkeja/screens/notifications/notifications_screen.dart';
import 'package:cloudkeja/screens/settings/settings_screen.dart';
import 'package:cloudkeja/widgets/custom_bottom_navigation_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List pages = const [
    Home(),
    MapsScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Provider.of<LocationProvider>(context, listen: false).getCurrentLocation();
    Provider.of<AuthProvider>(context, listen: false).getCurrentUser();

    return Scaffold(
        body: pages[selectedIndex],
        bottomNavigationBar: CustomBottomNavigationBar(
          onSelected: (val) {
            setState(() {
              selectedIndex = val;
            });
          },
        ));
  }
}
