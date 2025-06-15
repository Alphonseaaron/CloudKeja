import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Required for ObstructingPreferredSizeWidget if CustomCupertinoAppBar uses it
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/widgets/custom_material_app_bar.dart';
import 'package:cloudkeja/widgets/custom_cupertino_app_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final bool showUserProfileLeading;
  final VoidCallback? onUserProfileTap;
  final String? userProfileImageUrl; // For user avatar in leading
  final bool showChatAction;
  final bool showSettingsAction;

  const CustomAppBar({
    Key? key,
    required this.titleText,
    this.showUserProfileLeading = true, // Default for Material
    this.onUserProfileTap,
    this.userProfileImageUrl,
    this.showChatAction = true,
    this.showSettingsAction = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return CustomCupertinoAppBar(
        titleText: titleText,
        showUserProfileLeading: showUserProfileLeading, // Pass down
        onUserProfileTap: onUserProfileTap,
        userProfileImageUrl: userProfileImageUrl,
        showChatAction: showChatAction,
        showSettingsAction: showSettingsAction,
      );
    } else {
      return CustomMaterialAppBar(
        titleText: titleText,
        showUserProfileLeading: showUserProfileLeading,
        onUserProfileTap: onUserProfileTap,
        userProfileImageUrl: userProfileImageUrl,
        showChatAction: showChatAction,
        showSettingsAction: showSettingsAction,
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  // Both CustomMaterialAppBar and CustomCupertinoAppBar are designed to use kToolbarHeight
  // so the router can consistently return this.
  // If CustomCupertinoAppBar needed a different height (e.g. kMinInteractiveDimensionCupertino),
  // this getter would need to check the platform:
  // return Size.fromHeight(
  //   PlatformService.useCupertino // (this would need static access or instance from Provider if used here)
  //       ? kMinInteractiveDimensionCupertino
  //       : kToolbarHeight
  // );
  // But for this task, kToolbarHeight is used for both for simplicity and consistency.
}
