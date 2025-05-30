import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const CustomCheckbox({
    Key? key,
    this.initialValue = false,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // The standard Checkbox widget will use CheckboxThemeData from the global theme.
    // AppTheme.lightTheme already defines colorScheme.primary which will be used.
    return Checkbox(
      value: _isChecked,
      onChanged: (bool? value) {
        if (value != null) {
          setState(() {
            _isChecked = value;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        }
      },
      // VisualDensity can be used to make it slightly larger or smaller if needed
      // visualDensity: VisualDensity.compact,
      // splashRadius: 0, // To minimize splash if directly next to text
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduces tap area to checkbox size
      // Active color and check color will be derived from the theme (colorScheme.primary)
    );
  }
}
