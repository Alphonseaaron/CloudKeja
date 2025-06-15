import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/finances/finance_overview_screen_material.dart';
import 'package:cloudkeja/screens/landlord/finances/finance_overview_screen_cupertino.dart';

class FinanceOverviewScreenRouter extends StatelessWidget {
  const FinanceOverviewScreenRouter({Key? key}) : super(key: key);

  // static const String routeName = '/finance-overview'; // Optional

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return const FinanceOverviewScreenCupertino();
    } else {
      return const FinanceOverviewScreenMaterial();
    }
  }
}
