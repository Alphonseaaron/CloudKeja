import 'package:flutter/cupertino.dart';

class CupertinoAdminDashboardStub extends StatelessWidget {
  const CupertinoAdminDashboardStub({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Admin Dashboard - Cupertino'),
      ),
      child: Center(
        child: Text('Cupertino Admin Dashboard Stub'),
      ),
    );
  }
}
