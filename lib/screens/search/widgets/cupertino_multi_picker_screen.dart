import 'package:flutter/cupertino.dart';

class CupertinoMultiPickerScreen extends StatefulWidget {
  final String title;
  final List<String> allOptions;
  final List<String> initialSelectedOptions;

  const CupertinoMultiPickerScreen({
    Key? key,
    required this.title,
    required this.allOptions,
    required this.initialSelectedOptions,
  }) : super(key: key);

  @override
  State<CupertinoMultiPickerScreen> createState() => _CupertinoMultiPickerScreenState();
}

class _CupertinoMultiPickerScreenState extends State<CupertinoMultiPickerScreen> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List<String>.from(widget.initialSelectedOptions);
  }

  void _toggleSelection(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Done'),
          onPressed: () {
            Navigator.of(context).pop(_selectedOptions);
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              children: widget.allOptions.map((option) {
                final bool isSelected = _selectedOptions.contains(option);
                return CupertinoListTile(
                  title: Text(option),
                  trailing: isSelected 
                      ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue) 
                      : null,
                  onTap: () {
                    _toggleSelection(option);
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
