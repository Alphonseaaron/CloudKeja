import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final List<String> categories = [
    'Recommended',
    'Newest',
    'Popular', // Added for more variety, can be adjusted
    'Nearby',  // Added for more variety
  ];

  int _currentSelectedIndex = 0;

  void _handleCategorySelected(int index) {
    setState(() {
      _currentSelectedIndex = index;
      // TODO: Add logic to filter content based on the selected category
      // For example, call a provider method or a callback function.
      // widget.onCategorySelected(categories[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ChipThemeData is fetched from the global theme (AppTheme.lightTheme)
    // final chipTheme = theme.chipTheme; 

    return SizedBox(
      height: 48, // Adjusted height to comfortably fit chips with padding
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // M3 standard padding
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final bool isSelected = _currentSelectedIndex == index;
          return ChoiceChip(
            label: Text(categories[index]),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) { // ChoiceChip's onSelected gives current state
                _handleCategorySelected(index);
              }
            },
            // Styling will primarily come from ChipThemeData in AppTheme
            // However, you can override specific aspects here if necessary:
            // selectedColor: chipTheme.selectedColor,
            // backgroundColor: chipTheme.backgroundColor,
            // labelStyle: isSelected ? chipTheme.selectedLabelStyle : chipTheme.labelStyle,
            // shape: chipTheme.shape,
            // side: chipTheme.side,
            // padding: chipTheme.padding,
            // showCheckmark: chipTheme.showCheckmark ?? false, // Default to false for M3 feel
          );
        },
        separatorBuilder: (_, index) => const SizedBox(width: 8.0), // M3 standard spacing
      ),
    );
  }
}
