import 'package:flutter/cupertino.dart';

class CupertinoLoginPageStub extends StatelessWidget {
  const CupertinoLoginPageStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Login - Cupertino'),
      ),
      child: Center(
        child: Text('Cupertino Login Page Stub'),
      ),
    );
  }
}
