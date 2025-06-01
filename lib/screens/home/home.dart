import 'package:flutter/widgets.dart'; // For Widget
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/home/cupertino_home_screen.dart';
import 'package:cloudkeja/screens/home/home_screen_material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Optional: Add a static routeName if direct navigation to this router is ever needed by name
  // static const String routeName = '/home_router';

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const CupertinoHomeScreen();
    } else {
      return const HomeScreenMaterial();
    }
  }
}
