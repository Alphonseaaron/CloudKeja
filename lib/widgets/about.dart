import 'package:flutter/material.dart';
import 'package:cloudkeja/models/space_model.dart';

class About extends StatelessWidget {
  const About({Key? key, required this.space}) : super(key: key);
  final SpaceModel space;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      // Use M3 standard padding or adjust as per overall design language
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: textTheme.titleLarge?.copyWith(
                // fontWeight: FontWeight.bold, // titleLarge from theme might already be bold
                // color: colorScheme.onBackground, // Default from textTheme.apply
                ),
          ),
          const SizedBox(height: 8.0), // M3 standard spacing
          Text(
            space.description ?? 'No description available.', // Handle null description
            style: textTheme.bodyMedium?.copyWith(
                // color: colorScheme.onBackground.withOpacity(0.85), // Default from textTheme.apply
                // Ensure line height is comfortable if text is long
                height: 1.5, 
                ),
          )
        ],
      ),
    );
  }
}
