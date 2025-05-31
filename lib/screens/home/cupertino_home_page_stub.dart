import 'package:flutter/cupertino.dart';

class CupertinoHomePageStub extends StatelessWidget {
  const CupertinoHomePageStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Home'),
      ),
      child: Center(
        child: Text('Cupertino Home Content'),
      ),
    );
  }
}
