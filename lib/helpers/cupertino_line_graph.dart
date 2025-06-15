import 'package:flutter/cupertino.dart';
import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';

class CupertinoLineGraph extends StatelessWidget { // Renamed class
  final List<Feature> features;
  final List<String> labelX;
  final List<String> labelY;
  final String? title; // Optional title for the graph

  const CupertinoLineGraph({ // Renamed constructor
    Key? key,
    required this.features,
    required this.labelX,
    required this.labelY,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    // Access Cupertino text styles directly from theme.textTheme
    final baseTextStyle = theme.textTheme.textStyle;
    final titleTextStyle = theme.textTheme.navTitleTextStyle; // Example for a title

    // Caller should provide Feature objects with colors appropriate for Cupertino theme.
    // Example: Feature(title: "Data", color: theme.primaryColor, data: [...])

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
                style: titleTextStyle.copyWith(color: theme.textTheme.textStyle.color), // Use a prominent style
              ),
            ),
          LineGraph(
            features: features,
            size: const Size(340, 400), // Consider making this adaptable
            labelX: labelX,
            labelY: labelY,
            showDescription: true,
            graphColor: theme.textTheme.textStyle.color ?? CupertinoColors.label.resolveFrom(context), // Color for axes and labels
            graphOpacity: 0.2, // Opacity for area under lines
            verticalFeatureDirection: true,
            descriptionHeight: 130,
            fontFamily: baseTextStyle.fontFamily, // Use themed font family
          ),
        ],
      ),
    );
  }
}
