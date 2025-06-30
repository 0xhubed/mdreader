import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/accessibility_settings.dart';
import '../services/accessibility_service.dart';

class AccessibilityProvider with ChangeNotifier {
  late AccessibilityService _accessibilityService;
  AccessibilitySettings _settings = AccessibilitySettings.defaultSettings;
  bool _isLoading = true;

  AccessibilitySettings get settings => _settings;
  bool get isLoading => _isLoading;

  // Individual getters for convenience
  bool get enableScreenReader => _settings.enableScreenReader;
  bool get highContrastMode => _settings.highContrastMode;
  bool get reducedMotion => _settings.reducedMotion;
  bool get largeText => _settings.largeText;
  bool get boldText => _settings.boldText;
  double get textScaleFactor => _settings.textScaleFactor;
  bool get showFocusIndicators => _settings.showFocusIndicators;
  bool get enableVoiceOver => _settings.enableVoiceOver;
  Color get focusColor => _settings.focusColor;
  double get buttonSize => _settings.buttonSize;
  bool get hapticFeedback => _settings.hapticFeedback;
  bool get soundFeedback => _settings.soundFeedback;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessibilityService = AccessibilityService(prefs);
      
      _settings = await _accessibilityService.loadSettings();
      
      // Apply system-level accessibility
      AccessibilityService.applySystemAccessibility(_settings);
    } catch (e) {
      debugPrint('Failed to initialize accessibility settings: $e');
      _settings = AccessibilitySettings.defaultSettings;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSettings(AccessibilitySettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    
    try {
      await _accessibilityService.saveSettings(newSettings);
      AccessibilityService.applySystemAccessibility(newSettings);
    } catch (e) {
      debugPrint('Failed to save accessibility settings: $e');
    }
  }

  // Individual setters for convenience
  Future<void> setScreenReaderEnabled(bool enabled) async {
    await updateSettings(_settings.copyWith(enableScreenReader: enabled));
  }

  Future<void> setHighContrastMode(bool enabled) async {
    await updateSettings(_settings.copyWith(highContrastMode: enabled));
  }

  Future<void> setReducedMotion(bool enabled) async {
    await updateSettings(_settings.copyWith(reducedMotion: enabled));
  }

  Future<void> setLargeText(bool enabled) async {
    await updateSettings(_settings.copyWith(largeText: enabled));
  }

  Future<void> setBoldText(bool enabled) async {
    await updateSettings(_settings.copyWith(boldText: enabled));
  }

  Future<void> setTextScaleFactor(double factor) async {
    await updateSettings(_settings.copyWith(textScaleFactor: factor));
  }

  Future<void> setFocusIndicators(bool enabled) async {
    await updateSettings(_settings.copyWith(showFocusIndicators: enabled));
  }

  Future<void> setVoiceOverEnabled(bool enabled) async {
    await updateSettings(_settings.copyWith(enableVoiceOver: enabled));
  }

  Future<void> setFocusColor(Color color) async {
    await updateSettings(_settings.copyWith(focusColor: color));
  }

  Future<void> setButtonSize(double size) async {
    await updateSettings(_settings.copyWith(buttonSize: size));
  }

  Future<void> setHapticFeedback(bool enabled) async {
    await updateSettings(_settings.copyWith(hapticFeedback: enabled));
  }

  Future<void> setSoundFeedback(bool enabled) async {
    await updateSettings(_settings.copyWith(soundFeedback: enabled));
  }

  // Apply preset configurations
  Future<void> applyPreset(AccessibilitySettings preset) async {
    await updateSettings(preset);
    
    // Provide feedback
    if (preset.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    await updateSettings(AccessibilitySettings.defaultSettings);
  }

  // Get effective text scale factor (combines user setting with system setting)
  double getEffectiveTextScaleFactor(BuildContext context) {
    final systemScale = MediaQuery.of(context).textScaleFactor;
    return systemScale * _settings.textScaleFactor;
  }

  // Get effective button size
  double getEffectiveButtonSize(BuildContext context) {
    final systemScale = MediaQuery.of(context).textScaleFactor;
    return _settings.buttonSize * (systemScale > 1.0 ? systemScale : 1.0);
  }

  // Check if high contrast should be applied
  bool shouldUseHighContrast(BuildContext context) {
    return _settings.highContrastMode || MediaQuery.of(context).highContrast;
  }

  // Check if animations should be reduced
  bool shouldReduceMotion(BuildContext context) {
    return _settings.reducedMotion || MediaQuery.of(context).disableAnimations;
  }

  // Provide haptic feedback if enabled
  void provideFeedback([HapticFeedback? feedback]) {
    if (_settings.hapticFeedback) {
      (feedback ?? HapticFeedback.lightImpact)();
    }
  }

  // Announce message for screen readers
  void announceForAccessibility(BuildContext context, String message) {
    if (_settings.enableScreenReader) {
      AccessibilityService.announceForAccessibility(context, message);
    }
  }

  // Auto-configure based on system accessibility settings
  Future<void> autoConfigureFromSystem(BuildContext context) async {
    final systemSettings = AccessibilityService.getRecommendedSettings(context);
    await updateSettings(systemSettings);
  }

  // Get accessibility summary for display
  String get accessibilitySummary => _settings.activeFeatures;
}