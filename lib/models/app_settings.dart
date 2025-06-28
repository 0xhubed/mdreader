enum AppThemeMode {
  light,
  dark,
  system,
}

enum FontSize {
  small,
  medium,
  large,
}

class AppSettings {
  final AppThemeMode themeMode;
  final FontSize fontSize;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.fontSize = FontSize.medium,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'fontSize': fontSize.name,
    };
  }

  AppSettings copyWith({
    AppThemeMode? themeMode,
    FontSize? fontSize,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, fontSize: $fontSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.fontSize == fontSize;
  }

  @override
  int get hashCode => Object.hash(themeMode, fontSize);
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
    }
  }
}