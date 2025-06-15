import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/landlord_spaces_material.dart';
import 'package:cloudkeja/screens/landlord/landlord_spaces_cupertino.dart';

class LandlordSpacesRouter extends StatelessWidget {
  const LandlordSpacesRouter({Key? key}) : super(key: key);

  // static const String routeName = '/landlord-spaces'; // Optional: if used in named routes

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return const LandlordSpacesCupertino();
    } else {
      return const LandlordSpacesMaterial();
    }
  }
}
