import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/admin/admin_dashboard_cupertino.dart';
import 'package:cloudkeja/screens/admin/admin_dashboard_material.dart';

class AdminDashboardRouter extends StatelessWidget {
  const AdminDashboardRouter({Key? key}) : super(key: key);

  // Optional: Define a static routeName if you intend to use named routes for this router.
  // static const String routeName = '/admin_dashboard'; // Example

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const AdminDashboardCupertino();
    } else {
      return const AdminDashboardMaterial();
    }
  }
}
