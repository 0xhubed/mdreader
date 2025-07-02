import 'package:flutter/material.dart';

enum DisplayMode {
  normal;

  String get displayName {
    switch (this) {
      case DisplayMode.normal:
        return 'Normal';
    }
  }

  String get description {
    switch (this) {
      case DisplayMode.normal:
        return 'Standard reading view with all UI elements';
    }
  }

  IconData get icon {
    switch (this) {
      case DisplayMode.normal:
        return Icons.view_comfortable;
    }
  }
}

class ReadingSettings {
  final DisplayMode displayMode;
  final bool showScrollbar;
  final bool showProgress;
  final bool showTableOfContents;
  final bool autoHideControls;
  final Duration autoHideDelay;
  final double textScaleFactor;
  final EdgeInsets contentPadding;

  const ReadingSettings({
    this.displayMode = DisplayMode.normal,
    this.showScrollbar = true,
    this.showProgress = true,
    this.showTableOfContents = true,
    this.autoHideControls = false,
    this.autoHideDelay = const Duration(seconds: 3),
    this.textScaleFactor = 1.0,
    this.contentPadding = const EdgeInsets.all(16),
  });

  ReadingSettings copyWith({
    DisplayMode? displayMode,
    bool? showScrollbar,
    bool? showProgress,
    bool? showTableOfContents,
    bool? autoHideControls,
    Duration? autoHideDelay,
    double? textScaleFactor,
    EdgeInsets? contentPadding,
  }) {
    return ReadingSettings(
      displayMode: displayMode ?? this.displayMode,
      showScrollbar: showScrollbar ?? this.showScrollbar,
      showProgress: showProgress ?? this.showProgress,
      showTableOfContents: showTableOfContents ?? this.showTableOfContents,
      autoHideControls: autoHideControls ?? this.autoHideControls,
      autoHideDelay: autoHideDelay ?? this.autoHideDelay,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }

  // Presets for different display modes
  static ReadingSettings forDisplayMode(DisplayMode mode) {
    switch (mode) {
      case DisplayMode.normal:
        return const ReadingSettings();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'displayMode': displayMode.index,
      'showScrollbar': showScrollbar,
      'showProgress': showProgress,
      'showTableOfContents': showTableOfContents,
      'autoHideControls': autoHideControls,
      'autoHideDelaySeconds': autoHideDelay.inSeconds,
      'textScaleFactor': textScaleFactor,
      'contentPaddingLeft': contentPadding.left,
      'contentPaddingTop': contentPadding.top,
      'contentPaddingRight': contentPadding.right,
      'contentPaddingBottom': contentPadding.bottom,
    };
  }

  factory ReadingSettings.fromJson(Map<String, dynamic> json) {
    return ReadingSettings(
      displayMode: DisplayMode.values[json['displayMode'] ?? 0],
      showScrollbar: json['showScrollbar'] ?? true,
      showProgress: json['showProgress'] ?? true,
      showTableOfContents: json['showTableOfContents'] ?? true,
      autoHideControls: json['autoHideControls'] ?? false,
      autoHideDelay: Duration(seconds: json['autoHideDelaySeconds'] ?? 3),
      textScaleFactor: json['textScaleFactor'] ?? 1.0,
      contentPadding: EdgeInsets.fromLTRB(
        json['contentPaddingLeft'] ?? 16,
        json['contentPaddingTop'] ?? 16,
        json['contentPaddingRight'] ?? 16,
        json['contentPaddingBottom'] ?? 16,
      ),
    );
  }
}