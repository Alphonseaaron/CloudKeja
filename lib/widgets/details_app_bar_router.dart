import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/models/space_model.dart'; // Needed to accept SpaceModel
import 'package:cloudkeja/widgets/details_app_bar_cupertino.dart';
import 'package:cloudkeja/widgets/details_app_bar_material.dart';

class DetailsAppBarRouter extends StatelessWidget {
  final SpaceModel space;

  const DetailsAppBarRouter({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return DetailsAppBarCupertino(space: space);
    } else {
      return DetailsAppBarMaterial(space: space);
    }
  }
}
