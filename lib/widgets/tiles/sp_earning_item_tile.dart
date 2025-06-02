import 'package:flutter/widgets.dart'; // Using WidgetsFlutterBinding
import 'package:cloudkeja/models/sp_job_model.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/widgets/tiles/sp_earning_item_tile_material.dart';
import 'package:cloudkeja/widgets/tiles/sp_earning_item_tile_cupertino.dart';
import 'package:provider/provider.dart';

class SPEarningItemTile extends StatelessWidget {
  final SPJobModel job;
  final bool isSkeleton;

  const SPEarningItemTile({
    Key? key,
    required this.job,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return SPEarningItemTileCupertino(
        key: key,
        job: job,
        isSkeleton: isSkeleton,
      );
    } else {
      return SPEarningItemTileMaterial(
        key: key,
        job: job,
        isSkeleton: isSkeleton,
      );
    }
  }
}
