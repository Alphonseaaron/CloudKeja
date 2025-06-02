import 'package:flutter/cupertino.dart';

class MyDropDownCupertino extends StatefulWidget {
  const MyDropDownCupertino({
    Key? key,
    this.hintText,
    required this.selectedOption,
    this.options,
    this.currentValue,
  }) : super(key: key);

  final String? hintText;
  final List<String>? options;
  final Function(String option) selectedOption;
  final String? currentValue;

  @override
  State<MyDropDownCupertino> createState() => _MyDropDownCupertinoState();
}

class _MyDropDownCupertinoState extends State<MyDropDownCupertino> {
  String? _locallySelectedOption;

  @override
  void initState() {
    super.initState();
    _locallySelectedOption = widget.currentValue;
  }

  @override
  void didUpdateWidget(covariant MyDropDownCupertino oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      setState(() {
        _locallySelectedOption = widget.currentValue;
      });
    }
  }

  void _showPicker(BuildContext context) {
    if (widget.options == null || widget.options!.isEmpty) return;

    final List<String> pickerOptions = List<String>.from(widget.options ?? []);
    pickerOptions.sort(); // Sort for consistent picker order

    int initialItemIndex = 0;
    if (_locallySelectedOption != null && pickerOptions.contains(_locallySelectedOption!)) {
      initialItemIndex = pickerOptions.indexOf(_locallySelectedOption!);
    } else if (pickerOptions.isNotEmpty) {
       // If no current value or current value not in options, select first item by default
      // _locallySelectedOption = pickerOptions[0]; // Optionally pre-select first if none selected
    }


    String tempSelectedValue = _locallySelectedOption ?? (pickerOptions.isNotEmpty ? pickerOptions[initialItemIndex] : '');
    
    FixedExtentScrollController scrollController = FixedExtentScrollController(initialItem: initialItemIndex);


    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250, // Adjust height as needed
          color: CupertinoTheme.of(context).scaffoldBackgroundColor, // Use theme background
          child: Column(
            children: [
              Container(
                color: CupertinoTheme.of(context).barBackgroundColor, // Theme for top bar
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () {
                        setState(() {
                          _locallySelectedOption = tempSelectedValue;
                        });
                        widget.selectedOption(tempSelectedValue);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: scrollController,
                  itemExtent: 32.0, // Standard item height
                  onSelectedItemChanged: (int index) {
                    if (index >= 0 && index < pickerOptions.length) {
                       tempSelectedValue = pickerOptions[index];
                    }
                  },
                  children: pickerOptions.map((String value) {
                    return Center(child: Text(value, style: CupertinoTheme.of(context).textTheme.textStyle));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final String displayText = _locallySelectedOption ?? widget.hintText ?? 'Select an option';
    final Color displayTextColor = _locallySelectedOption != null
        ? cupertinoTheme.textTheme.textStyle.color!
        : CupertinoColors.placeholderText.resolveFrom(context);

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 44, // Standard Cupertino input height
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: cupertinoTheme.barBackgroundColor.withOpacity(0.1), // Subtle background like text fields
          borderRadius: BorderRadius.circular(8.0),
           border: Border.all(
            color: CupertinoColors.inactiveGray.withOpacity(0.5), // Subtle border
            width: 0.5,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: cupertinoTheme.textTheme.textStyle.copyWith(color: displayTextColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_down, // Standard Cupertino dropdown icon
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
              size: 18,
            )
          ],
        ),
      ),
    );
  }
}
