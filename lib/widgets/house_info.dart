import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HouseInfo extends StatelessWidget {
  const HouseInfo({Key? key}) : super(key: key);

  // Data for the info items - this could also come from a model or be passed in.
  // For now, keeping it similar to the original structure.
  static const List<Map<String, String>> _infoDataRow1 = [
    {'imageUrl': 'assets/icons/bedroom.svg', 'content': '5 Bedroom\n3 Master Bedroom'},
    {'imageUrl': 'assets/icons/bathroom.svg', 'content': '5 Bathroom\n3 Toilet'},
  ];

  static const List<Map<String, String>> _infoDataRow2 = [
    {'imageUrl': 'assets/icons/kitchen.svg', 'content': '2 Kitchen\n120 sqft'},
    {'imageUrl': 'assets/icons/parking.svg', 'content': '5 Parking\n120 sqft'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            children: _infoDataRow1
                .map((data) => _MenuInfo(
                      imageUrl: data['imageUrl']!,
                      content: data['content']!,
                    ))
                .toList(),
          ),
          const SizedBox(height: 16.0), // Adjusted spacing
          Row(
            children: _infoDataRow2
                .map((data) => _MenuInfo(
                      imageUrl: data['imageUrl']!,
                      content: data['content']!,
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}

class _MenuInfo extends StatelessWidget {
  final String imageUrl;
  final String content;

  const _MenuInfo({
    Key? key,
    required this.imageUrl,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Expanded(
      child: Row(
        children: [
          SvgPicture.asset(
            imageUrl,
            width: 28, // Slightly larger for clarity
            height: 28,
            colorFilter: ColorFilter.mode(
              colorScheme.primary, // Theme the icon color
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12.0), // Adjusted spacing
          Expanded( // Allow text to wrap if it's too long
            child: Text(
              content,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
                height: 1.4, // Improve line spacing for multi-line text
              ),
              // softWrap: true, // Default is true
            ),
          ),
        ],
      ),
    );
  }
}
