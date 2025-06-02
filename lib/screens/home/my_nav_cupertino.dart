import 'package:flutter/cupertino.dart';
import 'package:cloudkeja/theme/app_theme.dart'; // To access AppTheme for colors if needed directly
// import 'package:cloudkeja/screens/home/cupertino_home_page_stub.dart'; // Replaced by HomeScreen router
import 'package:cloudkeja/screens/home/home.dart'; // Import HomeScreen router
import 'package:cloudkeja/screens/maps/cupertino_maps_page_stub.dart';
import 'package:cloudkeja/screens/notifications/cupertino_notifications_page_stub.dart';
// import 'package:cloudkeja/screens/settings/cupertino_settings_page_stub.dart'; // Replaced by SettingsScreen router
import 'package:cloudkeja/screens/settings/settings_screen.dart'; // Import SettingsScreen router

class MyNavCupertino extends StatelessWidget {
  const MyNavCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing primaryColor from the currently applied CupertinoTheme.
    // This ensures it respects light/dark mode as set by MyAppCupertino.
    final Color activeTabColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(CupertinoIcons.home),
          ),
          BottomNavigationBarItem(
            label: 'Map',
            icon: Icon(CupertinoIcons.map),
          ),
          BottomNavigationBarItem(
            label: 'Notifications',
            icon: Icon(CupertinoIcons.bell),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(CupertinoIcons.settings),
          ),
        ],
        activeColor: activeTabColor, // Use theme's primary color
        inactiveColor: CupertinoColors.inactiveGray, // Standard inactive color
        // TabBar text style can also be customized via CupertinoThemeData.tabLabelTextStyle
        // textStyle: AppTheme.cupertinoTabBarTextStyle, // If direct styling is preferred
      ),
      tabBuilder: (BuildContext context, int index) {
        CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return const HomeScreen(); // Changed to HomeScreen router
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return const CupertinoMapsPageStub();
            });
            break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return const CupertinoNotificationsPageStub();
            });
            break;
          case 3:
            returnValue = CupertinoTabView(builder: (context) {
              return const SettingsScreen(); // Changed to SettingsScreen router
            });
            break;
          default: // Should ideally not be reached
            returnValue = CupertinoTabView(builder: (context) {
              return const HomeScreen(); // Changed to HomeScreen router
            });
            break;
        }
        return returnValue;
      },
    );
  }
}
