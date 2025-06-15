import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/helpers/line_graph.dart'; // Will contain MaterialLineGraph
import 'package:cloudkeja/helpers/cupertino_line_graph.dart'; // Will contain CupertinoLineGraph
import 'package:draw_graph/models/feature.dart'; // For Feature type

class AdaptiveLineGraph extends StatelessWidget {
  final List<Feature> features;
  final List<String> labelX;
  final List<String> labelY;
  final String? title;

  const AdaptiveLineGraph({
    Key? key,
    required this.features,
    required this.labelX,
    required this.labelY,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return CupertinoLineGraph(
        key: key,
        features: features,
        labelX: labelX,
        labelY: labelY,
        title: title,
      );
    } else {
      return MaterialLineGraph(
        key: key,
        features: features,
        labelX: labelX,
        labelY: labelY,
        title: title,
      );
    }
  }
}
