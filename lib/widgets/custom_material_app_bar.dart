import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/screens/chat/chat_screen.dart';
import 'package:cloudkeja/screens/profile/user_profile.dart';
import 'package:cloudkeja/screens/settings/settings_screen.dart';

class CustomMaterialAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final bool showUserProfileLeading;
  final VoidCallback? onUserProfileTap;
  final String? userProfileImageUrl;
  final bool showChatAction;
  final bool showSettingsAction;

  const CustomMaterialAppBar({
    Key? key,
    required this.titleText,
    this.showUserProfileLeading = true,
    this.onUserProfileTap,
    this.userProfileImageUrl,
    this.showChatAction = true,
    this.showSettingsAction = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget? leadingWidget;
    if (showUserProfileLeading) {
      leadingWidget = Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Center(
          child: GestureDetector(
            onTap: onUserProfileTap ?? () {
              Get.to(() => const UserProfileScreen());
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: userProfileImageUrl != null && userProfileImageUrl!.isNotEmpty
                  ? NetworkImage(userProfileImageUrl!)
                  : const AssetImage('assets/images/avatar.png') as ImageProvider,
              backgroundColor: colorScheme.surfaceVariant,
            ),
          ),
        ),
      );
    }

    List<Widget> actions = [];
    if (showChatAction) {
      actions.add(
        IconButton(
          onPressed: () {
            Get.to(() => const ChatScreen());
          },
          icon: Icon(
            Icons.chat_bubble_outline,
            color: colorScheme.onSurface,
          ),
          tooltip: 'Chats',
        ),
      );
    }
    if (showSettingsAction) {
      actions.add(
        IconButton(
          onPressed: () {
            Get.to(() => const SettingsScreen());
          },
          icon: Icon(
            Icons.settings_outlined,
            color: colorScheme.onSurface,
          ),
          tooltip: 'Settings',
        ),
      );
    }
    if (actions.isNotEmpty) {
      actions.add(const SizedBox(width: 8)); // Add spacing if there are actions
    }

    return AppBar(
      leadingWidth: showUserProfileLeading ? 70 : null,
      leading: leadingWidget,
      actions: actions,
      title: Text(titleText),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
