import 'package:flutter/widgets.dart';
import 'package:cloudkeja/models/sp_job_model.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/widgets/tiles/sp_job_history_tile_material.dart';
import 'package:cloudkeja/widgets/tiles/sp_job_history_tile_cupertino.dart';
import 'package:provider/provider.dart';

class SPJobHistoryTile extends StatelessWidget {
  final SPJobModel job;
  final bool isSkeleton;

  const SPJobHistoryTile({
    Key? key,
    required this.job,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return SPJobHistoryTileCupertino(
        key: key,
        job: job,
        isSkeleton: isSkeleton,
      );
    } else {
      return SPJobHistoryTileMaterial(
        key: key,
        job: job,
        isSkeleton: isSkeleton,
      );
    }
  }
}
