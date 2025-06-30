import 'package:flutter/material.dart';

class AccessibilitySettings {
  final bool enableScreenReader;
  final bool highContrastMode;
  final bool reducedMotion;
  final bool largeText;
  final bool boldText;
  final double textScaleFactor;
  final bool showFocusIndicators;
  final bool enableVoiceOver;
  final Color focusColor;
  final double buttonSize;
  final bool hapticFeedback;
  final bool soundFeedback;

  const AccessibilitySettings({
    this.enableScreenReader = false,
    this.highContrastMode = false,
    this.reducedMotion = false,
    this.largeText = false,
    this.boldText = false,
    this.textScaleFactor = 1.0,
    this.showFocusIndicators = true,
    this.enableVoiceOver = false,
    this.focusColor = Colors.blue,
    this.buttonSize = 48.0,
    this.hapticFeedback = true,
    this.soundFeedback = false,
  });

  AccessibilitySettings copyWith({
    bool? enableScreenReader,
    bool? highContrastMode,
    bool? reducedMotion,
    bool? largeText,
    bool? boldText,
    double? textScaleFactor,
    bool? showFocusIndicators,
    bool? enableVoiceOver,
    Color? focusColor,
    double? buttonSize,
    bool? hapticFeedback,
    bool? soundFeedback,
  }) {
    return AccessibilitySettings(
      enableScreenReader: enableScreenReader ?? this.enableScreenReader,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      largeText: largeText ?? this.largeText,
      boldText: boldText ?? this.boldText,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      showFocusIndicators: showFocusIndicators ?? this.showFocusIndicators,
      enableVoiceOver: enableVoiceOver ?? this.enableVoiceOver,
      focusColor: focusColor ?? this.focusColor,
      buttonSize: buttonSize ?? this.buttonSize,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundFeedback: soundFeedback ?? this.soundFeedback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableScreenReader': enableScreenReader,
      'highContrastMode': highContrastMode,
      'reducedMotion': reducedMotion,
      'largeText': largeText,
      'boldText': boldText,
      'textScaleFactor': textScaleFactor,
      'showFocusIndicators': showFocusIndicators,
      'enableVoiceOver': enableVoiceOver,
      'focusColor': focusColor.value,
      'buttonSize': buttonSize,
      'hapticFeedback': hapticFeedback,
      'soundFeedback': soundFeedback,
    };
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      enableScreenReader: json['enableScreenReader'] ?? false,
      highContrastMode: json['highContrastMode'] ?? false,
      reducedMotion: json['reducedMotion'] ?? false,
      largeText: json['largeText'] ?? false,
      boldText: json['boldText'] ?? false,
      textScaleFactor: json['textScaleFactor'] ?? 1.0,
      showFocusIndicators: json['showFocusIndicators'] ?? true,
      enableVoiceOver: json['enableVoiceOver'] ?? false,
      focusColor: Color(json['focusColor'] ?? Colors.blue.value),
      buttonSize: json['buttonSize'] ?? 48.0,
      hapticFeedback: json['hapticFeedback'] ?? true,
      soundFeedback: json['soundFeedback'] ?? false,
    );
  }

  // Quick preset configurations
  static AccessibilitySettings get defaultSettings => const AccessibilitySettings();

  static AccessibilitySettings get highAccessibility => const AccessibilitySettings(
    enableScreenReader: true,
    highContrastMode: true,
    largeText: true,
    boldText: true,
    textScaleFactor: 1.3,
    showFocusIndicators: true,
    buttonSize: 56.0,
    hapticFeedback: true,
  );

  static AccessibilitySettings get visualImpairment => const AccessibilitySettings(
    highContrastMode: true,
    largeText: true,
    boldText: true,
    textScaleFactor: 1.5,
    showFocusIndicators: true,
    buttonSize: 60.0,
    hapticFeedback: true,
    soundFeedback: true,
  );

  static AccessibilitySettings get motorImpairment => const AccessibilitySettings(
    buttonSize: 64.0,
    showFocusIndicators: true,
    hapticFeedback: true,
    reducedMotion: true,
  );

  // Check if any accessibility features are enabled
  bool get hasAnyFeatureEnabled {
    return enableScreenReader ||
           highContrastMode ||
           reducedMotion ||
           largeText ||
           boldText ||
           textScaleFactor != 1.0 ||
           enableVoiceOver ||
           buttonSize != 48.0 ||
           !hapticFeedback ||
           soundFeedback;
  }

  // Get description of active features
  String get activeFeatures {
    final features = <String>[];
    
    if (enableScreenReader) features.add('Screen Reader');
    if (highContrastMode) features.add('High Contrast');
    if (reducedMotion) features.add('Reduced Motion');
    if (largeText) features.add('Large Text');
    if (boldText) features.add('Bold Text');
    if (textScaleFactor != 1.0) features.add('Text Scale: ${(textScaleFactor * 100).round()}%');
    if (enableVoiceOver) features.add('Voice Over');
    if (buttonSize > 48.0) features.add('Large Buttons');
    if (!hapticFeedback) features.add('No Haptic');
    if (soundFeedback) features.add('Sound Feedback');
    
    return features.isEmpty ? 'None' : features.join(', ');
  }
}