import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/widgets/recent_tenants_material.dart';
import 'package:cloudkeja/screens/landlord/widgets/recent_tenants_cupertino.dart';

class RecentTenantsWidget extends StatelessWidget {
  const RecentTenantsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return const RecentTenantsCupertinoWidget();
    } else {
      return const RecentTenantsMaterialWidget();
    }
  }
}
