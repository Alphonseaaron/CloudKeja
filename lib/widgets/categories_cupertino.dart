import 'package:flutter/cupertino.dart';

class CategoriesCupertino extends StatefulWidget {
  const CategoriesCupertino({Key? key}) : super(key: key);

  @override
  State<CategoriesCupertino> createState() => _CategoriesCupertinoState();
}

class _CategoriesCupertinoState extends State<CategoriesCupertino> {
  // Using the same categories as Material version for consistency
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
      // If a callback is needed:
      // if (widget.onCategorySelected != null) {
      //   widget.onCategorySelected!(categories[index]);
      // }
      print('Selected Cupertino Category: ${categories[index]}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return SizedBox(
      height: 36, // Standard height for Cupertino segmented control like elements or small buttons
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final bool isSelected = _currentSelectedIndex == index;
          final String categoryText = categories[index];

          if (isSelected) {
            return CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Adjust padding
              borderRadius: BorderRadius.circular(8.0), // Standard Cupertino rounding
              minSize: 0, // Allow button to be smaller based on content
              onPressed: () => _handleCategorySelected(index),
              child: Text(categoryText, style: TextStyle(fontSize: 14, color: cupertinoTheme.brightness == Brightness.dark ? CupertinoColors.black : CupertinoColors.white)), // Ensure text contrast
            );
          } else {
            return CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              borderRadius: BorderRadius.circular(8.0),
              minSize: 0,
              color: CupertinoColors.tertiarySystemFill.resolveFrom(context), // Subtle background for unselected
              onPressed: () => _handleCategorySelected(index),
              child: Text(
                categoryText,
                style: TextStyle(
                  fontSize: 14,
                  color: cupertinoTheme.primaryColor, // Use primary color for text of unselected
                ),
              ),
            );
          }
        },
        separatorBuilder: (_, index) => const SizedBox(width: 8.0),
      ),
    );
  }
}
