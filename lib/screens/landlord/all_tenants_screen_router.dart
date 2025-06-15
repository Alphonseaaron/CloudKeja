import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/all_tenants_screen_material.dart';
import 'package:cloudkeja/screens/landlord/all_tenants_screen_cupertino.dart';

class AllTenantsScreenRouter extends StatelessWidget {
  const AllTenantsScreenRouter({Key? key}) : super(key: key);

  // static const String routeName = '/all-tenants'; // Optional: if used in named routes

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return const AllTenantsScreenCupertino();
    } else {
      return const AllTenantsScreenMaterial();
    }
  }
}
