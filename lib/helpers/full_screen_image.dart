import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/helpers/full_screen_image_material.dart';
import 'package:cloudkeja/helpers/full_screen_image_cupertino.dart';

class FullscreenImage extends StatelessWidget {
  final String image;

  const FullscreenImage({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return FullScreenImageCupertino(
        key: key, // Pass key
        image: image,
      );
    } else {
      return FullScreenImageMaterial(
        key: key, // Pass key
        image: image,
      );
    }
  }
}
