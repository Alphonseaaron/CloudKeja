import 'package:flutter/material.dart';
import 'package:cloudkeja/helpers/line_graph.dart';

class LandlordAnalytics extends StatelessWidget {
  const LandlordAnalytics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(children: [
        MyGraph(),
      ]),
    );
  }
}
