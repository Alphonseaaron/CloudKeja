import 'package:flutter/cupertino.dart';

class CupertinoSettingsPageStub extends StatelessWidget {
  const CupertinoSettingsPageStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: Center(
        child: Text('Cupertino Settings Content'),
      ),
    );
  }
}
