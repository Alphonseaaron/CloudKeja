import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/details/space_location_material.dart';
import 'package:cloudkeja/screens/details/space_location_cupertino.dart';

class SpaceLocation extends StatelessWidget {
  final LatLng? location;
  final String? imageUrl;
  final String? spaceName;

  const SpaceLocation({
    Key? key,
    required this.location,
    this.imageUrl,
    this.spaceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return SpaceLocationCupertino(
        key: key,
        location: location,
        imageUrl: imageUrl,
        spaceName: spaceName,
      );
    } else {
      return SpaceLocationMaterial(
        key: key,
        location: location,
        imageUrl: imageUrl,
        spaceName: spaceName,
      );
    }
  }
}
