import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for Cupertino
import 'package:provider/provider.dart'; // Added for Provider
import 'package:cloudkeja/services/platform_service.dart'; // Added for PlatformService
import 'package:cloudkeja/helpers/my_shimmer.dart';

Widget cachedImage(
  BuildContext context, // Added context as first parameter
  String url, {
  double? width,
  double? height,
  BoxFit? fit,
}) {
  final platformService = Provider.of<PlatformService>(context, listen: false);
  final bool isCupertino = platformService.useCupertino;

  Widget placeholderIcon;
  Widget errorIconWidget;

  if (isCupertino) {
    final cupertinoTheme = CupertinoTheme.of(context);
    placeholderIcon = Icon(
      CupertinoIcons.house,
      color: CupertinoColors.systemGrey.resolveFrom(context), // Standard subtle color
    );
    errorIconWidget = Icon(
      CupertinoIcons.exclamationmark_circle,
      color: CupertinoColors.systemRed.resolveFrom(context), // Standard error color
    );
  } else {
    final materialTheme = Theme.of(context);
    placeholderIcon = Icon(
      Icons.house_outlined,
      color: materialTheme.colorScheme.onSurface.withOpacity(0.4),
    );
    errorIconWidget = Icon(
      Icons.error,
      color: materialTheme.colorScheme.error,
    );
  }

  return CachedNetworkImage(
    imageUrl: url,
    height: height,
    width: width,
    fit: fit,
    progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
      height: height,
      width: width,
      child: MyShimmer( // MyShimmer wraps the placeholder icon
        child: placeholderIcon,
      ),
    ),
    errorWidget: (context, url, error) => errorIconWidget, // Use platform-specific error icon
  );
}
