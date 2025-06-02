import 'package:flutter/material.dart';
import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';

class MyGraph extends StatelessWidget {
  final List<Feature> features;
  final List<String> labelX;
  final List<String> labelY;
  final String? title; // Optional title for the graph

  const MyGraph({
    Key? key,
    required this.features,
    required this.labelX,
    required this.labelY,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // The 'features' data is now passed in.
    // Color adjustments for specific hardcoded colors can be done when features are defined by the caller.
    // Or, this widget could enforce theme colors if necessary.
    // For this refactor, we assume the caller will provide themed Feature objects.

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (title != null && title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                title!,
                style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
              ),
            ),
          LineGraph(
            features: features, // Use passed-in features
            size: const Size(340, 400), // Consider making this adaptable
            labelX: labelX, // Use passed-in labels
            labelY: labelY, // Use passed-in labels
            showDescription: true,
            graphColor: colorScheme.onSurface.withOpacity(0.6),
            graphOpacity: 0.2,
            verticalFeatureDirection: true,
            descriptionHeight: 130, // Adjust if needed based on number of features
            fontFamily: textTheme.bodySmall?.fontFamily,
          ),
        ],
      ),
    );
  }
}
