import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/route_manager.dart'; // For Get.to and Get.offAll
import 'package:cloudkeja/screens/admin/all_landlords.dart';
import 'package:cloudkeja/screens/admin/alll_users_screen.dart'; // Corrected typo from 'alll_users_screen' to 'all_users_screen' if that's the actual filename
import 'package:cloudkeja/screens/auth/login_page.dart';
import 'package:cloudkeja/screens/chat/chat_screen.dart'; // Assuming ChatScreen is suitable or will be adapted

// TODO: Rename this file to admin_dashboard_cupertino.dart

class CupertinoAdminDashboardStub extends StatelessWidget {
  const CupertinoAdminDashboardStub({super.key});

  // Helper to build list tiles for navigation
  Widget _buildNavigationTile(BuildContext context, {
    required String title,
    required IconData leadingIcon, // Use CupertinoIcons
    required VoidCallback onTap,
  }) {
    final theme = CupertinoTheme.of(context);
    return CupertinoListTile.notched(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(leadingIcon, color: theme.primaryColor, size: 22),
      ),
      title: Text(title, style: TextStyle(color: theme.textTheme.textStyle.color)),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }

  // Placeholder for summary data items
  Widget _buildSummaryItem(BuildContext context, String label, String value) {
     final theme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.textStyle),
          Text(value, style: theme.textTheme.textStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Admin Dashboard'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.square_arrow_left, size: 24), // Logout icon
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Get.offAll(() => const LoginPage()); // Navigate to login, clear stack
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: Text('Overview', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
              children: [
                _buildSummaryItem(context, 'Total Users', '1,234'), // Placeholder
                _buildSummaryItem(context, 'Active Landlords', '56'),   // Placeholder
                _buildSummaryItem(context, 'Properties Listed', '789'), // Placeholder
                _buildSummaryItem(context, 'Pending Approvals', '12'),  // Placeholder
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text('Management', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
              children: [
                _buildNavigationTile(
                  context,
                  title: 'Manage Users',
                  leadingIcon: CupertinoIcons.group_solid,
                  onTap: () => Get.to(() => const AllUsersScreen()),
                ),
                _buildNavigationTile(
                  context,
                  title: 'Manage Landlords',
                  leadingIcon: CupertinoIcons.house_alt_fill,
                  onTap: () => Get.to(() => const AllLandlordsScreen()),
                ),
                _buildNavigationTile(
                  context,
                  title: 'System Analytics',
                  leadingIcon: CupertinoIcons.chart_bar_square_fill,
                  onTap: () {
                    // Placeholder: PDF generation might be a shared service, UI feedback should be Cupertino
                    showCupertinoDialog(
                      context: context,
                      builder: (ctx) => CupertinoAlertDialog(
                        title: const Text('Analytics'),
                        content: const Text('System analytics report generation is not yet implemented for Cupertino.'),
                        actions: [CupertinoDialogAction(isDefaultAction: true, child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
                      ),
                    );
                  },
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text('Support', style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
              children: [
                _buildNavigationTile(
                  context,
                  title: 'User Support Tickets',
                  leadingIcon: CupertinoIcons.bubble_left_bubble_right_fill,
                  onTap: () => Get.to(() => const ChatScreen()), // Assuming ChatScreen can be used or adapted
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
