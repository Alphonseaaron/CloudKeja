import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kAppPrimaryColor = Color(0xFF007AFF); // Main app blue (Apple Blue)
// const Color kAppSecondaryColor = Color(0xFF409CFF); // Lighter blue or complementary - Not used in final ColorScheme
// const Color kAppTextColor = Color(0xFF100E34); // Dark text color for light theme - Defined by onBackground/onSurface
// const Color kAppBackgroundColor = Color(0xFFFFFFFF); // Clean white background for light theme - Defined by ColorScheme
// const Color kAppSurfaceColor = Color(0xFFF8F9FA); // Light grey for surfaces in light theme - Defined by ColorScheme
// const Color kAppErrorColor = Color(0xFFD32F2F); // Standard error red - Defined by ColorScheme

class AppTheme {
  static ThemeData get lightTheme {
    // Define the full ColorScheme for light theme
    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: kAppPrimaryColor,
      brightness: Brightness.light,
      // Override specific colors if needed, e.g.:
      // surface: kAppSurfaceColor,
      // background: kAppBackgroundColor,
      // error: kAppErrorColor,
      // onPrimary: Colors.white,
      // onSurface: kAppTextColor,
    );

    // Define the TextTheme using GoogleFonts.ibmPlexSans for light theme
    final TextTheme baseLightTextTheme = GoogleFonts.ibmPlexSansTextTheme(
      ThemeData.light().textTheme
    ).copyWith(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: lightColorScheme.onBackground),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: lightColorScheme.onBackground),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: lightColorScheme.onBackground),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: lightColorScheme.onBackground), // Adjusted from 22 to 20
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lightColorScheme.onBackground),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: lightColorScheme.onBackground),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: lightColorScheme.onBackground, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: lightColorScheme.onBackground, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: lightColorScheme.onPrimary),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: lightColorScheme.onBackground.withOpacity(0.7), height: 1.3),
      // caption: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: lightColorScheme.onBackground.withOpacity(0.6)), // Example for caption
    ).apply(
      bodyColor: lightColorScheme.onBackground,
      displayColor: lightColorScheme.onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: lightColorScheme.primary,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightColorScheme.background,
      dialogBackgroundColor: lightColorScheme.surface, // M3 uses surface for dialogs
      hintColor: lightColorScheme.onSurface.withOpacity(0.5),
      dividerColor: lightColorScheme.outline.withOpacity(0.5),
      brightness: Brightness.light,

      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 0.5,
        titleTextStyle: baseLightTextTheme.titleLarge?.copyWith(color: lightColorScheme.onSurface),
        iconTheme: IconThemeData(color: lightColorScheme.onSurface, size: 24),
      ),

      textTheme: baseLightTextTheme,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          textStyle: baseLightTextTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Increased vertical padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1.0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          textStyle: baseLightTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600, // Slightly bolder for text buttons
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          side: BorderSide(color: lightColorScheme.outline, width: 1.0), // Use outline color
          textStyle: baseLightTextTheme.labelLarge?.copyWith(
            color: lightColorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      cardTheme: CardTheme(
        elevation: 1.0, // M3 often uses lower elevation for cards
        color: lightColorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Standardized margin
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surfaceContainerHighest, // M3 standard for filled inputs
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // Filled inputs often have no border or subtle one
        ),
        enabledBorder: OutlineInputBorder( // Subtle border for enabled state
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.outline.withOpacity(0.5), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2.0),
        ),
        labelStyle: baseLightTextTheme.bodyLarge?.copyWith(color: lightColorScheme.onSurface.withOpacity(0.7)),
        hintStyle: baseLightTextTheme.bodyMedium?.copyWith(color: lightColorScheme.onSurface.withOpacity(0.5)),
        prefixIconColor: lightColorScheme.onSurfaceVariant,
        suffixIconColor: lightColorScheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Standard padding
      ),

      dialogTheme: DialogTheme(
        backgroundColor: lightColorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Slightly larger radius for dialogs
        titleTextStyle: baseLightTextTheme.titleLarge?.copyWith(color: lightColorScheme.onSurface),
        contentTextStyle: baseLightTextTheme.bodyMedium?.copyWith(color: lightColorScheme.onSurface),
        elevation: 3.0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: lightColorScheme.secondaryContainer.withOpacity(0.4),
        selectedColor: lightColorScheme.primary,
        secondarySelectedColor: lightColorScheme.primary,
        labelStyle: baseLightTextTheme.bodySmall?.copyWith(color: lightColorScheme.onSecondaryContainer),
        selectedLabelStyle: baseLightTextTheme.bodySmall?.copyWith(color: lightColorScheme.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        side: BorderSide.none,
        showCheckmark: true, // M3 often does show checkmark on selected FilterChips
        elevation: 0.0,
        pressElevation: 1.0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightColorScheme.surface, // Or surfaceContainer for a bit of elevation feel
        indicatorColor: lightColorScheme.primaryContainer,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: lightColorScheme.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: lightColorScheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final style = baseLightTextTheme.bodySmall;
          if (states.contains(MaterialState.selected)) {
            return style?.copyWith(color: lightColorScheme.onSurface, fontWeight: FontWeight.w600); // Selected label is often onSurface
          }
          return style?.copyWith(color: lightColorScheme.onSurfaceVariant);
        }),
        elevation: 1.0, // Subtle elevation
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, // Or onlyShowSelected
      ),
       bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lightColorScheme.surface,
        modalBackgroundColor: lightColorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        elevation: 2.0,
      ),
      dividerTheme: DividerThemeData(
        color: lightColorScheme.outline.withOpacity(0.5),
        space: 1,
        thickness: 1,
      ),
    );
  }

  // --- DARK THEME DEFINITION ---
  static ThemeData get darkTheme {
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: kAppPrimaryColor,
      brightness: Brightness.dark,
      // Override to ensure good contrast and M3 feel:
      // primary: Colors.blue.shade300, // Lighter blue for dark theme
      // secondary: Colors.cyan.shade300,
      // surface: const Color(0xFF1E1E1E), // Slightly off-black surface
      // background: const Color(0xFF121212), // Standard dark background
      // onPrimary: Colors.black, // Text on lighter blue primary
      // onSurface: Colors.white.withOpacity(0.87),
      // onBackground: Colors.white.withOpacity(0.87),
      // error: Colors.red.shade400,
    );

    final TextTheme baseDarkTextTheme = GoogleFonts.ibmPlexSansTextTheme(
      ThemeData.dark().textTheme
    ).copyWith(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkColorScheme.onBackground),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkColorScheme.onBackground),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: darkColorScheme.onBackground),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkColorScheme.onBackground),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkColorScheme.onBackground),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkColorScheme.onBackground),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: darkColorScheme.onBackground, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: darkColorScheme.onBackground, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkColorScheme.onPrimary),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: darkColorScheme.onBackground.withOpacity(0.7), height: 1.3),
      // caption: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: darkColorScheme.onBackground.withOpacity(0.6)),
    ).apply(
      bodyColor: darkColorScheme.onBackground,
      displayColor: darkColorScheme.onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: darkColorScheme.primary,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkColorScheme.background,
      dialogBackgroundColor: darkColorScheme.surface,
      hintColor: darkColorScheme.onSurface.withOpacity(0.5),
      dividerColor: darkColorScheme.outline.withOpacity(0.5),
      brightness: Brightness.dark,

      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface, // Or surfaceContainer for elevation effect
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0.5,
        titleTextStyle: baseDarkTextTheme.titleLarge?.copyWith(color: darkColorScheme.onSurface),
        iconTheme: IconThemeData(color: darkColorScheme.onSurface, size: 24),
      ),

      textTheme: baseDarkTextTheme,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary,
          textStyle: baseDarkTextTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1.0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkColorScheme.primary, // Or secondary for variety
          textStyle: baseDarkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkColorScheme.primary, // Or secondary
          side: BorderSide(color: darkColorScheme.outline, width: 1.0), // Use outline color
          textStyle: baseDarkTextTheme.labelLarge?.copyWith(
            color: darkColorScheme.primary, // Or secondary
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      cardTheme: CardTheme(
        elevation: 1.0,
        color: darkColorScheme.surfaceVariant, // surfaceVariant is often used for cards in dark M3
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surfaceContainerHighest, // M3 dark input fill
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
         enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.outline.withOpacity(0.7), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2.0),
        ),
        labelStyle: baseDarkTextTheme.bodyLarge?.copyWith(color: darkColorScheme.onSurface.withOpacity(0.7)),
        hintStyle: baseDarkTextTheme.bodyMedium?.copyWith(color: darkColorScheme.onSurface.withOpacity(0.5)),
        prefixIconColor: darkColorScheme.onSurfaceVariant,
        suffixIconColor: darkColorScheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: darkColorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: baseDarkTextTheme.titleLarge?.copyWith(color: darkColorScheme.onSurface),
        contentTextStyle: baseDarkTextTheme.bodyMedium?.copyWith(color: darkColorScheme.onSurface),
        elevation: 3.0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkColorScheme.secondaryContainer.withOpacity(0.6),
        selectedColor: darkColorScheme.primary, // Or secondary
        secondarySelectedColor: darkColorScheme.primary, // Or secondary
        labelStyle: baseDarkTextTheme.bodySmall?.copyWith(color: darkColorScheme.onSecondaryContainer),
        selectedLabelStyle: baseDarkTextTheme.bodySmall?.copyWith(color: darkColorScheme.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        side: BorderSide.none, // Or BorderSide(color: darkColorScheme.outline.withOpacity(0.5))
        showCheckmark: true,
        elevation: 0.0,
        pressElevation: 1.0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkColorScheme.surface, // Or surfaceContainer for a bit of elevation feel
        indicatorColor: darkColorScheme.primaryContainer,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: darkColorScheme.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: darkColorScheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final style = baseDarkTextTheme.bodySmall;
          if (states.contains(MaterialState.selected)) {
            return style?.copyWith(color: darkColorScheme.onSurface, fontWeight: FontWeight.w600);
          }
          return style?.copyWith(color: darkColorScheme.onSurfaceVariant);
        }),
        elevation: 1.0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkColorScheme.surface,
        modalBackgroundColor: darkColorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        elevation: 2.0,
      ),
      dividerTheme: DividerThemeData(
        color: darkColorScheme.outline.withOpacity(0.5),
        space: 1,
        thickness: 1,
      ),
    );
  }
}
