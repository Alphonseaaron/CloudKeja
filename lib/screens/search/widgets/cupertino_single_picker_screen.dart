import 'package:flutter/cupertino.dart';

class CupertinoSinglePickerScreen extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? currentSelection;

  const CupertinoSinglePickerScreen({
    Key? key,
    required this.title,
    required this.options,
    this.currentSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        // previousPageTitle will be automatically handled by CupertinoPageRoute
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              children: options.map((option) {
                final bool isSelected = option == currentSelection;
                return CupertinoListTile(
                  title: Text(option),
                  trailing: isSelected 
                      ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue) 
                      : null,
                  onTap: () {
                    Navigator.of(context).pop(option); // Return selected option
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
