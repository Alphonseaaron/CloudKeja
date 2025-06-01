import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For Brightness, MediaQuery
import 'package:provider/provider.dart';
import 'package:get/get.dart'; // Import Get
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

import 'package:cloudkeja/providers/theme_provider.dart';
import 'package:cloudkeja/theme/app_theme.dart'; // Import AppTheme
// import 'package:cloudkeja/screens/auth/cupertino_login_page_stub.dart'; // Will use LoginPage router
import 'package:cloudkeja/screens/auth/login_page.dart'; // Import the LoginPage router
// import 'package:cloudkeja/screens/home/cupertino_main_navigation_stub.dart'; // No longer needed
// import 'package:cloudkeja/screens/home/my_nav_cupertino.dart'; // MyNavCupertino is loaded by AppInitialLoadingRouter
import 'package:cloudkeja/widgets/initial_loading.dart'; // Import AppInitialLoadingRouter

class MyAppCupertino extends StatelessWidget {
  const MyAppCupertino({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This will consume ThemeProvider from main.dart's MultiProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Determine brightness for CupertinoThemeData based on ThemeProvider
    Brightness currentBrightness;
    switch (themeProvider.themeMode) {
      case ThemeMode.light:
        currentBrightness = Brightness.light;
        break;
      case ThemeMode.dark:
        currentBrightness = Brightness.dark;
        break;
      case ThemeMode.system:
      default: // Fallback to system brightness if ThemeMode.system
        currentBrightness = MediaQuery.platformBrightnessOf(context);
        break;
    }

    final CupertinoThemeData currentCupertinoTheme;
    if (currentBrightness == Brightness.dark) {
      currentCupertinoTheme = AppTheme.cupertinoThemeDark;
    } else {
      currentCupertinoTheme = AppTheme.cupertinoThemeLight;
    }

    return GetCupertinoApp( // Changed to GetCupertinoApp
      debugShowCheckedModeBanner: false,
      theme: currentCupertinoTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CupertinoPageScaffold( // Basic scaffold for loading indicator
              child: Center(child: CupertinoActivityIndicator(radius: 15)),
            );
          }
          if (snapshot.hasData) {
            // User is logged in
            // TODO: Replace with CupertinoInitialLoadingScreen if that's created, -> This is now done via AppInitialLoadingRouter
            // similar to how MyAppMaterial uses InitialLoadingScreen.
            // For now, directly to main navigation.
            return const AppInitialLoadingRouter(); // Changed to AppInitialLoadingRouter
          } else {
            // User is not logged in
            return const LoginPage(); // Changed to LoginPage router
          }
        },
      ),
      // Define GetPages here if using GetX named routes for Cupertino
      // getPages: [
      //   GetPage(name: '/login_cupertino', page: () => const CupertinoLoginPageStub()),
      //   GetPage(name: '/main_cupertino', page: () => const CupertinoMainNavigationStub()),
      // ],
    );
  }
}
