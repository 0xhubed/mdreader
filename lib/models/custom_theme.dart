import 'dart:convert';
import 'package:flutter/material.dart';

class CustomTheme {
  final String id;
  final String name;
  final String description;
  final bool isDark;
  final Map<String, Color> colors;
  final Map<String, double> textScales;
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final bool isBuiltIn;

  CustomTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.isDark,
    required this.colors,
    required this.textScales,
    required this.fontFamily,
    required this.fontSize,
    required this.lineHeight,
    required this.createdAt,
    this.modifiedAt,
    this.isBuiltIn = false,
  });

  // Color keys
  static const String primaryColorKey = 'primary';
  static const String secondaryColorKey = 'secondary';
  static const String backgroundColorKey = 'background';
  static const String surfaceColorKey = 'surface';
  static const String errorColorKey = 'error';
  static const String onPrimaryColorKey = 'onPrimary';
  static const String onSecondaryColorKey = 'onSecondary';
  static const String onBackgroundColorKey = 'onBackground';
  static const String onSurfaceColorKey = 'onSurface';
  static const String onErrorColorKey = 'onError';
  static const String textPrimaryColorKey = 'textPrimary';
  static const String textSecondaryColorKey = 'textSecondary';
  static const String dividerColorKey = 'divider';
  static const String shadowColorKey = 'shadow';
  static const String codeBackgroundColorKey = 'codeBackground';
  static const String codeTextColorKey = 'codeText';
  static const String linkColorKey = 'link';
  static const String selectionColorKey = 'selection';

  // Text scale keys
  static const String h1ScaleKey = 'h1';
  static const String h2ScaleKey = 'h2';
  static const String h3ScaleKey = 'h3';
  static const String h4ScaleKey = 'h4';
  static const String h5ScaleKey = 'h5';
  static const String h6ScaleKey = 'h6';
  static const String bodyScaleKey = 'body';
  static const String captionScaleKey = 'caption';

  // Default color values
  static Map<String, Color> defaultLightColors() => {
    primaryColorKey: const Color(0xFF1A73E8),
    secondaryColorKey: const Color(0xFF0288D1),
    backgroundColorKey: const Color(0xFFFAFAFA),
    surfaceColorKey: const Color(0xFFFFFFFF),
    errorColorKey: const Color(0xFFD32F2F),
    onPrimaryColorKey: const Color(0xFFFFFFFF),
    onSecondaryColorKey: const Color(0xFFFFFFFF),
    onBackgroundColorKey: const Color(0xFF212121),
    onSurfaceColorKey: const Color(0xFF212121),
    onErrorColorKey: const Color(0xFFFFFFFF),
    textPrimaryColorKey: const Color(0xFF212121),
    textSecondaryColorKey: const Color(0xFF757575),
    dividerColorKey: const Color(0xFFE0E0E0),
    shadowColorKey: const Color(0x1F000000),
    codeBackgroundColorKey: const Color(0xFFF5F5F5),
    codeTextColorKey: const Color(0xFF37474F),
    linkColorKey: const Color(0xFF1565C0),
    selectionColorKey: const Color(0x3D1A73E8),
  };

  static Map<String, Color> defaultDarkColors() => {
    primaryColorKey: const Color(0xFF4285F4),
    secondaryColorKey: const Color(0xFF039BE5),
    backgroundColorKey: const Color(0xFF121212),
    surfaceColorKey: const Color(0xFF1E1E1E),
    errorColorKey: const Color(0xFFEF5350),
    onPrimaryColorKey: const Color(0xFF000000),
    onSecondaryColorKey: const Color(0xFF000000),
    onBackgroundColorKey: const Color(0xFFE0E0E0),
    onSurfaceColorKey: const Color(0xFFE0E0E0),
    onErrorColorKey: const Color(0xFF000000),
    textPrimaryColorKey: const Color(0xFFE0E0E0),
    textSecondaryColorKey: const Color(0xFF9E9E9E),
    dividerColorKey: const Color(0xFF424242),
    shadowColorKey: const Color(0x3D000000),
    codeBackgroundColorKey: const Color(0xFF263238),
    codeTextColorKey: const Color(0xFFB0BEC5),
    linkColorKey: const Color(0xFF64B5F6),
    selectionColorKey: const Color(0x3D4285F4),
  };

  // Default text scales
  static Map<String, double> defaultTextScales() => {
    h1ScaleKey: 2.0,
    h2ScaleKey: 1.75,
    h3ScaleKey: 1.5,
    h4ScaleKey: 1.25,
    h5ScaleKey: 1.125,
    h6ScaleKey: 1.0,
    bodyScaleKey: 1.0,
    captionScaleKey: 0.875,
  };

  ThemeData toThemeData() {
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
    
    return baseTheme.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors[primaryColorKey]!,
        onPrimary: colors[onPrimaryColorKey]!,
        secondary: colors[secondaryColorKey]!,
        onSecondary: colors[onSecondaryColorKey]!,
        error: colors[errorColorKey]!,
        onError: colors[onErrorColorKey]!,
        surface: colors[surfaceColorKey]!,
        onSurface: colors[onSurfaceColorKey]!,
        background: colors[backgroundColorKey]!,
        onBackground: colors[onBackgroundColorKey]!,
      ),
      scaffoldBackgroundColor: colors[backgroundColorKey],
      dividerColor: colors[dividerColorKey],
      shadowColor: colors[shadowColorKey],
    );
  }

  CustomTheme copyWith({
    String? id,
    String? name,
    String? description,
    bool? isDark,
    Map<String, Color>? colors,
    Map<String, double>? textScales,
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? isBuiltIn,
  }) {
    return CustomTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isDark: isDark ?? this.isDark,
      colors: colors ?? Map.from(this.colors),
      textScales: textScales ?? Map.from(this.textScales),
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isDark': isDark,
      'colors': colors.map((key, color) => MapEntry(key, color.value)),
      'textScales': textScales,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
      'isBuiltIn': isBuiltIn,
    };
  }

  factory CustomTheme.fromJson(Map<String, dynamic> json) {
    return CustomTheme(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isDark: json['isDark'],
      colors: (json['colors'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Color(value as int)),
      ),
      textScales: (json['textScales'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      fontFamily: json['fontFamily'],
      fontSize: (json['fontSize'] as num).toDouble(),
      lineHeight: (json['lineHeight'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: json['modifiedAt'] != null 
        ? DateTime.parse(json['modifiedAt']) 
        : null,
      isBuiltIn: json['isBuiltIn'] ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory CustomTheme.fromJsonString(String jsonString) {
    return CustomTheme.fromJson(jsonDecode(jsonString));
  }
}

// Theme presets
class ThemePresets {
  static CustomTheme get defaultLight => CustomTheme(
    id: 'default_light',
    name: 'Default Light',
    description: 'Clean and modern light theme',
    isDark: false,
    colors: CustomTheme.defaultLightColors(),
    textScales: CustomTheme.defaultTextScales(),
    fontFamily: 'Inter',
    fontSize: 16.0,
    lineHeight: 1.5,
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  static CustomTheme get defaultDark => CustomTheme(
    id: 'default_dark',
    name: 'Default Dark',
    description: 'Easy on the eyes dark theme',
    isDark: true,
    colors: CustomTheme.defaultDarkColors(),
    textScales: CustomTheme.defaultTextScales(),
    fontFamily: 'Inter',
    fontSize: 16.0,
    lineHeight: 1.5,
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  static CustomTheme get sepia => CustomTheme(
    id: 'sepia',
    name: 'Sepia',
    description: 'Warm and comfortable reading theme',
    isDark: false,
    colors: {
      CustomTheme.primaryColorKey: const Color(0xFF8D6E63),
      CustomTheme.secondaryColorKey: const Color(0xFF6D4C41),
      CustomTheme.backgroundColorKey: const Color(0xFFF4F1EA),
      CustomTheme.surfaceColorKey: const Color(0xFFFAF8F3),
      CustomTheme.errorColorKey: const Color(0xFFBF360C),
      CustomTheme.onPrimaryColorKey: const Color(0xFFFFFFFF),
      CustomTheme.onSecondaryColorKey: const Color(0xFFFFFFFF),
      CustomTheme.onBackgroundColorKey: const Color(0xFF5D4037),
      CustomTheme.onSurfaceColorKey: const Color(0xFF5D4037),
      CustomTheme.onErrorColorKey: const Color(0xFFFFFFFF),
      CustomTheme.textPrimaryColorKey: const Color(0xFF5D4037),
      CustomTheme.textSecondaryColorKey: const Color(0xFF795548),
      CustomTheme.dividerColorKey: const Color(0xFFD7CCC8),
      CustomTheme.shadowColorKey: const Color(0x1F5D4037),
      CustomTheme.codeBackgroundColorKey: const Color(0xFFEFEBE9),
      CustomTheme.codeTextColorKey: const Color(0xFF4E342E),
      CustomTheme.linkColorKey: const Color(0xFF6D4C41),
      CustomTheme.selectionColorKey: const Color(0x3D8D6E63),
    },
    textScales: CustomTheme.defaultTextScales(),
    fontFamily: 'Merriweather',
    fontSize: 16.0,
    lineHeight: 1.6,
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  static CustomTheme get highContrast => CustomTheme(
    id: 'high_contrast',
    name: 'High Contrast',
    description: 'Maximum readability with strong contrast',
    isDark: false,
    colors: {
      CustomTheme.primaryColorKey: const Color(0xFF000000),
      CustomTheme.secondaryColorKey: const Color(0xFF000000),
      CustomTheme.backgroundColorKey: const Color(0xFFFFFFFF),
      CustomTheme.surfaceColorKey: const Color(0xFFFFFFFF),
      CustomTheme.errorColorKey: const Color(0xFFFF0000),
      CustomTheme.onPrimaryColorKey: const Color(0xFFFFFFFF),
      CustomTheme.onSecondaryColorKey: const Color(0xFFFFFFFF),
      CustomTheme.onBackgroundColorKey: const Color(0xFF000000),
      CustomTheme.onSurfaceColorKey: const Color(0xFF000000),
      CustomTheme.onErrorColorKey: const Color(0xFFFFFFFF),
      CustomTheme.textPrimaryColorKey: const Color(0xFF000000),
      CustomTheme.textSecondaryColorKey: const Color(0xFF000000),
      CustomTheme.dividerColorKey: const Color(0xFF000000),
      CustomTheme.shadowColorKey: const Color(0xFF000000),
      CustomTheme.codeBackgroundColorKey: const Color(0xFFF0F0F0),
      CustomTheme.codeTextColorKey: const Color(0xFF000000),
      CustomTheme.linkColorKey: const Color(0xFF0000FF),
      CustomTheme.selectionColorKey: const Color(0xFFFFFF00),
    },
    textScales: CustomTheme.defaultTextScales(),
    fontFamily: 'Open Sans',
    fontSize: 18.0,
    lineHeight: 1.8,
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  static CustomTheme get midnight => CustomTheme(
    id: 'midnight',
    name: 'Midnight',
    description: 'Deep blue theme for night reading',
    isDark: true,
    colors: {
      CustomTheme.primaryColorKey: const Color(0xFF64B5F6),
      CustomTheme.secondaryColorKey: const Color(0xFF4FC3F7),
      CustomTheme.backgroundColorKey: const Color(0xFF0D1117),
      CustomTheme.surfaceColorKey: const Color(0xFF161B22),
      CustomTheme.errorColorKey: const Color(0xFFFF6B6B),
      CustomTheme.onPrimaryColorKey: const Color(0xFF000000),
      CustomTheme.onSecondaryColorKey: const Color(0xFF000000),
      CustomTheme.onBackgroundColorKey: const Color(0xFFC9D1D9),
      CustomTheme.onSurfaceColorKey: const Color(0xFFC9D1D9),
      CustomTheme.onErrorColorKey: const Color(0xFF000000),
      CustomTheme.textPrimaryColorKey: const Color(0xFFC9D1D9),
      CustomTheme.textSecondaryColorKey: const Color(0xFF8B949E),
      CustomTheme.dividerColorKey: const Color(0xFF30363D),
      CustomTheme.shadowColorKey: const Color(0xFF000000),
      CustomTheme.codeBackgroundColorKey: const Color(0xFF0D1117),
      CustomTheme.codeTextColorKey: const Color(0xFF7EE787),
      CustomTheme.linkColorKey: const Color(0xFF58A6FF),
      CustomTheme.selectionColorKey: const Color(0x3D58A6FF),
    },
    textScales: CustomTheme.defaultTextScales(),
    fontFamily: 'Source Serif Pro',
    fontSize: 16.0,
    lineHeight: 1.5,
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  static CustomTheme get forest => CustomTheme(
    id: 'forest',
    name: 'Forest',
    description: 'Natural green theme for comfortable reading',
    isDark: false,
    colors: {
      CustomTheme.primaryColorKey: const Color(0xFF2E7D32),
      CustomTheme.secondaryColorKey: const Color(0xFF388E3C),
      CustomTheme.backgroundColorKey: const Color(0xFFF1F8E9),
      CustomTheme.surfaceColorKey: const Color(0xFFF9FBF7),
      CustomTheme.errorColorKey: const Color(0xFFC62828),
      CustomTheme.onPrimaryColorKey: const Color(0xFFFFFFFF),
      CustomTheme.onSecondaryColorKey: const Color(0xFFFFFFFF),
      CustomTheme.onBackgroundColorKey: const Color(0xFF1B5E20),
      CustomTheme.onSurfaceColorKey: const Color(0xFF1B5E20),
      CustomTheme.onErrorColorKey: const Color(0xFFFFFFFF),
      CustomTheme.textPrimaryColorKey: const Color(0xFF1B5E20),
      CustomTheme.textSecondaryColorKey: const Color(0xFF558B2F),
      CustomTheme.dividerColorKey: const Color(0xFFC8E6C9),
      CustomTheme.shadowColorKey: const Color(0x1F1B5E20),
      CustomTheme.codeBackgroundColorKey: const Color(0xFFE8F5E9),
      CustomTheme.codeTextColorKey: const Color(0xFF2E7D32),
      CustomTheme.linkColorKey: const Color(0xFF388E3C),
      CustomTheme.selectionColorKey: const Color(0x3D4CAF50),
    },
    textScales: CustomTheme.defaultTextScales(),
    fontFamily: 'Lora',
    fontSize: 16.0,
    lineHeight: 1.6,
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  static List<CustomTheme> get all => [
    defaultLight,
    defaultDark,
    sepia,
    highContrast,
    midnight,
    forest,
  ];
}