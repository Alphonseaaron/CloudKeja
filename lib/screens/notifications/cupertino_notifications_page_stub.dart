import 'package:flutter/cupertino.dart';

class CupertinoNotificationsPageStub extends StatelessWidget {
  const CupertinoNotificationsPageStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Notifications'),
      ),
      child: Center(
        child: Text('Cupertino Notifications Content'),
      ),
    );
  }
}
