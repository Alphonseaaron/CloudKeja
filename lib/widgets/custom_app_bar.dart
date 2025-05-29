import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart'; // Not used
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/screens/chat/chat_screen.dart';
import 'package:cloudkeja/screens/profile/user_profile.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access theme for icon colors, etc., if not directly handled by AppBarTheme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      // The AppBarTheme from main AppTheme will handle background, elevation, etc.
      // No need to set them here unless specifically overriding.
      leadingWidth: 70, // Adjusted to give avatar some space
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0), // Standard padding for leading items
        child: Center(
          child: FutureBuilder<UserModel>(
            future: Provider.of<AuthProvider>(context, listen: false).getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                // Show a placeholder or loading indicator if desired, but keep it small
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.surfaceVariant, // Theme-aware placeholder BG
                );
              }
              if (snapshot.hasData && snapshot.data?.profile != null) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => const UserProfileScreen());
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(snapshot.data!.profile!),
                    backgroundColor: colorScheme.surfaceVariant, // Fallback BG
                  ),
                );
              }
              // Fallback to local asset if no data or no profile URL
              return GestureDetector(
                onTap: () {
                  Get.to(() => const UserProfileScreen());
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: const AssetImage('assets/images/avatar.png'),
                  backgroundColor: colorScheme.surfaceVariant, // Fallback BG
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Get.to(() => const ChatScreen());
          },
          icon: Icon(
            Icons.chat_bubble_outline, // Material Design icon
            color: colorScheme.onSurface, // Explicitly use theme color
          ),
          tooltip: 'Chats',
        ),
        const SizedBox(width: 8), // Add a bit of spacing for the last action
      ],
      // The title would go here if needed:
      // title: Text(
      //   'Page Title',
      //   style: theme.appBarTheme.titleTextStyle, // Uses global AppBarTheme style
      // ),
      // centerTitle: true, // Or false, based on design
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}
