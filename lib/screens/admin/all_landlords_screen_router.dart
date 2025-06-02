import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/admin/all_landlords_screen_cupertino.dart';
import 'package:cloudkeja/screens/admin/all_landlords_screen_material.dart';

class AllLandlordsScreenRouter extends StatelessWidget {
  const AllLandlordsScreenRouter({Key? key}) : super(key: key);

  // It's good practice to define a static routeName if you plan to use named routes.
  static const String routeName = '/admin/all_landlords'; 

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const AllLandlordsScreenCupertino();
    } else {
      return const AllLandlordsScreenMaterial();
    }
  }
}
