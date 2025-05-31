import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/loading_effect.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/screens/admin/admin.dart'; // AdminDashboard is now in admin.dart
import 'package:cloudkeja/screens/home/my_nav_material.dart'; // Updated import

class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({Key? key}) : super(key: key);

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero, () async {
      final user = await Provider.of<AuthProvider>(context, listen: false)
          .getCurrentUser();

      if (user.isAdmin!) {
        Get.offAll(() => const AdminDashboard()); // Used Get.offAll
      } else {
        Get.offAll(() => const MyNavMaterial()); // Changed to MyNavMaterial and used Get.offAll
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingEffect.getSearchLoadingScreen(context), // This loading effect should be theme-aware
    );
  }
}
