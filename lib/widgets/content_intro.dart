import 'package:flutter/material.dart';
import 'package:cloudkeja/models/space_model.dart';

class ContentIntro extends StatelessWidget {
  final SpaceModel space;

  const ContentIntro({
    Key? key,
    required this.space,
  }) : super(key: key);

  String _getRentTimeText() {
    // Default to "Per Month" if rentTime is null or not recognized
    switch (space.rentTime) {
      case 1:
        return '/ Month'; // Changed to include slash for better visual separation
      case 7:
        return '/ Week';
      case 30:
        return '/ Month';
      case 365: // Assuming 365 might mean per year
        return '/ Year';
      default:
        return '/ Month'; // Sensible default
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Placeholder for area if not available in model
    final String areaText = space.area?.toString() ?? 'N/A'; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            space.spaceName ?? 'Unnamed Space',
            style: textTheme.titleLarge?.copyWith(
                // fontWeight: FontWeight.bold, // titleLarge might already be bold
                // color: colorScheme.onBackground // Default
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            space.address ?? 'No address provided',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12.0),
          // Displaying area - Assuming 'area' might be a field in SpaceModel
          // If not, this part can be adjusted or removed.
          // For now, using the hardcoded '500 sqft' as a placeholder if space.area is null.
          Text(
            (space.area != null ? '${space.area} sqft' : 'Area not specified'),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8.0), // Adjusted spacing
          RichText(
            text: TextSpan(
              style: textTheme.titleMedium, // Base style for the RichText
              children: [
                TextSpan(
                  text: 'KES ${space.price?.toStringAsFixed(0) ?? 'N/A'}',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: _getRentTimeText(),
                  style: textTheme.bodySmall?.copyWith( // Smaller for "/ Month" part
                    color: colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
