import 'package:flutter/material.dart';

class MyDropDownMaterial extends StatefulWidget {
  const MyDropDownMaterial({
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
  State<MyDropDownMaterial> createState() => _MyDropDownMaterialState();
}

class _MyDropDownMaterialState extends State<MyDropDownMaterial> {
  String? _locallySelectedOption;

  @override
  void initState() {
    super.initState();
    _locallySelectedOption = widget.currentValue;
  }

  @override
  void didUpdateWidget(covariant MyDropDownMaterial oldWidget) {
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
    final inputDecorationTheme = theme.inputDecorationTheme;

    final String displayText = _locallySelectedOption ?? widget.hintText ?? 'Select an option';
    final TextStyle effectiveTextStyle = (_locallySelectedOption != null)
        ? (inputDecorationTheme.labelStyle ?? textTheme.bodyLarge)!.copyWith(color: colorScheme.onSurface)
        : (inputDecorationTheme.hintStyle ?? textTheme.bodyLarge)!.copyWith(color: colorScheme.onSurface.withOpacity(0.6));

    return GestureDetector(
      onTap: () {
        if (widget.options == null || widget.options!.isEmpty) return;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: theme.bottomSheetTheme.shape ?? const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          builder: (ctx) {
            List<String> sortedOptions = List<String>.from(widget.options ?? []);
            sortedOptions.sort();

            return _DropDownOptionsMaterial( // Renamed helper class
              options: sortedOptions,
              title: widget.hintText?.toUpperCase() ?? 'SELECT OPTION',
              selectedOptionCallback: (val) {
                setState(() {
                  _locallySelectedOption = val;
                });
                widget.selectedOption(val);
              },
              currentlySelected: _locallySelectedOption,
            );
          },
        );
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
            Expanded(
              child: Text(
                displayText,
                style: effectiveTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              size: 24,
            )
          ],
        ),
      ),
    );
  }
}

// Renamed helper class specific to Material version
class _DropDownOptionsMaterial extends StatelessWidget {
  const _DropDownOptionsMaterial({
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

    return GestureDetector(
      onTap: () {},
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.7,
        minChildSize: 0.2,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.bottomSheetTheme.backgroundColor ?? colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 4.0),
                  child: Column(
                    children: [
                      Container(
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
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Divider(color: colorScheme.outline.withOpacity(0.2), height: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
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
                        selectedTileColor: colorScheme.primary.withOpacity(0.1),
                        onTap: () {
                          selectedOptionCallback(option);
                          Navigator.of(context).pop();
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
