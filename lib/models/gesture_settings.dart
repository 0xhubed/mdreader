import 'package:flutter/services.dart';

enum GestureAction {
  none,
  scrollUp,
  scrollDown,
  goToTop,
  goToBottom,
  openSearch,
  closeSearch,
  openTableOfContents,
  addBookmark,
  openSettings,
  toggleTheme,
  toggleReadingMode,
  toggleDisplayMode,
  goBack,
  openFile,
  zoomIn,
  zoomOut,
  resetZoom;

  String get displayName {
    switch (this) {
      case GestureAction.none:
        return 'None';
      case GestureAction.scrollUp:
        return 'Scroll Up';
      case GestureAction.scrollDown:
        return 'Scroll Down';
      case GestureAction.goToTop:
        return 'Go to Top';
      case GestureAction.goToBottom:
        return 'Go to Bottom';
      case GestureAction.openSearch:
        return 'Open Search';
      case GestureAction.closeSearch:
        return 'Close Search';
      case GestureAction.openTableOfContents:
        return 'Open Table of Contents';
      case GestureAction.addBookmark:
        return 'Add Bookmark';
      case GestureAction.openSettings:
        return 'Open Settings';
      case GestureAction.toggleTheme:
        return 'Toggle Theme';
      case GestureAction.toggleReadingMode:
        return 'Toggle Reading Mode';
      case GestureAction.toggleDisplayMode:
        return 'Toggle Display Mode';
      case GestureAction.goBack:
        return 'Go Back';
      case GestureAction.openFile:
        return 'Open File';
      case GestureAction.zoomIn:
        return 'Zoom In';
      case GestureAction.zoomOut:
        return 'Zoom Out';
      case GestureAction.resetZoom:
        return 'Reset Zoom';
    }
  }

  String get description {
    switch (this) {
      case GestureAction.none:
        return 'No action assigned';
      case GestureAction.scrollUp:
        return 'Scroll content upward';
      case GestureAction.scrollDown:
        return 'Scroll content downward';
      case GestureAction.goToTop:
        return 'Jump to document beginning';
      case GestureAction.goToBottom:
        return 'Jump to document end';
      case GestureAction.openSearch:
        return 'Open document search';
      case GestureAction.closeSearch:
        return 'Close search interface';
      case GestureAction.openTableOfContents:
        return 'Show table of contents';
      case GestureAction.addBookmark:
        return 'Bookmark current position';
      case GestureAction.openSettings:
        return 'Open app settings';
      case GestureAction.toggleTheme:
        return 'Switch between light/dark theme';
      case GestureAction.toggleReadingMode:
        return 'Cycle through reading modes';
      case GestureAction.toggleDisplayMode:
        return 'Cycle through display modes';
      case GestureAction.goBack:
        return 'Return to previous screen';
      case GestureAction.openFile:
        return 'Open file picker';
      case GestureAction.zoomIn:
        return 'Increase text size';
      case GestureAction.zoomOut:
        return 'Decrease text size';
      case GestureAction.resetZoom:
        return 'Reset text size to default';
    }
  }
}

enum GestureType {
  tap,
  doubleTap,
  longPress,
  swipeLeft,
  swipeRight,
  swipeUp,
  swipeDown,
  pinchIn,
  pinchOut,
  twoFingerTap,
  threeFingerTap;

  String get displayName {
    switch (this) {
      case GestureType.tap:
        return 'Single Tap';
      case GestureType.doubleTap:
        return 'Double Tap';
      case GestureType.longPress:
        return 'Long Press';
      case GestureType.swipeLeft:
        return 'Swipe Left';
      case GestureType.swipeRight:
        return 'Swipe Right';
      case GestureType.swipeUp:
        return 'Swipe Up';
      case GestureType.swipeDown:
        return 'Swipe Down';
      case GestureType.pinchIn:
        return 'Pinch In';
      case GestureType.pinchOut:
        return 'Pinch Out';
      case GestureType.twoFingerTap:
        return 'Two Finger Tap';
      case GestureType.threeFingerTap:
        return 'Three Finger Tap';
    }
  }
}

class KeyboardShortcut {
  final Set<LogicalKeyboardKey> keys;
  final GestureAction action;
  final String description;

  const KeyboardShortcut({
    required this.keys,
    required this.action,
    required this.description,
  });

  String get displayString {
    return keys.map((key) => key.keyLabel).join(' + ');
  }

  bool matches(Set<LogicalKeyboardKey> pressedKeys) {
    return keys.length == pressedKeys.length &&
           keys.every((key) => pressedKeys.contains(key));
  }

  Map<String, dynamic> toJson() {
    return {
      'keys': keys.map((key) => key.keyId).toList(),
      'action': action.index,
      'description': description,
    };
  }

  factory KeyboardShortcut.fromJson(Map<String, dynamic> json) {
    return KeyboardShortcut(
      keys: (json['keys'] as List)
          .map((keyId) => LogicalKeyboardKey.findKeyByKeyId(keyId))
          .where((key) => key != null)
          .cast<LogicalKeyboardKey>()
          .toSet(),
      action: GestureAction.values[json['action']],
      description: json['description'],
    );
  }
}

class GestureSettings {
  final Map<GestureType, GestureAction> gestureMap;
  final List<KeyboardShortcut> keyboardShortcuts;
  final bool enableGestures;
  final bool enableKeyboardShortcuts;
  final double gestureThreshold;
  final bool hapticFeedbackOnGesture;

  const GestureSettings({
    this.gestureMap = const {},
    this.keyboardShortcuts = const [],
    this.enableGestures = true,
    this.enableKeyboardShortcuts = true,
    this.gestureThreshold = 50.0,
    this.hapticFeedbackOnGesture = true,
  });

  GestureSettings copyWith({
    Map<GestureType, GestureAction>? gestureMap,
    List<KeyboardShortcut>? keyboardShortcuts,
    bool? enableGestures,
    bool? enableKeyboardShortcuts,
    double? gestureThreshold,
    bool? hapticFeedbackOnGesture,
  }) {
    return GestureSettings(
      gestureMap: gestureMap ?? this.gestureMap,
      keyboardShortcuts: keyboardShortcuts ?? this.keyboardShortcuts,
      enableGestures: enableGestures ?? this.enableGestures,
      enableKeyboardShortcuts: enableKeyboardShortcuts ?? this.enableKeyboardShortcuts,
      gestureThreshold: gestureThreshold ?? this.gestureThreshold,
      hapticFeedbackOnGesture: hapticFeedbackOnGesture ?? this.hapticFeedbackOnGesture,
    );
  }

  // Default gesture mappings
  static GestureSettings get defaultSettings => GestureSettings(
    gestureMap: {
      GestureType.swipeUp: GestureAction.scrollUp,
      GestureType.swipeDown: GestureAction.scrollDown,
      GestureType.swipeLeft: GestureAction.goBack,
      GestureType.doubleTap: GestureAction.toggleTheme,
      GestureType.longPress: GestureAction.addBookmark,
      GestureType.pinchOut: GestureAction.zoomIn,
      GestureType.pinchIn: GestureAction.zoomOut,
      GestureType.twoFingerTap: GestureAction.openSearch,
      GestureType.threeFingerTap: GestureAction.openTableOfContents,
    },
    keyboardShortcuts: defaultKeyboardShortcuts,
  );

  // Reading-focused gesture mappings
  static GestureSettings get readingFocused => GestureSettings(
    gestureMap: {
      GestureType.swipeUp: GestureAction.scrollUp,
      GestureType.swipeDown: GestureAction.scrollDown,
      GestureType.swipeLeft: GestureAction.toggleReadingMode,
      GestureType.swipeRight: GestureAction.toggleDisplayMode,
      GestureType.doubleTap: GestureAction.goToTop,
      GestureType.longPress: GestureAction.addBookmark,
      GestureType.pinchOut: GestureAction.zoomIn,
      GestureType.pinchIn: GestureAction.zoomOut,
    },
    keyboardShortcuts: defaultKeyboardShortcuts,
  );

  static List<KeyboardShortcut> get defaultKeyboardShortcuts => [
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyF},
      action: GestureAction.openSearch,
      description: 'Open search',
    ),
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.escape},
      action: GestureAction.closeSearch,
      description: 'Close search',
    ),
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyO},
      action: GestureAction.openFile,
      description: 'Open file',
    ),
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyB},
      action: GestureAction.addBookmark,
      description: 'Add bookmark',
    ),
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyT},
      action: GestureAction.toggleTheme,
      description: 'Toggle theme',
    ),
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.home},
      action: GestureAction.goToTop,
      description: 'Go to top',
    ),
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.end},
      action: GestureAction.goToBottom,
      description: 'Go to bottom',
    ),
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.control, LogicalKeyboardKey.equal},
      action: GestureAction.zoomIn,
      description: 'Zoom in',
    ),
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.control, LogicalKeyboardKey.minus},
      action: GestureAction.zoomOut,
      description: 'Zoom out',
    ),
    const KeyboardShortcut(
      keys: {LogicalKeyboardKey.control, LogicalKeyboardKey.digit0},
      action: GestureAction.resetZoom,
      description: 'Reset zoom',
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'gestureMap': gestureMap.map(
        (key, value) => MapEntry(key.index.toString(), value.index),
      ),
      'keyboardShortcuts': keyboardShortcuts.map((shortcut) => shortcut.toJson()).toList(),
      'enableGestures': enableGestures,
      'enableKeyboardShortcuts': enableKeyboardShortcuts,
      'gestureThreshold': gestureThreshold,
      'hapticFeedbackOnGesture': hapticFeedbackOnGesture,
    };
  }

  factory GestureSettings.fromJson(Map<String, dynamic> json) {
    final gestureMapJson = json['gestureMap'] as Map<String, dynamic>? ?? {};
    final gestureMap = <GestureType, GestureAction>{};
    
    gestureMapJson.forEach((key, value) {
      final gestureTypeIndex = int.tryParse(key);
      if (gestureTypeIndex != null && 
          gestureTypeIndex < GestureType.values.length &&
          value < GestureAction.values.length) {
        gestureMap[GestureType.values[gestureTypeIndex]] = GestureAction.values[value];
      }
    });

    final shortcutsJson = json['keyboardShortcuts'] as List? ?? [];
    final shortcuts = shortcutsJson
        .map((shortcutJson) => KeyboardShortcut.fromJson(shortcutJson))
        .toList();

    return GestureSettings(
      gestureMap: gestureMap,
      keyboardShortcuts: shortcuts,
      enableGestures: json['enableGestures'] ?? true,
      enableKeyboardShortcuts: json['enableKeyboardShortcuts'] ?? true,
      gestureThreshold: json['gestureThreshold'] ?? 50.0,
      hapticFeedbackOnGesture: json['hapticFeedbackOnGesture'] ?? true,
    );
  }
}