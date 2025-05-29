import 'package:flutter/material.dart';

class MyDropDown extends StatefulWidget {
  const MyDropDown({
    Key? key,
    this.hintText,
    required this.selectedOption, // Callback when an option is selected
    this.options,
    this.currentValue, // Optional: To show the currently selected value
  }) : super(key: key);

  final String? hintText;
  final List<String>? options;
  final Function(String option) selectedOption;
  final String? currentValue; // To pre-fill the dropdown display

  @override
  State<MyDropDown> createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String? _locallySelectedOption; // To display the selection

  @override
  void initState() {
    super.initState();
    _locallySelectedOption = widget.currentValue;
  }

  @override
  void didUpdateWidget(covariant MyDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue) {
      setState(() {
        _locallySelectedOption = widget.currentValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // Use InputDecorationTheme for consistent styling with TextFormFields
    final inputDecorationTheme = theme.inputDecorationTheme;

    // Determine text style based on whether an option is selected or hint is shown
    final String displayText = _locallySelectedOption ?? widget.hintText ?? 'Select an option';
    final TextStyle effectiveTextStyle = (_locallySelectedOption != null)
        ? (inputDecorationTheme.labelStyle ?? textTheme.bodyLarge)!.copyWith(color: colorScheme.onSurface) // Style for selected value
        : (inputDecorationTheme.hintStyle ?? textTheme.bodyLarge)!.copyWith(color: colorScheme.onSurface.withOpacity(0.6)); // Style for hint

    return GestureDetector(
      onTap: () {
        if (widget.options == null || widget.options!.isEmpty) return; // Don't show if no options

        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Allows content to determine height
          backgroundColor: Colors.transparent, // For custom rounded corners on the sheet content
          shape: theme.bottomSheetTheme.shape ?? const RoundedRectangleBorder( // Use themed shape
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          builder: (ctx) {
            // Sort options alphabetically
            List<String> sortedOptions = List<String>.from(widget.options ?? []);
            sortedOptions.sort();
            
            return DropDownOptions(
              options: sortedOptions,
              title: widget.hintText?.toUpperCase() ?? 'SELECT OPTION', // Title for the sheet
              selectedOptionCallback: (val) { // Renamed for clarity
                setState(() {
                  _locallySelectedOption = val;
                });
                widget.selectedOption(val); // Call the original callback
              },
              currentlySelected: _locallySelectedOption, // Pass current selection to highlight
            );
          },
        );
      },
      child: Container(
        height: 50, // Standard height for input fields, adjust as needed
        padding: const EdgeInsets.symmetric(horizontal: 12.0), // Consistent with TextField padding
        decoration: BoxDecoration(
          color: inputDecorationTheme.fillColor ?? colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: (inputDecorationTheme.border as OutlineInputBorder?)?.borderRadius ?? BorderRadius.circular(8.0),
          border: Border.all(
            color: (inputDecorationTheme.border as OutlineInputBorder?)?.borderSide.color ?? colorScheme.outline.withOpacity(0.5),
            width: (inputDecorationTheme.border as OutlineInputBorder?)?.borderSide.width ?? 1.0,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded( // Ensure text truncates if too long
              child: Text(
                displayText,
                style: effectiveTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down_rounded, // Material Design dropdown icon
              color: colorScheme.onSurfaceVariant.withOpacity(0.7), // Themed icon color
              size: 24,
            )
          ],
        ),
      ),
    );
  }
}

class DropDownOptions extends StatelessWidget {
  const DropDownOptions({
    Key? key,
    required this.options,
    required this.title,
    required this.selectedOptionCallback,
    this.currentlySelected,
  }) : super(key: key);

  final List<String> options;
  final String title;
  final Function(String option) selectedOptionCallback;
  final String? currentlySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // This GestureDetector is for the content inside the DraggableScrollableSheet,
    // preventing taps on it from closing the sheet.
    return GestureDetector(
      onTap: () {}, // Prevent sheet dismissal when tapping on content
      child: DraggableScrollableSheet(
        initialChildSize: 0.4, // Start at 40% of screen height
        maxChildSize: 0.7,     // Max 70%
        minChildSize: 0.2,     // Min 20%
        expand: false, // Content determines height
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.bottomSheetTheme.backgroundColor ?? colorScheme.surface, // Themed sheet background
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), // Consistent radius
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Drag Handle and Title
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 4.0),
                  child: Column(
                    children: [
                      Container( // Drag handle
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith( // More subtle title for sheet
                          color: colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Divider(color: colorScheme.outline.withOpacity(0.2), height: 16),
                    ],
                  ),
                ),
                // Options List
                Expanded(
                  child: ListView.builder( // Changed from List.generate for performance
                    controller: scrollController,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final bool isSelected = currentlySelected == option;
                      return ListTile(
                        title: Text(
                          option,
                          style: textTheme.bodyLarge?.copyWith(
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: colorScheme.primary.withOpacity(0.1), // Subtle selection indicator
                        onTap: () {
                          selectedOptionCallback(option);
                          Navigator.of(context).pop(); // Close sheet after selection
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
