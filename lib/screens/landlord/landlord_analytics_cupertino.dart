import 'package:flutter/cupertino.dart';
import 'package:cloudkeja/helpers/cupertino_line_graph.dart'; // CupertinoMyGraph
import 'package:draw_graph/models/feature.dart'; // For Feature model

class LandlordAnalyticsCupertino extends StatelessWidget {
  const LandlordAnalyticsCupertino({Key? key}) : super(key: key);

  // Example data for the graph - this would typically come from a provider or view model
  static List<Feature> _createSampleFeatures(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    // Use Cupertino-appropriate colors
    return [
      Feature(
        title: "Property Views",
        color: theme.primaryColor,
        data: [0.3, 0.5, 0.4, 0.7, 0.6, 0.9, 0.5],
      ),
      Feature(
        title: "Enquiries",
        color: theme.primaryContrastingColor, // Example, can be any distinct color
        data: [0.1, 0.2, 0.3, 0.2, 0.4, 0.5, 0.3],
      ),
      Feature(
        title: "New Listings",
        color: CupertinoColors.systemGreen.resolveFrom(context), // Example color
        data: [0.5, 0.4, 0.6, 0.3, 0.7, 0.2, 0.4],
      ),
      Feature(
        title: "Maintenance Requests",
        color: CupertinoColors.systemOrange.resolveFrom(context), // Example color
        data: [0.2, 0.1, 0.1, 0.3, 0.2, 0.1, 0.05],
      ),
    ];
  }

  static const List<String> _sampleLabelX = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _sampleLabelY = ['Low', 'Med', 'High', 'V.High'];

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final List<Feature> features = _createSampleFeatures(context);
    final baseTextStyle = theme.textTheme.textStyle;
    final sectionHeaderStyle = theme.textTheme.navTitleTextStyle.copyWith(
      fontSize: 18, // Slightly smaller than default nav title for section headers
      color: theme.textTheme.textStyle.color
    );


    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Landlord Analytics'),
      ),
      child: SafeArea( // Ensure content is not obscured by status bar or notch
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Graph section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: theme.barBackgroundColor, // Use a card-like background
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: CupertinoMyGraph(
                features: features,
                labelX: _sampleLabelX,
                labelY: _sampleLabelY,
                title: 'Weekly Activity Overview',
              ),
            ),
            const SizedBox(height: 24),

            // Summary Statistics Section
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0), // Align with list section header if used
              child: Text("Summary Statistics", style: sectionHeaderStyle),
            ),
            CupertinoListSection.insetGrouped(
              backgroundColor: theme.scaffoldBackgroundColor, // Match page background
              margin: EdgeInsets.zero, // Remove default margin for seamless look with title
              children: [
                CupertinoListTile(
                  title: Text("Total Properties", style: baseTextStyle),
                  additionalInfo: Text("15", style: baseTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                ),
                CupertinoListTile(
                  title: Text("Occupancy Rate", style: baseTextStyle),
                  additionalInfo: Text("85%", style: baseTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                ),
                CupertinoListTile(
                  title: Text("Average Enquiries/Week", style: baseTextStyle),
                  additionalInfo: Text("25", style: baseTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
