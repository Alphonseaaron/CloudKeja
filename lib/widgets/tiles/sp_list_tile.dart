import 'package:flutter/widgets.dart';
import 'package:cloudkeja/models/user_model.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/widgets/tiles/sp_list_tile_material.dart';
import 'package:cloudkeja/widgets/tiles/sp_list_tile_cupertino.dart';
import 'package:provider/provider.dart';

class SPListTile extends StatelessWidget {
  final UserModel serviceProvider;
  final bool isSkeleton;

  const SPListTile({
    Key? key,
    required this.serviceProvider,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return SPListTileCupertino(
        key: key,
        serviceProvider: serviceProvider,
        isSkeleton: isSkeleton,
      );
    } else {
      return SPListTileMaterial(
        key: key,
        serviceProvider: serviceProvider,
        isSkeleton: isSkeleton,
      );
    }
  }
}

// Skeleton widget router
class SPListTileSkeleton extends StatelessWidget {
  const SPListTileSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      // Assuming SPListTileCupertinoSkeleton is defined in sp_list_tile_cupertino.dart
      // and SPListTileMaterialSkeleton in sp_list_tile_material.dart
      // We need to import them if they are separate classes.
      // For this refactor, I created them within their respective platform files.
      return const SPListTileCupertinoSkeleton();
    } else {
      return const SPListTileMaterialSkeleton();
    }
  }
}
