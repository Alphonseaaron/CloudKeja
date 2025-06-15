import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart'; // For SpaceModel type
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/edit_space_screen_material.dart';
import 'package:cloudkeja/screens/landlord/edit_space_screen_cupertino.dart';

class EditSpaceScreenRouter extends StatelessWidget {
  final SpaceModel space;

  const EditSpaceScreenRouter({
    Key? key,
    required this.space,
  }) : super(key: key);

  // static const String routeName = '/edit-space'; // Optional: if used in named routes

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return EditSpaceScreenCupertino(
        key: key, // Pass key
        space: space,
      );
    } else {
      return EditSpaceScreenMaterial(
        key: key, // Pass key
        space: space,
      );
    }
  }
}
