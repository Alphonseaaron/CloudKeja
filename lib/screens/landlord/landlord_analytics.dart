import 'package:flutter/material.dart';
import 'package:cloudkeja/helpers/line_graph.dart'; // Contains MyGraph

class LandlordAnalytics extends StatelessWidget {
  const LandlordAnalytics({Key? key}) : super(key: key);

  static const String routeName = '/landlord-analytics'; // Optional: for named routing

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Themed background
      appBar: AppBar(
        title: const Text('Landlord Analytics'), // Uses AppBarTheme
        // Add other AppBar properties if needed, e.g., actions
      ),
      body: ListView( // Using ListView for potential future additions
        padding: const EdgeInsets.all(16.0), // Overall padding for the page content
        children: [
          // Optional: Section Title for the graph
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Weekly Activity Overview', // Example title
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // The MyGraph widget, which has been internally themed
          // It's wrapped in a Card for better visual grouping and elevation from CardTheme.
          Card(
            // Card uses CardTheme from AppTheme
            // elevation: theme.cardTheme.elevation,
            // shape: theme.cardTheme.shape,
            // color: theme.cardTheme.color, // Or a specific surface color
            // margin: theme.cardTheme.margin, // Default margin from CardTheme is usually fine
            child: Padding(
              // Padding inside the card, before the graph itself if MyGraph doesn't have its own
              padding: const EdgeInsets.all(12.0),
              child: MyGraph(), // MyGraph was themed in Subtask 9.16
            )
          ),

          // Example: Add more analytic components or summaries here later
          // const SizedBox(height: 20),
          // Text("Other Stats Placeholder", style: textTheme.titleMedium),
          // Card(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Text("More details...", style: textTheme.bodyMedium),
          //   ),
          // ),
        ],
      ),
    );
  }
}
