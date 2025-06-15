import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/profile/tenant_details_screen_material.dart';
import 'package:cloudkeja/screens/profile/tenant_details_screen_cupertino.dart';

class TenantDetailsScreen extends StatelessWidget {
  final SpaceModel space;

  const TenantDetailsScreen({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return TenantDetailsScreenCupertino(
        key: key, // Pass key if needed for framework
        space: space,
      );
    } else {
      return TenantDetailsScreenMaterial(
        key: key, // Pass key
        space: space,
      );
    }
  }
}
