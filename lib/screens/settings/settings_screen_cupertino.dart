import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode; // For ThemeMode enum
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/theme_provider.dart';
import 'package:cloudkeja/screens/auth/login_page.dart';
import 'package:cloudkeja/screens/profile/user_profile.dart'; // Assuming UserProfileScreen is adaptive or Material for now
import 'package:cloudkeja/screens/admin/admin.dart'; // Assuming Admin screen is adaptive or Material
import 'package:cloudkeja/screens/landlord/landlord_dashboard.dart'; // Assuming LandlordDashboard is adaptive or Material
import 'package:cloudkeja/screens/settings/request_landlord.dart'; // Assuming RequestLandlord is adaptive or Material

class SettingsScreenCupertino extends StatelessWidget {
  const SettingsScreenCupertino({super.key});

  Widget _buildListTile({
    required BuildContext context,
    required String title,
    required IconData leadingIcon,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final theme = CupertinoTheme.of(context);
    final Color iconColor = isDestructive ? CupertinoColors.destructiveRed : theme.primaryColor;
    final Color textColor = isDestructive ? CupertinoColors.destructiveRed : theme.textTheme.textStyle.color ?? CupertinoColors.label.resolveFrom(context);

    return CupertinoListTile(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15), // Subtle background for icon
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(leadingIcon, color: iconColor, size: 22),
      ),
      title: Text(title, style: theme.textTheme.textStyle.copyWith(color: textColor)),
      trailing: trailing ?? (onTap != null ? const CupertinoListTileChevron() : null),
      onTap: onTap,
    );
  }

  void _showThemeSelectionActionSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentThemeMode = themeProvider.themeMode;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: currentThemeMode == ThemeMode.light,
            child: const Text('Light'),
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.light);
              Navigator.pop(dialogContext);
            },
          ),
          CupertinoActionSheetAction(
            isDefaultAction: currentThemeMode == ThemeMode.dark,
            child: const Text('Dark'),
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.dark);
              Navigator.pop(dialogContext);
            },
          ),
          CupertinoActionSheetAction(
            isDefaultAction: currentThemeMode == ThemeMode.system,
            child: const Text('System Default'),
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.system);
              Navigator.pop(dialogContext);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: FutureBuilder<UserModel>(
        future: authProvider.getCurrentUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: CupertinoColors.destructiveRed)));
          }

          final UserModel? user = snapshot.data;

          return SafeArea(
            child: ListView(
              children: [
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: CupertinoColors.systemGrey5.resolveFrom(context),
                          backgroundImage: (user.profile != null && user.profile!.isNotEmpty)
                              ? NetworkImage(user.profile!)
                              : null,
                          child: (user.profile == null || user.profile!.isEmpty)
                              ? Icon(CupertinoIcons.person_fill, size: 35, color: CupertinoColors.systemGrey.resolveFrom(context))
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? 'User',
                                style: theme.textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email ?? 'No email',
                                style: theme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8), // Small gap before the first section

                CupertinoListSection.insetGrouped(
                  header: Text('Account', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                  children: [
                    if (user != null) ...[
                      _buildListTile(
                        context: context,
                        title: 'View Profile',
                        leadingIcon: CupertinoIcons.person_circle,
                        onTap: () => Get.to(() => const UserProfileScreen()), // Assuming UserProfileScreen is adaptive
                      ),
                      // Add Edit Profile if needed
                    ],
                    _buildListTile(
                      context: context,
                      title: 'App Theme',
                      leadingIcon: CupertinoIcons.brightness,
                      onTap: () => _showThemeSelectionActionSheet(context),
                    ),
                  ],
                ),

                if (user != null)
                  CupertinoListSection.insetGrouped(
                    header: Text('Roles & Access', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                    children: [
                      _buildListTile(
                        context: context,
                        title: user.isLandlord == true ? 'Landlord Dashboard' : 'Become a Landlord',
                        leadingIcon: user.isLandlord == true ? CupertinoIcons.house_fill : CupertinoIcons.house,
                        onTap: () {
                          if (user.isLandlord == true) {
                            Get.to(() => const LandlordDashboard());
                          } else {
                            // Using Cupertino dialog for RequestLandlord, assuming it's a simple form
                            Get.dialog(CupertinoAlertDialog(
                              title: const Text('Become a Landlord'),
                              content: SingleChildScrollView(child: RequestLandlord()), // Ensure RequestLandlord is suitable for dialog
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () => Get.back(),
                                ),
                                // Add a submit if RequestLandlord has its own submission logic
                              ],
                            ));
                          }
                        },
                      ),
                      if (user.isAdmin == true)
                        _buildListTile(
                          context: context,
                          title: 'Admin Panel',
                          leadingIcon: CupertinoIcons.shield_lefthalf_fill,
                          onTap: () => Get.to(() => const Admin()),
                        ),
                    ],
                  ),

                CupertinoListSection.insetGrouped(
                  children: [
                    _buildListTile(
                      context: context,
                      title: 'Logout',
                      leadingIcon: CupertinoIcons.square_arrow_left,
                      isDestructive: true,
                      onTap: () async {
                        await authProvider.signOut();
                        Get.offAll(() => const LoginPage());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
