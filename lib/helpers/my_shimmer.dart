import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for Cupertino
import 'package:provider/provider.dart'; // Added for Provider
import 'package:cloudkeja/services/platform_service.dart'; // Added for PlatformService
import 'package:shimmer/shimmer.dart';

class MyShimmer extends StatelessWidget {
  const MyShimmer({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);
    final bool isCupertino = platformService.useCupertino;

    Color baseColor;
    Color highlightColor;

    if (isCupertino) {
      baseColor = CupertinoColors.systemGrey5.resolveFrom(context);
      highlightColor = CupertinoColors.systemGrey4.resolveFrom(context);
    } else {
      final materialTheme = Theme.of(context);
      baseColor = materialTheme.colorScheme.surfaceVariant.withOpacity(0.5);
      highlightColor = materialTheme.colorScheme.surfaceVariant;
    }

    return Shimmer.fromColors(
        baseColor: baseColor, // Applied platform-adaptive color
        highlightColor: highlightColor, // Applied platform-adaptive color
        enabled: true,
        direction: ShimmerDirection.ltr,
        period: const Duration(milliseconds: 1500), // Adjusted period for typical shimmer
        child: child);
  }
}
