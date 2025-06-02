import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/add_space_screen_cupertino.dart';
import 'package:cloudkeja/screens/landlord/add_space_screen_material.dart';

class AddSpaceScreenRouter extends StatelessWidget {
  const AddSpaceScreenRouter({Key? key}) : super(key: key);

  static const String routeName = '/add_space'; 

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const AddSpaceScreenCupertino();
    } else {
      return const AddSpaceScreenMaterial();
    }
  }
}
