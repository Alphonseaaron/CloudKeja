import 'package:flutter/cupertino.dart';

class CupertinoPropertyTypePickerScreen extends StatelessWidget {
  final List<String> propertyTypes;
  final String? currentType;

  const CupertinoPropertyTypePickerScreen({
    Key? key,
    required this.propertyTypes,
    this.currentType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Select Property Type'),
        // PreviousPageTitle is auto-handled by CupertinoNavigationBar if pushed normally
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              children: propertyTypes.map((type) {
                final bool isSelected = type == currentType;
                return CupertinoListTile(
                  title: Text(type),
                  trailing: isSelected 
                      ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue) 
                      : null,
                  onTap: () {
                    Navigator.of(context).pop(type); // Return selected type
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
