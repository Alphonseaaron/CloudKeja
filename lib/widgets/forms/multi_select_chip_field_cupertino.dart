import 'package:flutter/cupertino.dart';
import 'package:cloudkeja/widgets/forms/_cupertino_multi_select_page_route.dart'; // Import the selection page

class MultiSelectChipFieldCupertino extends StatefulWidget {
  final List<String> allOptions;
  final List<String> initialSelectedOptions;
  final Function(List<String> selectedOptions) onSelectionChanged;
  final String? title;

  const MultiSelectChipFieldCupertino({
    Key? key,
    required this.allOptions,
    required this.initialSelectedOptions,
    required this.onSelectionChanged,
    this.title,
  }) : super(key: key);

  @override
  State<MultiSelectChipFieldCupertino> createState() => _MultiSelectChipFieldCupertinoState();
}

class _MultiSelectChipFieldCupertinoState extends State<MultiSelectChipFieldCupertino> {
  late List<String> _currentSelectedOptions;

  @override
  void initState() {
    super.initState();
    _currentSelectedOptions = List<String>.from(widget.initialSelectedOptions);
  }

  @override
  void didUpdateWidget(covariant MultiSelectChipFieldCupertino oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Consider deep equality check if necessary, similar to Material version
    if (widget.initialSelectedOptions != oldWidget.initialSelectedOptions) {
      _currentSelectedOptions = List<String>.from(widget.initialSelectedOptions);
    }
  }

  String _getSelectedOptionsDisplayString() {
    if (_currentSelectedOptions.isEmpty) {
      return 'None selected';
    }
    // Sort for consistent display order
    // List<String> sortedOptions = List.from(_currentSelectedOptions)..sort();
    // return sortedOptions.join(', ');
    // Or, just show a count if list can be long
     if (_currentSelectedOptions.length > 2) {
      return '${_currentSelectedOptions.length} items selected';
    }
    return _currentSelectedOptions.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null && widget.title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 8.0), // Added top padding
            child: Text(
              widget.title!,
              style: cupertinoTheme.textTheme.navTitleTextStyle.copyWith(
                fontSize: 17, // Typical size for section titles or prominent labels
                color: CupertinoColors.label.resolveFrom(context)
              ), 
            ),
          ),
        GestureDetector(
          onTap: () async {
            final List<String>? result = await Navigator.of(context).push<List<String>>(
              CupertinoPageRoute(
                builder: (context) => _CupertinoMultiSelectPage(
                  allOptions: widget.allOptions,
                  initiallySelectedOptions: _currentSelectedOptions,
                  pageTitle: widget.title ?? 'Select Options',
                ),
                // settings: RouteSettings(name: '/cupertinoMultiSelectPage') // Optional: for route observers
              ),
            );

            if (result != null) {
              setState(() {
                _currentSelectedOptions = result;
              });
              widget.onSelectionChanged(List<String>.from(_currentSelectedOptions));
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: CupertinoColors.systemGrey4.resolveFrom(context),
                width: 0.5,
              )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getSelectedOptionsDisplayString(),
                    style: cupertinoTheme.textTheme.textStyle.copyWith(
                      color: _currentSelectedOptions.isEmpty 
                          ? CupertinoColors.secondaryLabel.resolveFrom(context) 
                          : CupertinoColors.label.resolveFrom(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_down, // Or chevron_right
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
