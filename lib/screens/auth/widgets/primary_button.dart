import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  final Color? buttonColor; // This can be used to override the theme's primary if needed
  final String textValue;
  final Color? textColor; // This can be used to override the theme's onPrimary if needed
  final VoidCallback? onTap; // Changed to VoidCallback for type safety
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;

  const CustomPrimaryButton({
    Key? key,
    required this.textValue,
    this.buttonColor,
    this.textColor,
    this.onTap,
    this.minWidth, // Default will be from theme or intrinsic
    this.minHeight, // Default will be from theme (typically 40-56dp)
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elevatedButtonTheme = theme.elevatedButtonTheme;

    // Use passed-in values or fallback to theme/defaults
    final effectiveButtonColor = buttonColor ?? elevatedButtonTheme.style?.backgroundColor?.resolve({}) ?? theme.colorScheme.primary;
    final effectiveTextColor = textColor ?? elevatedButtonTheme.style?.foregroundColor?.resolve({}) ?? theme.colorScheme.onPrimary;
    final effectiveTextStyle = elevatedButtonTheme.style?.textStyle?.resolve({}) ?? theme.textTheme.labelLarge?.copyWith(color: effectiveTextColor);
    final effectiveShape = elevatedButtonTheme.style?.shape?.resolve({}) ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)); // Default M3 radius
    final effectivePadding = padding ?? elevatedButtonTheme.style?.padding?.resolve({}) ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    final effectiveMinimumSize = Size(minWidth ?? 0, minHeight ?? 50); // Provide a default height

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveButtonColor,
        foregroundColor: effectiveTextColor,
        textStyle: effectiveTextStyle,
        shape: effectiveShape,
        padding: effectivePadding,
        minimumSize: effectiveMinimumSize,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Can be adjusted
        elevation: elevatedButtonTheme.style?.elevation?.resolve({}) ?? 2.0, // Default M3 elevation
      ).copyWith(
        // Ensure the text style's color is correctly applied if overridden
        textStyle: MaterialStateProperty.all(effectiveTextStyle?.copyWith(color: effectiveTextColor)),
      ),
      child: Text(textValue),
    );
  }
}
