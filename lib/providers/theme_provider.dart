import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  static const String _themePrefsKey = 'appThemeMode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedThemeMode = prefs.getString(_themePrefsKey);

    if (savedThemeMode != null) {
      try {
        // Assuming Dart 2.17+ for enum.name and values.byName
        _themeMode = ThemeMode.values.byName(savedThemeMode);
      } catch (_) {
        // Fallback if the saved string is invalid for any reason
        _themeMode = ThemeMode.system;
      }
    } else {
      _themeMode = ThemeMode.system; // Default if no preference saved
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return; // No change needed

    _themeMode = mode;
    notifyListeners(); // Notify listeners immediately for UI update

    final prefs = await SharedPreferences.getInstance();
    try {
      // Assuming Dart 2.17+ for enum.name
      await prefs.setString(_themePrefsKey, mode.name);
    } catch (e) {
      // Handle potential errors during saving, though unlikely for simple string
      // In a real app, might log this error
      debugPrint('Error saving theme mode preference: $e');
    }
  }
}
