import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for Cupertino
import 'package:provider/provider.dart'; // Added for Provider
import 'package:cloudkeja/services/platform_service.dart'; // Added for PlatformService
import 'package:cloudkeja/models/space_model.dart';
import 'package:intl/intl.dart'; // For currency formatting

class ContentIntro extends StatelessWidget {
  final SpaceModel space;

  const ContentIntro({
    Key? key,
    required this.space,
  }) : super(key: key);

  String _getRentTimeText() {
    switch (space.rentTime) {
      case 1: return '/ Day'; // Assuming 1 means daily from previous contexts
      case 7: return '/ Week';
      case 30: return '/ Month';
      case 365: return '/ Year';
      default: return '/ Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);
    final bool isCupertino = platformService.useCupertino;

    TextStyle spaceNameStyle;
    TextStyle addressStyle;
    TextStyle areaStyle;
    TextStyle priceStyle;
    TextStyle rentTimeStyle;
    TextStyle basePriceStyle; // For RichText base

    double spacing1 = 8.0; // Space after name
    double spacing2 = 12.0; // Space after address
    double spacing3 = 8.0; // Space after area

    if (isCupertino) {
      final cupertinoTheme = CupertinoTheme.of(context);
      spaceNameStyle = cupertinoTheme.textTheme.navTitleTextStyle.copyWith(fontSize: 22); // Prominent
      addressStyle = cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 15);
      areaStyle = cupertinoTheme.textTheme.textStyle.copyWith(fontSize: 15);
      basePriceStyle = cupertinoTheme.textTheme.textStyle.copyWith(fontSize: 18); // Base for RichText
      priceStyle = basePriceStyle.copyWith(fontWeight: FontWeight.bold, color: cupertinoTheme.primaryColor, fontSize: 20);
      rentTimeStyle = cupertinoTheme.textTheme.footnote.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 14);
      spacing1 = 6.0;
      spacing2 = 10.0;
      spacing3 = 6.0;
    } else {
      final materialTheme = Theme.of(context);
      final textTheme = materialTheme.textTheme;
      final colorScheme = materialTheme.colorScheme;
      spaceNameStyle = textTheme.titleLarge ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
      addressStyle = textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant) ?? const TextStyle(fontSize: 14);
      areaStyle = textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.9)) ?? const TextStyle(fontSize: 14);
      basePriceStyle = textTheme.titleMedium ?? const TextStyle(fontSize: 16);
      priceStyle = basePriceStyle.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold);
      rentTimeStyle = textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant) ?? const TextStyle(fontSize: 12);
    }

    final String areaText = space.area != null && space.area!.isNotEmpty ? '${space.area} sqft' : 'Area not specified';
    final String priceValue = space.price != null
        ? NumberFormat.currency(locale: 'en_KE', symbol: 'KES ', decimalDigits: 0).format(space.price)
        : 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            space.spaceName ?? 'Unnamed Space',
            style: spaceNameStyle,
          ),
          SizedBox(height: spacing1),
          Text(
            space.address ?? 'No address provided',
            style: addressStyle,
          ),
          SizedBox(height: spacing2),
          Text(
            areaText,
            style: areaStyle,
          ),
          SizedBox(height: spacing3),
          RichText(
            text: TextSpan(
              style: basePriceStyle, // Base style for RichText, platform-dependent
              children: [
                TextSpan(
                  text: priceValue,
                  style: priceStyle,
                ),
                TextSpan(
                  text: _getRentTimeText(),
                  style: rentTimeStyle,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
