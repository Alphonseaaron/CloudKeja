import 'package:flutter/material.dart';

class CategoriesMaterial extends StatefulWidget {
  const CategoriesMaterial({Key? key}) : super(key: key);

  @override
  State<CategoriesMaterial> createState() => _CategoriesMaterialState();
}

class _CategoriesMaterialState extends State<CategoriesMaterial> {
  final List<String> categories = [
    'Recommended',
    'Newest',
    'Popular',
    'Nearby',
  ];

  int _currentSelectedIndex = 0;

  void _handleCategorySelected(int index) {
    setState(() {
      _currentSelectedIndex = index;
      // TODO: Add logic to filter content based on the selected category
      // For example, call a provider method or a callback function.
      // If a callback is needed:
      // if (widget.onCategorySelected != null) {
      //   widget.onCategorySelected!(categories[index]);
      // }
      print('Selected Material Category: ${categories[index]}');
    });
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context); // Not strictly needed if relying on ChipThemeData

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final bool isSelected = _currentSelectedIndex == index;
          return ChoiceChip(
            label: Text(categories[index]),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                _handleCategorySelected(index);
              }
            },
            // Styling primarily from ChipThemeData in AppTheme.
            // Specific overrides can be done here if needed.
            // e.g., showCheckmark: false, // Common for M3 if checkmark is not desired
          );
        },
        separatorBuilder: (_, index) => const SizedBox(width: 8.0),
      ),
    );
  }
}
