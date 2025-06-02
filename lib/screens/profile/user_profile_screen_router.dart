import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/profile/user_profile_screen_cupertino.dart';
import 'package:cloudkeja/screens/profile/user_profile_screen_material.dart';
// No need to import UserModel here if we only pass userId

class UserProfileScreenRouter extends StatelessWidget {
  final String? userId; // Optional: if null, shows current user's profile

  const UserProfileScreenRouter({
    Key? key,
    this.userId,
  }) : super(key: key);
  
  static const String routeName = '/user_profile'; 

  @override
  Widget build(BuildContext context) {
    // The platform-specific screens will handle fetching the current user 
    // if userId is null, or fetching the specified user if userId is provided.
    if (PlatformService.useCupertino) {
      return UserProfileScreenCupertino(userId: userId);
    } else {
      return UserProfileScreenMaterial(); // UserProfileScreenMaterial currently doesn't accept userId, assumes current user.
                                        // This might need to be adapted if viewing other profiles is a Material feature too.
                                        // For now, assuming Material version is primarily for current user.
                                        // If Material needs to view other profiles, it should also accept userId.
    }
  }
}
