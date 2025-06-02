import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/models/maintenance_request_model.dart';
import 'package:cloudkeja/widgets/tiles/maintenance_request_tile_cupertino.dart';
import 'package:cloudkeja/widgets/tiles/maintenance_request_tile_material.dart';

class MaintenanceRequestTileRouter extends StatelessWidget {
  final MaintenanceRequestModel maintenanceRequest;

  const MaintenanceRequestTileRouter({
    Key? key,
    required this.maintenanceRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return MaintenanceRequestTileCupertino(maintenanceRequest: maintenanceRequest);
    } else {
      return MaintenanceRequestTileMaterial(maintenanceRequest: maintenanceRequest);
    }
  }
}
