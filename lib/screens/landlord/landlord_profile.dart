import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel type
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/landlord_profile_material.dart';
import 'package:cloudkeja/screens/landlord/landlord_profile_cupertino.dart';

// Renamed original LandlordProfile to LandlordProfileRouter to act as the router
class LandlordProfileRouter extends StatelessWidget {
  final UserModel user;

  const LandlordProfileRouter({
    Key? key,
    required this.user,
  }) : super(key: key);

  // static const String routeName = '/landlord-profile'; // Optional: if used in named routes

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return LandlordProfileCupertino(
        key: key, // Pass key
        user: user,
      );
    } else {
      return LandlordProfileMaterial(
        key: key, // Pass key
        user: user,
      );
    }
  }
}
