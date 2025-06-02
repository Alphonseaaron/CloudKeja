import 'package:firebase_auth/firebase_auth.dart'; // For signOut
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
import 'package:cloudkeja/helpers/loading_effect.dart'; // Themed loading effect
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/theme_provider.dart'; // Import ThemeProvider
import 'package:cloudkeja/screens/admin/admin.dart';
import 'package:cloudkeja/screens/auth/change_password.dart';
import 'package:cloudkeja/screens/auth/login_page.dart';
import 'package:cloudkeja/screens/landlord/landlord_dashboard.dart';
import 'package:cloudkeja/screens/chat/chat_screen.dart'; // Import ChatScreen
// import 'package:cloudkeja/screens/notifications/notifications_screen.dart'; // Removed for redundancy
import 'package:cloudkeja/screens/profile/edit_profile.dart'; // Still used
import 'package:cloudkeja/screens/profile/user_profile.dart'; // For "View Profile"
import 'package:cloudkeja/screens/settings/request_landlord.dart';
import 'package:cloudkeja/screens/settings/wishlist_screen.dart';
import 'package:cloudkeja/screens/service_provider/dashboard_page.dart'; // For Service Provider Dashboard
import 'package:cloudkeja/screens/service_provider/profile_management_page.dart'; // For Service Provider Profile Link
import 'package:cloudkeja/screens/service_provider/view_service_provider_profile_screen.dart'; // Import for testing
import 'package:cloudkeja/services/walkthrough_service.dart'; // Import WalkthroughService

class SettingsScreenMaterial extends StatelessWidget {
  const SettingsScreenMaterial({Key? key}) : super(key: key);

  // Themed buildListTile method
  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false, // Optional: for logout or delete actions
    Widget? trailing, // Allow custom trailing widget
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Color iconColor = isDestructive ? colorScheme.error : colorScheme.primary;
    Color iconBackgroundColor = isDestructive ? colorScheme.errorContainer : colorScheme.primaryContainer;
    Color textColor = isDestructive ? colorScheme.error : colorScheme.onSurface;


    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), // M3 standard radius
              color: iconBackgroundColor,
            ),
            child: Icon(icon, color: iconColor, size: 22), // Adjusted icon size
          ),
          title: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(color: textColor),
          ),
          trailing: trailing ?? Icon( // Use provided trailing or default arrow
            Icons.arrow_forward_ios,
            size: 16,
            color: colorScheme.onSurface.withOpacity(0.5), // Subtle color for trailing icon
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Standard padding
        ),
        Padding( // Apply padding to divider for controlled spacing
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            height: 1, // Standard divider height
            color: theme.dividerColor, // Uses global theme's dividerColor
          ),
        ),
      ],
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentThemeMode = themeProvider.themeMode;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'), // Changed title
      ),
      body: FutureBuilder<UserModel>(
        future: Provider.of<AuthProvider>(context, listen: false).getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return LoadingEffect.getSearchLoadingScreen(context);
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading user data.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)));
          }

          final user = snapshot.data;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            children: [
              if (user != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: (user.profile != null && user.profile!.isNotEmpty)
                            ? NetworkImage(user.profile!)
                            : null,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        child: (user.profile == null || user.profile!.isEmpty)
                            ? Icon(Icons.person_outline, size: 30, color: theme.colorScheme.onSurfaceVariant)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'User',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.email ?? 'No email',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: Divider(height: 24, color: theme.dividerColor),
                ),
                _buildListTile(context, 'View Profile', Icons.account_circle_outlined, () {
                  Get.to(() => const UserProfileScreen());
                }),
                _buildListTile(context, 'Edit Profile', Icons.manage_accounts_outlined, () {
                  Get.to(() => EditProfileScreen());
                }),
              ],

              // App Theme Selection Tile (General Setting)
              _buildListTile(
                context,
                'App Theme',
                Icons.brightness_6_outlined,
                () => _showThemeSelectionDialog(context),
              ),

              // My Chats Tile (General Setting for logged-in users)
              if (user != null) // Ensure user is logged in to see My Chats
                _buildListTile(
                  context,
                  'My Chats',
                  Icons.chat_bubble_outline_rounded,
                  () => Get.to(() => const ChatScreen()),
                ),

              // Temporary Test Tile for ViewServiceProviderProfileScreen
              // Consider removing this or placing under a "Developer Options" if kept long-term
              if (user != null && user.isAdmin == true) // Example: Only show to admins
                _buildListTile(
                  context,
                  'Test View SP Profile (Dev)',
                  Icons.person_search_outlined,
                  () {
                    const String testServiceProviderId = 'test_service_provider_id_123';
                    if (testServiceProviderId == 'test_service_provider_id_123') {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Placeholder ID used. Update for real testing.')),
                      );
                    }
                    Get.to(() => ViewServiceProviderProfileScreen(serviceProviderId: testServiceProviderId));
                  },
                ),


              if (user != null) ...[
                _buildListTile(
                  context,
                  user.isLandlord == true ? 'Landlord Dashboard' : 'Become a Landlord',
                  user.isLandlord == true ? Icons.dashboard_customize_outlined : Icons.real_estate_agent_outlined,
                  () {
                    if (user.isLandlord == true) {
                      Get.to(() => const LandlordDashboard());
                    } else {
                      Get.to(() => const RequestLandlord()); // Changed to full page navigation
                    }
                  },
                ),

                if (user.role == 'ServiceProvider') ...[
                  _buildListTile(
                    context,
                    'Service Provider Dashboard',
                    Icons.build_circle_outlined,
                    () => Get.to(() => const ServiceProviderDashboardPage()),
                  ),
                   _buildListTile(
                    context,
                    'Manage Service Profile',
                    Icons.settings_accessibility_outlined,
                    () => Get.to(() => const ServiceProviderProfilePage()),
                  ),
                ],

                if (user.isAdmin == true) ...[
                  _buildListTile(
                    context,
                    'Admin Panel',
                    Icons.admin_panel_settings_outlined,
                    () => Get.to(() => const Admin()),
                  ),
                  // Developer Options Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).copyWith(top: 20.0),
                    child: Text(
                      'Developer Options',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildListTile(
                    context,
                    'Reset HomeScreen Walkthrough',
                    Icons.replay_circle_filled_outlined,
                    () async {
                      await WalkthroughService.resetSeen('homeScreenWalkthrough');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('HomeScreen walkthrough reset.')),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    'Reset All Walkthroughs',
                    Icons.replay_outlined,
                    () async {
                      await WalkthroughService.resetAllSeenWalkthroughs();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All walkthroughs reset.')),
                      );
                    },
                  ),
                  Padding( // Divider after dev options
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(height: 24, color: theme.dividerColor),
                  ),
                ],

                _buildListTile(context, 'Change Password', Icons.lock_reset_outlined, () {
                  Get.to(() => ChangePassword());
                }),
                _buildListTile(context, 'My Wishlist', Icons.favorite_border_outlined, () {
                  Get.to(() => const WishlistScreen());
                }),

                const SizedBox(height: 20),
                _buildListTile(context, 'Logout', Icons.exit_to_app_outlined, () async {
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                  Get.offAll(() => const LoginPage());
                }, isDestructive: true),
              ],
            ],
          );
        },
      ),
    );
  }
}
