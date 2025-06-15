import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/landlord_dashboard_material.dart';
import 'package:cloudkeja/screens/landlord/landlord_dashboard_cupertino.dart';

class LandlordDashboardRouter extends StatelessWidget {
  const LandlordDashboardRouter({Key? key}) : super(key: key);

  // static const String routeName = '/landlord-dashboard'; // Optional: if used in named routes

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return const LandlordDashboardCupertino();
    } else {
      return const LandlordDashboardMaterial();
    }
  }
}
