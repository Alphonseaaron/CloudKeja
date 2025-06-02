import 'package:flutter/material.dart';

class MultiSelectChipFieldMaterial extends StatefulWidget {
  final List<String> allOptions;
  final List<String> initialSelectedOptions;
  final Function(List<String> selectedOptions) onSelectionChanged;
  final String? title;

  const MultiSelectChipFieldMaterial({
    Key? key,
    required this.allOptions,
    required this.initialSelectedOptions,
    required this.onSelectionChanged,
    this.title,
  }) : super(key: key);

  @override
  State<MultiSelectChipFieldMaterial> createState() => _MultiSelectChipFieldMaterialState();
}

class _MultiSelectChipFieldMaterialState extends State<MultiSelectChipFieldMaterial> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List<String>.from(widget.initialSelectedOptions);
  }

  @override
  void didUpdateWidget(covariant MultiSelectChipFieldMaterial oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the actual list content is different, not just the instance.
    // This simple check might be okay if parent always provides a new list instance on change.
    if (widget.initialSelectedOptions != oldWidget.initialSelectedOptions) {
       // Or perform a deep equality check if necessary:
       // if (!listEquals(widget.initialSelectedOptions, oldWidget.initialSelectedOptions)) {
      _selectedOptions = List<String>.from(widget.initialSelectedOptions);
       // }
    }
  }

  void _toggleSelection(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
      widget.onSelectionChanged(List<String>.from(_selectedOptions));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null && widget.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 8.0), // Added top padding for spacing
            child: Text(
              widget.title!,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        Wrap(
          spacing: 8.0,
          runSpacing: 6.0,
          children: widget.allOptions.map((option) {
            final bool isSelected = _selectedOptions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                _toggleSelection(option);
              },
              // Styling is primarily handled by ChipThemeData in AppTheme.
              // Example explicit styling (usually not needed if theme is set):
              // selectedColor: theme.chipTheme.selectedColor ?? theme.colorScheme.primary,
              // backgroundColor: theme.chipTheme.backgroundColor ?? theme.colorScheme.surfaceVariant,
              // labelStyle: isSelected 
              //   ? theme.chipTheme.labelStyle?.copyWith(color: theme.chipTheme.selectedColor) 
              //   : theme.chipTheme.labelStyle, // This logic might need refinement based on theme
              // checkmarkColor: theme.chipTheme.checkmarkColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}
