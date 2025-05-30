import 'package:flutter/material.dart'; // For BuildContext, GlobalKey
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart'; // For ShowCaseWidget, if used directly here later

class WalkthroughService {
  static SharedPreferences? _prefs;

  // Key prefix to avoid collisions in SharedPreferences
  static const String _walkthroughKeyPrefix = 'walkthrough_seen_';

  // Initialization method to be called once in main.dart
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('WalkthroughService initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing WalkthroughService (SharedPreferences): $e');
      // Handle error, perhaps by disabling walkthroughs if prefs are not available
    }
  }

  // Checks if a specific walkthrough has been seen
  static bool hasSeen(String walkthroughKey) {
    if (_prefs == null) {
      debugPrint('WalkthroughService: SharedPreferences not initialized. Assuming walkthrough not seen.');
      return false; // Or true, depending on desired fallback behavior
    }
    final String fullKey = '$_walkthroughKeyPrefix$walkthroughKey';
    bool hasSeenWalkthrough = _prefs!.getBool(fullKey) ?? false;
    debugPrint('WalkthroughService: Check "$walkthroughKey" (key: "$fullKey") - Seen: $hasSeenWalkthrough');
    return hasSeenWalkthrough;
  }

  // Marks a specific walkthrough as seen
  static Future<void> markAsSeen(String walkthroughKey) async {
    if (_prefs == null) {
      debugPrint('WalkthroughService: SharedPreferences not initialized. Cannot mark walkthrough as seen.');
      return;
    }
    final String fullKey = '$_walkthroughKeyPrefix$walkthroughKey';
    try {
      await _prefs!.setBool(fullKey, true);
      debugPrint('WalkthroughService: Marked "$walkthroughKey" (key: "$fullKey") as seen.');
    } catch (e) {
      debugPrint('Error marking walkthrough "$walkthroughKey" as seen: $e');
    }
  }

  // Resets the "seen" status for a specific walkthrough (for testing/debugging)
  static Future<void> resetSeen(String walkthroughKey) async {
    if (_prefs == null) {
      debugPrint('WalkthroughService: SharedPreferences not initialized. Cannot reset walkthrough status.');
      return;
    }
    final String fullKey = '$_walkthroughKeyPrefix$walkthroughKey';
    try {
      await _prefs!.remove(fullKey);
      debugPrint('WalkthroughService: Reset seen status for "$walkthroughKey" (key: "$fullKey").');
    } catch (e) {
      debugPrint('Error resetting walkthrough "$walkthroughKey": $e');
    }
  }

  static Future<void> resetAllSeenWalkthroughs() async {
    if (_prefs == null) {
      debugPrint('WalkthroughService: SharedPreferences not initialized. Cannot reset all walkthroughs.');
      // Attempt to initialize if not already, though ideally it should be.
      await init();
      if (_prefs == null) return; // Still null after init, abort.
    }
    final keys = _prefs!.getKeys().where((key) => key.startsWith(_walkthroughKeyPrefix)).toList();
    if (keys.isNotEmpty) {
      for (final key in keys) {
        try {
          await _prefs!.remove(key);
          debugPrint('WalkthroughService: Removed walkthrough key: $key');
        } catch (e) {
          debugPrint('WalkthroughService: Error removing walkthrough key $key: $e');
        }
      }
      debugPrint('WalkthroughService: All walkthrough seen statuses reset.');
    } else {
      debugPrint('WalkthroughService: No walkthrough keys found to reset.');
    }
  }

  /// Starts a showcase sequence for the given [walkthroughKey] if it hasn't been seen before.
  ///
  /// The screen calling this method must be wrapped in a [ShowCaseWidget].
  /// The [ShowCaseWidget.onFinish] callback on the screen should call [markAsSeen]
  /// with the same [walkthroughKey].
  ///
  /// - [context]: The build context from the screen.
  /// - [walkthroughKey]: A unique key identifying this specific walkthrough.
  /// - [showcaseGlobalKeys]: A list of GlobalKeys attached to the [Showcase] widgets
  ///   that are part of this walkthrough.
  static void startShowcaseIfNeeded({
    required BuildContext context,
    required String walkthroughKey,
    required List<GlobalKey> showcaseGlobalKeys,
  }) {
    if (hasSeen(walkthroughKey)) {
      debugPrint('WalkthroughService: Walkthrough "$walkthroughKey" already seen. Skipping.');
      return;
    }

    if (showcaseGlobalKeys.isEmpty) {
      debugPrint('WalkthroughService: No global keys provided for walkthrough "$walkthroughKey". Cannot start showcase.');
      // Optionally, mark as seen to prevent repeated attempts if configuration is wrong
      // markAsSeen(walkthroughKey);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final showCaseWidgetState = ShowCaseWidget.of(context);
        if (showCaseWidgetState != null) {
          debugPrint('WalkthroughService: Starting showcase for "$walkthroughKey" with ${showcaseGlobalKeys.length} items.');
          showCaseWidgetState.startShowCase(showcaseGlobalKeys);
        } else {
          debugPrint('WalkthroughService: ShowCaseWidget.of(context) returned null for "$walkthroughKey". Ensure the context is a descendant of ShowCaseWidget.');
          // If ShowCaseWidget is not found, we might mark it as seen to avoid retrying every time,
          // or log this as a setup error. For now, just logging.
          // markAsSeen(walkthroughKey); // Consider implications: user might never see it.
        }
      } catch (e) {
        debugPrint('WalkthroughService: Error trying to start ShowCaseWidget for "$walkthroughKey". Error: $e');
        // Mark as seen to prevent repeated errors if there's a persistent issue with the showcase setup on this screen.
        // markAsSeen(walkthroughKey); // Again, consider implications.
      }
    });
  }
}
