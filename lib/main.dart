import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// google_fonts is now primarily used within app_theme.dart
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/firebase_options.dart';
import 'package:cloudkeja/models/chat_provider.dart';
import 'package:cloudkeja/providers/admin_provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/job_provider.dart'; // Added in previous subtask, ensure it's here
import 'package:cloudkeja/providers/location_provider.dart';
import 'package:cloudkeja/providers/payment_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/providers/tenancy_provider.dart';
import 'package:cloudkeja/providers/wishlist_provider.dart';
import 'package:cloudkeja/providers/theme_provider.dart';
import 'package:cloudkeja/providers/maintenance_provider.dart';
import 'package:cloudkeja/providers/sp_search_provider.dart'; // Added in previous subtask, ensure it's here
import 'package:cloudkeja/services/walkthrough_service.dart'; // Import WalkthroughService
import 'package:cloudkeja/screens/auth/login_page.dart';
import 'package:cloudkeja/screens/chat/chat_room.dart';
import 'package:cloudkeja/screens/home/my_nav.dart';
import 'package:cloudkeja/widgets/initial_loading.dart';
import 'package:cloudkeja/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  await WalkthroughService.init(); // Initialize WalkthroughService
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => LocationProvider()),
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => PostProvider()),
        ChangeNotifierProvider(create: (ctx) => WishlistProvider()),
        ChangeNotifierProvider(create: (ctx) => PaymentProvider()),
        ChangeNotifierProvider(create: (ctx) => ChatProvider()),
        ChangeNotifierProvider(create: (ctx) => TenancyProvider()),
        ChangeNotifierProvider(create: (ctx) => AdminProvider()),
        ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
        ChangeNotifierProvider(create: (ctx) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (ctx) => JobProvider()), // Added in previous subtask
        ChangeNotifierProvider(create: (ctx) => ServiceProviderSearchProvider()), // Added in previous subtask
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasData) {
                    return const InitialLoadingScreen();
                  } else {
                    return const LoginPage();
                  }
                }),
            routes: {
              ChatRoom.routeName: (ctx) => ChatRoom(),
            },
          );
        },
      ),
    );
  }
}
