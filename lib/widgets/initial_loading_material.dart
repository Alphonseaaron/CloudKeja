import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/loading_effect.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/user_model.dart'; // Import UserModel
import 'package:cloudkeja/screens/admin/admin.dart';
import 'package:cloudkeja/screens/home/my_nav_material.dart';
import 'package:cloudkeja/screens/auth/login_page.dart'; // Import LoginPage router

class InitialLoadingScreenMaterial extends StatefulWidget { // Renamed class
  const InitialLoadingScreenMaterial({Key? key}) : super(key: key); // Renamed constructor

  @override
  State<InitialLoadingScreenMaterial> createState() => _InitialLoadingScreenMaterialState(); // Renamed state class
}

class _InitialLoadingScreenMaterialState extends State<InitialLoadingScreenMaterial> { // Renamed state class
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Ensure that context is still valid and mounted before proceeding.
    await Future.delayed(Duration.zero);

    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final UserModel user = await authProvider.getCurrentUser(forceRefresh: true);

      if (!mounted) return;

      if (user.isAdmin == true) { // Ensure isAdmin is not null, or handle null case
        Get.offAll(() => const AdminDashboard());
      } else {
        Get.offAll(() => const MyNavMaterial());
      }
    } catch (e) {
      print('Error during initial user check (Material): $e');
      if (mounted) {
        // It's possible getCurrentUser throws if FirebaseAuth.instance.currentUser is null
        // or if the Firestore document doesn't exist.
        Get.offAll(() => const LoginPage()); // Navigate to LoginPage router
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The LoadingEffect.getSearchLoadingScreen should ideally be theme-aware.
    // If it's a custom widget, ensure it uses Theme.of(context).colorScheme etc.
    return Scaffold(
      body: LoadingEffect.getSearchLoadingScreen(context),
    );
  }
}
