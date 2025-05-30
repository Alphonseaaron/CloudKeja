import 'package:flutter/material.dart';
import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';

class MyGraph extends StatelessWidget {
  const MyGraph({Key? key}) : super(key: key); // Added const constructor

  // features list is now built inside the build method to access theme.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Define features with themed colors
    final List<Feature> features = [
      Feature(
        title: "Drink Water",
        color: colorScheme.primary, // Themed color
        data: [0.2, 0.8, 0.4, 0.7, 0.6],
      ),
      Feature(
        title: "Exercise",
        color: colorScheme.secondary, // Themed color
        data: [1, 0.8, 0.6, 0.7, 0.3],
      ),
      Feature(
        title: "Study",
        color: colorScheme.tertiary, // Themed color
        data: [0.5, 0.4, 0.85, 0.4, 0.7],
      ),
      Feature(
        title: "Water Plants",
        color: Colors.green.shade600, // Using a specific green, ensure it works in dark/light
        // Or, use another theme color: colorScheme.primaryContainer,
        data: [0.6, 0.2, 0, 0.1, 1],
      ),
      Feature(
        title: "Grocery Shopping",
        color: Colors.orange.shade600, // Using a specific orange
        // Or, use another theme color: colorScheme.secondaryContainer,
        data: [0.25, 1, 0.3, 0.8, 0.6],
      ),
    ];

    return Container( // Wrap in a container if a specific background for the graph area is needed
      // color: colorScheme.surfaceContainerLowest, // Example themed background for the graph's container
      padding: const EdgeInsets.all(8.0), // Optional padding around the graph
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Optional: Add a title for the graph using themed text
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 16.0),
          //   child: Text(
          //     "Weekly Activity Progress",
          //     style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
          //   ),
          // ),
          LineGraph(
            features: features,
            size: const Size(340, 400), // Adjusted size for better fit with padding
            labelX: const ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5'],
            labelY: const ['20%', '40%', '60%', '80%', '100%'], // These are static labels
            showDescription: true,
            graphColor: colorScheme.onSurface.withOpacity(0.6), // Color for axes and labels
            graphOpacity: 0.2, // Opacity for area under lines (uses feature color with this opacity)
            verticalFeatureDirection: true,
            descriptionHeight: 130,
            fontFamily: textTheme.bodySmall?.fontFamily, // Use themed font family
          ),
        ],
      ),
    );
  }
}
