enum AppThemeMode {
  light,
  dark,
  system,
}

enum FontSize {
  small,
  medium,
  large,
  extraLarge,
}

enum FontFamily {
  inter,
  openSans,
  roboto,
  sourceSerif,
  playfair,
  lora,
  merriweather,
}

enum ReadingMode {
  normal,
  sepia,
  highContrast,
}

enum LineSpacing {
  compact,
  normal,
  relaxed,
  loose,
}

class AppSettings {
  final AppThemeMode themeMode;
  final FontSize fontSize;
  final FontFamily fontFamily;
  final ReadingMode readingMode;
  final LineSpacing lineSpacing;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.fontSize = FontSize.medium,
    this.fontFamily = FontFamily.inter,
    this.readingMode = ReadingMode.normal,
    this.lineSpacing = LineSpacing.normal,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      fontSize: FontSize.values.firstWhere(
        (e) => e.name == json['fontSize'],
        orElse: () => FontSize.medium,
      ),
      fontFamily: FontFamily.values.firstWhere(
        (e) => e.name == json['fontFamily'],
        orElse: () => FontFamily.inter,
      ),
      readingMode: ReadingMode.values.firstWhere(
        (e) => e.name == json['readingMode'],
        orElse: () => ReadingMode.normal,
      ),
      lineSpacing: LineSpacing.values.firstWhere(
        (e) => e.name == json['lineSpacing'],
        orElse: () => LineSpacing.normal,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'fontSize': fontSize.name,
      'fontFamily': fontFamily.name,
      'readingMode': readingMode.name,
      'lineSpacing': lineSpacing.name,
    };
  }

  AppSettings copyWith({
    AppThemeMode? themeMode,
    FontSize? fontSize,
    FontFamily? fontFamily,
    ReadingMode? readingMode,
    LineSpacing? lineSpacing,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      readingMode: readingMode ?? this.readingMode,
      lineSpacing: lineSpacing ?? this.lineSpacing,
    );
  }

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, fontSize: $fontSize, fontFamily: $fontFamily, readingMode: $readingMode, lineSpacing: $lineSpacing)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.fontSize == fontSize &&
        other.fontFamily == fontFamily &&
        other.readingMode == readingMode &&
        other.lineSpacing == lineSpacing;
  }

  @override
  int get hashCode => Object.hash(themeMode, fontSize, fontFamily, readingMode, lineSpacing);
}

extension FontSizeExtension on FontSize {
  double get value {
    switch (this) {
      case FontSize.small:
        return 14.0;
      case FontSize.medium:
        return 16.0;
      case FontSize.large:
        return 18.0;
      case FontSize.extraLarge:
        return 20.0;
    }
  }

  String get displayName {
    switch (this) {
      case FontSize.small:
        return 'Small';
      case FontSize.medium:
        return 'Medium';
      case FontSize.large:
        return 'Large';
      case FontSize.extraLarge:
        return 'Extra Large';
    }
  }
}

extension FontFamilyExtension on FontFamily {
  String get displayName {
    switch (this) {
      case FontFamily.inter:
        return 'Inter';
      case FontFamily.openSans:
        return 'Open Sans';
      case FontFamily.roboto:
        return 'Roboto';
      case FontFamily.sourceSerif:
        return 'Source Serif Pro';
      case FontFamily.playfair:
        return 'Playfair Display';
      case FontFamily.lora:
        return 'Lora';
      case FontFamily.merriweather:
        return 'Merriweather';
    }
  }

  String get googleFontName {
    switch (this) {
      case FontFamily.inter:
        return 'Inter';
      case FontFamily.openSans:
        return 'Open Sans';
      case FontFamily.roboto:
        return 'Roboto';
      case FontFamily.sourceSerif:
        return 'Source Serif Pro';
      case FontFamily.playfair:
        return 'Playfair Display';
      case FontFamily.lora:
        return 'Lora';
      case FontFamily.merriweather:
        return 'Merriweather';
    }
  }
}

extension ReadingModeExtension on ReadingMode {
  String get displayName {
    switch (this) {
      case ReadingMode.normal:
        return 'Normal';
      case ReadingMode.sepia:
        return 'Sepia';
      case ReadingMode.highContrast:
        return 'High Contrast';
    }
  }
}

extension LineSpacingExtension on LineSpacing {
  double get value {
    switch (this) {
      case LineSpacing.compact:
        return 1.2;
      case LineSpacing.normal:
        return 1.5;
      case LineSpacing.relaxed:
        return 1.8;
      case LineSpacing.loose:
        return 2.0;
    }
  }

  String get displayName {
    switch (this) {
      case LineSpacing.compact:
        return 'Compact';
      case LineSpacing.normal:
        return 'Normal';
      case LineSpacing.relaxed:
        return 'Relaxed';
      case LineSpacing.loose:
        return 'Loose';
    }
  }
}