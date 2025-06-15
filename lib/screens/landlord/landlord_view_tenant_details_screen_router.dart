import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/landlord/landlord_view_tenant_details_screen_material.dart';
import 'package:cloudkeja/screens/landlord/landlord_view_tenant_details_screen_cupertino.dart';

class LandlordViewTenantDetailsScreenRouter extends StatelessWidget {
  final String tenantId;
  final String? leaseId; // leaseId is optional

  const LandlordViewTenantDetailsScreenRouter({
    Key? key,
    required this.tenantId,
    this.leaseId,
  }) : super(key: key);

  // static const String routeName = '/landlord-view-tenant-details-router'; // Optional

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return LandlordViewOfTenantDetailsScreenCupertino(
        key: key, // Pass key
        tenantId: tenantId,
        leaseId: leaseId,
      );
    } else {
      return LandlordViewOfTenantDetailsScreenMaterial(
        key: key, // Pass key
        tenantId: tenantId,
        leaseId: leaseId,
      );
    }
  }
}
