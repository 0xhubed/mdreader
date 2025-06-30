import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_theme.dart';

class ThemeService {
  static const String _customThemesKey = 'custom_themes';
  static const String _activeThemeIdKey = 'active_theme_id';
  
  final SharedPreferences _prefs;
  
  ThemeService(this._prefs);

  // Get all themes (built-in + custom)
  Future<List<CustomTheme>> getAllThemes() async {
    final builtInThemes = ThemePresets.all;
    final customThemes = await getCustomThemes();
    return [...builtInThemes, ...customThemes];
  }

  // Get only custom themes
  Future<List<CustomTheme>> getCustomThemes() async {
    final themesJson = _prefs.getStringList(_customThemesKey) ?? [];
    return themesJson
        .map((json) => CustomTheme.fromJsonString(json))
        .toList();
  }

  // Save a custom theme
  Future<void> saveCustomTheme(CustomTheme theme) async {
    final themes = await getCustomThemes();
    
    // Remove existing theme with same ID if updating
    themes.removeWhere((t) => t.id == theme.id);
    
    // Add the new/updated theme
    themes.add(theme.copyWith(
      modifiedAt: DateTime.now(),
    ));
    
    // Save to preferences
    final themesJson = themes.map((t) => t.toJsonString()).toList();
    await _prefs.setStringList(_customThemesKey, themesJson);
  }

  // Delete a custom theme
  Future<void> deleteCustomTheme(String themeId) async {
    final themes = await getCustomThemes();
    themes.removeWhere((t) => t.id == themeId);
    
    final themesJson = themes.map((t) => t.toJsonString()).toList();
    await _prefs.setStringList(_customThemesKey, themesJson);
    
    // If the deleted theme was active, clear the active theme
    final activeThemeId = await getActiveThemeId();
    if (activeThemeId == themeId) {
      await clearActiveTheme();
    }
  }

  // Get theme by ID
  Future<CustomTheme?> getThemeById(String themeId) async {
    final allThemes = await getAllThemes();
    try {
      return allThemes.firstWhere((t) => t.id == themeId);
    } catch (e) {
      return null;
    }
  }

  // Set active theme
  Future<void> setActiveTheme(String themeId) async {
    await _prefs.setString(_activeThemeIdKey, themeId);
  }

  // Get active theme ID
  Future<String?> getActiveThemeId() async {
    return _prefs.getString(_activeThemeIdKey);
  }

  // Get active theme
  Future<CustomTheme?> getActiveTheme() async {
    final themeId = await getActiveThemeId();
    if (themeId == null) return null;
    return getThemeById(themeId);
  }

  // Clear active theme (revert to system default)
  Future<void> clearActiveTheme() async {
    await _prefs.remove(_activeThemeIdKey);
  }

  // Export theme to JSON string
  String exportTheme(CustomTheme theme) {
    return theme.toJsonString();
  }

  // Import theme from JSON string
  Future<CustomTheme?> importTheme(String jsonString) async {
    try {
      final theme = CustomTheme.fromJsonString(jsonString);
      
      // Generate new ID to avoid conflicts
      final newTheme = theme.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isBuiltIn: false,
        createdAt: DateTime.now(),
        modifiedAt: null,
      );
      
      await saveCustomTheme(newTheme);
      return newTheme;
    } catch (e) {
      return null;
    }
  }

  // Duplicate a theme
  Future<CustomTheme> duplicateTheme(CustomTheme theme, String newName) async {
    final newTheme = theme.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      isBuiltIn: false,
      createdAt: DateTime.now(),
      modifiedAt: null,
    );
    
    await saveCustomTheme(newTheme);
    return newTheme;
  }

  // Reset to default themes (removes all custom themes)
  Future<void> resetToDefaults() async {
    await _prefs.remove(_customThemesKey);
    await clearActiveTheme();
  }
}