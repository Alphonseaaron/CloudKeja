import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For kToolbarHeight
import 'package:get/route_manager.dart';
import 'package:cloudkeja/screens/chat/chat_screen.dart';
import 'package:cloudkeja/screens/profile/user_profile.dart'; // For tap on avatar
import 'package:cloudkeja/screens/settings/settings_screen.dart';

class CustomCupertinoAppBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final String titleText;
  final bool showUserProfileLeading;
  final VoidCallback? onUserProfileTap;
  final String? userProfileImageUrl;
  final bool showChatAction;
  final bool showSettingsAction;

  const CustomCupertinoAppBar({
    Key? key,
    required this.titleText,
    this.showUserProfileLeading = false, // Default to false for Cupertino
    this.onUserProfileTap,
    this.userProfileImageUrl,
    this.showChatAction = true,
    this.showSettingsAction = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    Widget? leadingWidget;
    if (showUserProfileLeading) {
      // CupertinoPageRoutes handle back buttons automatically.
      // This leading is for a custom action, like a profile avatar.
      leadingWidget = CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onUserProfileTap ?? () {
          Get.to(() => const UserProfileScreen());
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0), // Adjust padding as needed
          child: CircleAvatar(
            radius: 16, // Smaller for Cupertino nav bar
            backgroundImage: userProfileImageUrl != null && userProfileImageUrl!.isNotEmpty
                ? NetworkImage(userProfileImageUrl!)
                : const AssetImage('assets/images/avatar.png') as ImageProvider,
            backgroundColor: cupertinoTheme.barBackgroundColor.withOpacity(0.5), // Subtle background
          ),
        ),
      );
    }

    List<Widget> trailingWidgets = [];
    if (showChatAction) {
      trailingWidgets.add(
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Get.to(() => const ChatScreen());
          },
          child: const Icon(CupertinoIcons.chat_bubble_2, size: 24), // Adjusted icon
        ),
      );
    }
    if (showSettingsAction) {
      trailingWidgets.add(
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Get.to(() => const SettingsScreen());
          },
          child: const Icon(CupertinoIcons.settings, size: 24), // Adjusted icon
        ),
      );
    }

    Widget? trailing;
    if (trailingWidgets.isNotEmpty) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure buttons fill height
        children: trailingWidgets,
      );
    }


    return CupertinoNavigationBar(
      middle: Text(titleText, style: cupertinoTheme.textTheme.navTitleTextStyle),
      leading: leadingWidget, // Will be automatically managed if null and can show back button
      trailing: trailing,
      backgroundColor: cupertinoTheme.barBackgroundColor.withOpacity(0.85), // Common style for Cupertino
      border: Border(
        bottom: BorderSide(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5, // Standard Cupertino separator width
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard height

  @override
  bool shouldFullyObstruct(BuildContext context) {
    // Determines if the navigation bar should obscure the content behind it.
    // Based on CupertinoNavigationBar's default behavior.
    final Color backgroundColor = CupertinoTheme.of(context).barBackgroundColor;
    return backgroundColor.alpha == 0xFF; // Fully opaque if alpha is 255
  }
}
