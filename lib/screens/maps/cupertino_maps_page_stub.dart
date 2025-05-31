import 'package:flutter/cupertino.dart';

class CupertinoMapsPageStub extends StatelessWidget {
  const CupertinoMapsPageStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Map'),
      ),
      child: Center(
        child: Text('Cupertino Map Content'),
      ),
    );
  }
}
