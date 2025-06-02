import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/models/space_model.dart'; // Needed to accept SpaceModel
import 'package:cloudkeja/screens/details/details_screen_cupertino.dart';
import 'package:cloudkeja/screens/details/details_screen_material.dart';

class DetailsScreenRouter extends StatelessWidget {
  final SpaceModel space;

  const DetailsScreenRouter({
    Key? key,
    required this.space,
  }) : super(key: key);
  
  // It's good practice to define a static routeName if you plan to use named routes.
  // This also helps avoid typos when navigating.
  static const String routeName = '/details'; // Example, align with actual usage

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return DetailsScreenCupertino(space: space);
    } else {
      return DetailsScreenMaterial(space: space);
    }
  }
}
