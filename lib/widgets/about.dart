import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for CupertinoTheme
import 'package:provider/provider.dart'; // Added for Provider
import 'package:cloudkeja/services/platform_service.dart'; // Added for PlatformService
import 'package:cloudkeja/models/space_model.dart';

class About extends StatelessWidget {
  const About({Key? key, required this.space}) : super(key: key);
  final SpaceModel space;

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);
    final bool isCupertino = platformService.useCupertino;

    TextStyle? titleTextStyle;
    TextStyle? descriptionTextStyle;

    if (isCupertino) {
      final cupertinoTheme = CupertinoTheme.of(context);
      titleTextStyle = cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
        fontWeight: FontWeight.bold, // Ensure it's bold for a section title
        color: CupertinoColors.label.resolveFrom(context), // Standard label color
      );
      descriptionTextStyle = cupertinoTheme.textTheme.textStyle.copyWith(
        height: 1.4, // Line height for readability
        color: CupertinoColors.secondaryLabel.resolveFrom(context), // Standard secondary text color
      );
    } else {
      final materialTheme = Theme.of(context);
      titleTextStyle = materialTheme.textTheme.titleLarge?.copyWith(
          // fontWeight is often part of titleLarge by default in M3
          // color: materialTheme.colorScheme.onBackground, // Default if not specified
          );
      descriptionTextStyle = materialTheme.textTheme.bodyMedium?.copyWith(
          // color: materialTheme.colorScheme.onBackground.withOpacity(0.85), // Default if not specified
          height: 1.5,
          );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Slightly increased vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: titleTextStyle,
          ),
          const SizedBox(height: 8.0),
          Text(
            space.description ?? 'No description available.',
            style: descriptionTextStyle,
          )
        ],
      ),
    );
  }
}
