import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel parameter
import 'package:cloudkeja/screens/profile/edit_profile_screen_cupertino.dart';
import 'package:cloudkeja/screens/profile/edit_profile_screen_material.dart';

class EditProfileScreenRouter extends StatelessWidget {
  final UserModel user;

  const EditProfileScreenRouter({
    Key? key,
    required this.user,
  }) : super(key: key);
  
  static const String routeName = '/edit_profile'; 

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return EditProfileScreenCupertino(user: user);
    } else {
      // EditProfileScreenMaterial currently gets user from AuthProvider.
      // For consistency and to support editing other users (if admin),
      // it should also be adapted to take UserModel user as a parameter.
      // For now, assuming it will be refactored or primarily edits current user.
      // If EditProfileScreenMaterial is to take a user model, it should be:
      // return EditProfileScreenMaterial(user: user);
      // However, its current implementation (read in previous step) gets user from Provider.
      // This is an inconsistency that should be resolved.
      // For this step, I will keep its current behavior and not pass user.
      // TODO: Refactor EditProfileScreenMaterial to accept UserModel via constructor for consistency.
      return EditProfileScreenMaterial(); 
    }
  }
}
