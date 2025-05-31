import 'package:flutter/cupertino.dart';

class CupertinoSelectServiceTypesPageStub extends StatelessWidget {
  const CupertinoSelectServiceTypesPageStub({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Select Service Types'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Done'),
          onPressed: () {
            // In a real implementation, this would pop with selected data.
            Navigator.of(context).pop();
          },
        ),
      ),
      child: const Center(
        child: Text('Service Type Selection List Placeholder'),
      ),
    );
  }
}
