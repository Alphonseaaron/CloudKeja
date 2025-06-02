import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/service_provider/sp_earnings_report_screen_cupertino.dart';
import 'package:cloudkeja/screens/service_provider/sp_earnings_report_screen_material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:cloudkeja/providers/job_provider.dart'; // Import JobProvider
import 'package:cloudkeja/screens/service_provider/sp_earnings_report_controller.dart'; // Import Controller

class SPEarningsReportScreen extends StatelessWidget {
  const SPEarningsReportScreen({Key? key}) : super(key: key);
  static const String routeName = '/sp-earnings-report';

  @override
  Widget build(BuildContext context) {
    // It's important that SPEarningsReportController is provided above this router
    // or handled within each platform-specific screen if not using a shared Provider instance here.
    // For this example, we'll assume SPEarningsReportController will be instantiated
    // within the platform-specific screens, which already provide JobProvider.
    // If a single instance of SPEarningsReportController is desired for both,
    // it should be provided higher up in the widget tree, e.g., via a ChangeNotifierProvider.

    // However, the controller was designed to take JobProvider in its constructor.
    // The platform-specific screens are already creating the controller and providing JobProvider.
    // So, this dispatcher just needs to route to the correct screen.

    if (PlatformService.useCupertino) {
      return const SPEarningsReportScreenCupertino();
    } else {
      return const SPEarningsReportScreenMaterial();
    }
  }
}
