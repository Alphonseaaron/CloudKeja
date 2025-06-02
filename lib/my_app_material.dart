import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// Ensure all necessary provider imports are here
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/job_provider.dart';
import 'package:cloudkeja/providers/location_provider.dart';
import 'package:cloudkeja/providers/maintenance_provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/providers/sp_search_provider.dart';
import 'package:cloudkeja/providers/tenancy_provider.dart';
import 'package:cloudkeja/providers/theme_provider.dart';
import 'package:cloudkeja/providers/wishlist_provider.dart';
import 'package:cloudkeja/models/chat_provider.dart'; // Assuming this is also a provider

// Screen imports
import 'package:cloudkeja/screens/auth/login_page.dart';
import 'package:cloudkeja/screens/chat/chat_room.dart';
// import 'package:cloudkeja/screens/home/my_nav.dart'; // MyNav is loaded by InitialLoadingScreen
import 'package:cloudkeja/widgets/initial_loading.dart';

// Theme import
import 'package:cloudkeja/theme/app_theme.dart';

class MyAppMaterial extends StatelessWidget {
  const MyAppMaterial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MultiProvider is kept at the root in main.dart
    // This widget will now consume ThemeProvider directly if needed,
    // or expect it to be an ancestor from main.dart's MultiProvider.
    // For GetMaterialApp, it needs to consume ThemeProvider to set themeMode.

    // The Consumer<ThemeProvider> is essential here to react to theme changes.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.fadeIn, // Added for Web page transitions
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Use a themed loading indicator if possible, or a simple one
                  return Scaffold(
                    backgroundColor: AppTheme.lightTheme.colorScheme.background, // Or adapt to current theme
                    body: Center(child: CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ))
                  );
                }
                if (snapshot.hasData) {
                  return const InitialLoadingScreen();
                } else {
                  return const LoginPage();
                }
              }),
          routes: {
            ChatRoom.routeName: (ctx) => ChatRoom(),
            // Add other globally accessible named routes if any
          },
        );
      },
    );
  }
}
