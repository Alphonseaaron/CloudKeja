import 'package:flutter/material.dart';
import 'package:cloudkeja/helpers/line_graph.dart'; // Contains MyGraph
import 'package:draw_graph/models/feature.dart'; // For Feature model

class LandlordAnalyticsMaterial extends StatelessWidget {
  const LandlordAnalyticsMaterial({Key? key}) : super(key: key);

  // Example data for the graph - this would typically come from a provider or view model
  static List<Feature> _createSampleFeatures(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return [
      Feature(
        title: "Property Views",
        color: colorScheme.primary,
        data: [0.3, 0.5, 0.4, 0.7, 0.6, 0.9, 0.5],
      ),
      Feature(
        title: "Enquiries",
        color: colorScheme.secondary,
        data: [0.1, 0.2, 0.3, 0.2, 0.4, 0.5, 0.3],
      ),
      Feature(
        title: "New Listings",
        color: colorScheme.tertiary,
        data: [0.5, 0.4, 0.6, 0.3, 0.7, 0.2, 0.4],
      ),
      // Example of using a theme-derived container color for a feature
      Feature(
        title: "Maintenance Requests",
        color: colorScheme.primaryContainer, 
        data: [0.2, 0.1, 0.1, 0.3, 0.2, 0.1, 0.05],
      ),
    ];
  }

  static const List<String> _sampleLabelX = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _sampleLabelY = ['Low', 'Med', 'High', 'V.High']; // Adjusted for typical analytics

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final List<Feature> features = _createSampleFeatures(context);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Landlord Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: MyGraph(
                features: features,
                labelX: _sampleLabelX,
                labelY: _sampleLabelY,
                title: 'Weekly Activity Overview', // Pass title to MyGraph
              ),
            )
          ),
          const SizedBox(height: 20),
          // Placeholder for more stats
          Text("Summary Statistics", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Properties: 15", style: textTheme.bodyLarge), // Example stat
                  const SizedBox(height: 8),
                  Text("Occupancy Rate: 85%", style: textTheme.bodyLarge), // Example stat
                  const SizedBox(height: 8),
                  Text("Average Enquiries/Week: 25", style: textTheme.bodyLarge), // Example stat
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
