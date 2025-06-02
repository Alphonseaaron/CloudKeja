import 'package:flutter/cupertino.dart';

class _CupertinoMultiSelectPage extends StatefulWidget {
  final List<String> allOptions;
  final List<String> initiallySelectedOptions;
  final String pageTitle;

  const _CupertinoMultiSelectPage({
    Key? key,
    required this.allOptions,
    required this.initiallySelectedOptions,
    required this.pageTitle,
  }) : super(key: key);

  @override
  _CupertinoMultiSelectPageState createState() => _CupertinoMultiSelectPageState();
}

class _CupertinoMultiSelectPageState extends State<_CupertinoMultiSelectPage> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    // Create a copy to manage locally
    _selectedOptions = List<String>.from(widget.initiallySelectedOptions);
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
        middle: Text(widget.pageTitle),
        // previousPageTitle: 'Back', // Optional: if you want to specify
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Done'),
          onPressed: () {
            Navigator.of(context).pop(_selectedOptions);
          },
        ),
      ),
      child: SafeArea( // Ensure content is not obscured by status bar or notch
        child: ListView.builder(
          itemCount: widget.allOptions.length,
          itemBuilder: (context, index) {
            final option = widget.allOptions[index];
            final bool isSelected = _selectedOptions.contains(option);
            return CupertinoListTile(
              title: Text(option),
              onTap: () {
                _toggleSelection(option);
              },
              trailing: isSelected
                  ? Icon(CupertinoIcons.check_mark, color: CupertinoTheme.of(context).primaryColor)
                  : null, // No icon if not selected
              // Adding a visual cue for selection state change might be nice
              // e.g. changing background color, but simple checkmark is standard.
            );
          },
        ),
      ),
    );
  }
}
