import 'dart:io' show Platform; // Import Platform with a guard for web
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformService {
  // Mobile checks
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isAppleDevice => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  // Specific OS checks
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  // Add other OS checks as needed e.g. isLinux, isWindows

  // Desktop check (non-web)
  static bool get isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

  // Web check
  static bool get isWeb => kIsWeb;

  // UI System Choice
  // Prefers Cupertino for Apple native platforms, Material otherwise.
  static bool get useCupertino {
    if (kIsWeb) {
      return false; // Force Material on Web for now, can be a setting later
    }
    return Platform.isIOS || Platform.isMacOS;
  }

  static bool get useMaterial {
    if (kIsWeb) {
      return true;
    }
    // Use Material for Android and other non-Apple native platforms (Linux, Windows, Fuchsia)
    return Platform.isAndroid || (!Platform.isIOS && !Platform.isMacOS);
  }
}
