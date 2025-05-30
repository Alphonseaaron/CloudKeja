import 'package:flutter/material.dart';

class MultiSelectChipField extends StatefulWidget {
  final List<String> allOptions;
  final List<String> initialSelectedOptions;
  final Function(List<String> selectedOptions) onSelectionChanged;
  final String? title;

  const MultiSelectChipField({
    Key? key,
    required this.allOptions,
    required this.initialSelectedOptions,
    required this.onSelectionChanged,
    this.title,
  }) : super(key: key);

  @override
  State<MultiSelectChipField> createState() => _MultiSelectChipFieldState();
}

class _MultiSelectChipFieldState extends State<MultiSelectChipField> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    // Initialize with a copy to avoid modifying the original list passed in widget.initialSelectedOptions
    _selectedOptions = List<String>.from(widget.initialSelectedOptions);
  }

  // This can be useful if the initialSelectedOptions can change from the parent widget
  @override
  void didUpdateWidget(covariant MultiSelectChipField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedOptions != oldWidget.initialSelectedOptions) {
      _selectedOptions = List<String>.from(widget.initialSelectedOptions);
    }
  }

  void _toggleSelection(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
      // Sort for consistent output order, optional
      // _selectedOptions.sort();
      widget.onSelectionChanged(List<String>.from(_selectedOptions)); // Pass a copy
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final chipTheme = theme.chipTheme; // For explicit styling if needed, otherwise FilterChip uses it

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // To take up minimal vertical space
      children: [
        if (widget.title != null && widget.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.title!,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), // Or labelLarge
            ),
          ),
        Wrap(
          spacing: 8.0,  // Horizontal spacing between chips
          runSpacing: 6.0, // Vertical spacing between chip lines
          children: widget.allOptions.map((option) {
            final bool isSelected = _selectedOptions.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                _toggleSelection(option);
              },
              // FilterChip styling primarily comes from ChipThemeData in AppTheme.
              // Explicit overrides can be done here if needed:
              // selectedColor: chipTheme.selectedColor ?? theme.colorScheme.primary,
              // backgroundColor: chipTheme.backgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.7),
              // labelStyle: isSelected
              //   ? chipTheme.selectedLabelStyle ?? textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary)
              //   : chipTheme.labelStyle ?? textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              // checkmarkColor: chipTheme.checkmarkColor, // Will be used if showCheckmark is true in ChipThemeData
              // shape: chipTheme.shape,
              // side: chipTheme.side,
              // elevation: chipTheme.elevation,
              // pressElevation: chipTheme.pressElevation,
              // visualDensity: VisualDensity.compact, // Make chips a bit smaller
            );
          }).toList(),
        ),
      ],
    );
  }
}
