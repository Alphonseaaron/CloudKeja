import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/landlord_analytics_cupertino.dart';
import 'package:cloudkeja/screens/landlord/landlord_analytics_material.dart';

class LandlordAnalytics extends StatelessWidget {
  const LandlordAnalytics({Key? key}) : super(key: key);

  static const String routeName = '/landlord-analytics'; // Optional: for named routing

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const LandlordAnalyticsCupertino();
    } else {
      return const LandlordAnalyticsMaterial();
    }
  }
}
