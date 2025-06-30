import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/accessibility_settings.dart';

class AccessibilityService {
  static const String _settingsKey = 'accessibility_settings';
  
  final SharedPreferences _prefs;
  
  AccessibilityService(this._prefs);

  // Load accessibility settings
  Future<AccessibilitySettings> loadSettings() async {
    try {
      final settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final Map<String, dynamic> json = {};
        // Parse basic key-value format (simplified for this implementation)
        settingsJson.split(',').forEach((pair) {
          final parts = pair.split(':');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = parts[1].trim();
            
            if (value == 'true' || value == 'false') {
              json[key] = value == 'true';
            } else if (double.tryParse(value) != null) {
              json[key] = double.parse(value);
            } else if (int.tryParse(value) != null) {
              json[key] = int.parse(value);
            } else {
              json[key] = value;
            }
          }
        });
        
        return AccessibilitySettings.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading accessibility settings: $e');
    }
    
    return AccessibilitySettings.defaultSettings;
  }

  // Save accessibility settings
  Future<void> saveSettings(AccessibilitySettings settings) async {
    try {
      final json = settings.toJson();
      final settingsString = json.entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      
      await _prefs.setString(_settingsKey, settingsString);
    } catch (e) {
      debugPrint('Error saving accessibility settings: $e');
    }
  }

  // Apply accessibility settings to the system
  static void applySystemAccessibility(AccessibilitySettings settings) {
    // Enable/disable haptic feedback
    if (settings.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  // Announce text for screen readers
  static void announceForAccessibility(BuildContext context, String message) {
    if (WidgetsBinding.instance.accessibilityFeatures.accessibleNavigation) {
      Semantics.fromProperties(
        properties: SemanticsProperties(
          liveRegion: true,
          label: message,
        ),
        child: const SizedBox.shrink(),
      );
    }
  }

  // Provide haptic feedback if enabled
  static void provideFeedback(AccessibilitySettings settings, {
    HapticFeedback? feedback,
  }) {
    if (settings.hapticFeedback) {
      (feedback ?? HapticFeedback.lightImpact).call();
    }
  }

  // Check if device has accessibility features enabled
  static bool hasSystemAccessibilityEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation ||
           mediaQuery.boldText ||
           mediaQuery.highContrast ||
           mediaQuery.textScaleFactor > 1.0;
  }

  // Get recommended settings based on system accessibility
  static AccessibilitySettings getRecommendedSettings(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return AccessibilitySettings(
      enableScreenReader: mediaQuery.accessibleNavigation,
      highContrastMode: mediaQuery.highContrast,
      largeText: mediaQuery.textScaleFactor > 1.2,
      boldText: mediaQuery.boldText,
      textScaleFactor: mediaQuery.textScaleFactor,
      reducedMotion: mediaQuery.disableAnimations,
      buttonSize: mediaQuery.textScaleFactor > 1.2 ? 56.0 : 48.0,
    );
  }

  // Merge user settings with system recommendations
  static AccessibilitySettings mergeWithSystemSettings(
    AccessibilitySettings userSettings,
    BuildContext context,
  ) {
    final mediaQuery = MediaQuery.of(context);
    
    return userSettings.copyWith(
      textScaleFactor: mediaQuery.textScaleFactor > userSettings.textScaleFactor
          ? mediaQuery.textScaleFactor
          : userSettings.textScaleFactor,
      highContrastMode: userSettings.highContrastMode || mediaQuery.highContrast,
      boldText: userSettings.boldText || mediaQuery.boldText,
      reducedMotion: userSettings.reducedMotion || mediaQuery.disableAnimations,
    );
  }
}