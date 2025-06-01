import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/screens/admin/cupertino_admin_dashboard_stub.dart';
import 'package:cloudkeja/screens/home/my_nav_cupertino.dart';
import 'package:cloudkeja/screens/auth/login_page.dart'; // Router for login

class CupertinoInitialLoadingScreen extends StatefulWidget {
  const CupertinoInitialLoadingScreen({super.key});

  @override
  State<CupertinoInitialLoadingScreen> createState() => _CupertinoInitialLoadingScreenState();
}

class _CupertinoInitialLoadingScreenState extends State<CupertinoInitialLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Ensure that context is still valid and mounted before proceeding.
    // Delaying with Duration.zero allows the first frame to build.
    await Future.delayed(Duration.zero);

    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Attempt to get current user. This might throw if no user is logged in via FirebaseAuth.instance.currentUser
      // or if fetching from Firestore fails when it shouldn't (e.g. user deleted from DB but auth state persists briefly)
      final UserModel user = await authProvider.getCurrentUser(forceRefresh: true); // forceRefresh to get latest admin status

      if (!mounted) return; // Check again after await

      if (user.isAdmin == true) {
        Get.offAll(() => const CupertinoAdminDashboardStub());
      } else {
        Get.offAll(() => const MyNavCupertino());
      }
    } catch (e) {
      // If any error occurs (e.g., user not found in DB, network issue, or no Firebase user)
      // redirect to login.
      print('Error during initial user check: $e');
      if (mounted) {
        Get.offAll(() => const LoginPage()); // Navigate to the LoginPage router
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(radius: 15),
            const SizedBox(height: 16),
            Text(
              'Loading your workspace...',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
