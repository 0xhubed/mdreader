import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/custom_theme.dart';
import '../models/reading_settings.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  late ThemeService _themeService;
  
  AppSettings _settings = const AppSettings();
  bool _isLoading = true;
  CustomTheme? _activeCustomTheme;
  List<CustomTheme> _availableThemes = [];
  ReadingSettings _readingSettings = const ReadingSettings();

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  AppThemeMode get themeMode => _settings.themeMode;
  FontSize get fontSize => _settings.fontSize;
  FontFamily get fontFamily => _settings.fontFamily;
  ReadingMode get readingMode => _settings.readingMode;
  LineSpacing get lineSpacing => _settings.lineSpacing;
  CustomTheme? get activeCustomTheme => _activeCustomTheme;
  List<CustomTheme> get availableThemes => _availableThemes;
  ReadingSettings get readingSettings => _readingSettings;
  DisplayMode get displayMode => _readingSettings.displayMode;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeService = ThemeService(prefs);
      
      _settings = await _settingsService.loadSettings();
      _availableThemes = await _themeService.getAllThemes();
      
      final activeThemeId = await _themeService.getActiveThemeId();
      if (activeThemeId != null) {
        _activeCustomTheme = await _themeService.getThemeById(activeThemeId);
      } else {
        // Set "Default Light" as the default theme on first run
        _activeCustomTheme = _availableThemes.firstWhere(
          (theme) => theme.id == 'default_light',
          orElse: () => ThemePresets.defaultLight,
        );
        // Save it as the active theme
        await _themeService.setActiveTheme(_activeCustomTheme!.id);
      }
      
      await _loadReadingSettings();
    } catch (e) {
      _settings = const AppSettings();
      _availableThemes = ThemePresets.all;
      // Set Default Light as fallback theme even on error
      _activeCustomTheme = ThemePresets.defaultLight;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    final newSettings = _settings.copyWith(themeMode: themeMode);
    await _updateSettings(newSettings);
  }

  Future<void> setFontSize(FontSize fontSize) async {
    final newSettings = _settings.copyWith(fontSize: fontSize);
    await _updateSettings(newSettings);
  }

  Future<void> setFontFamily(FontFamily fontFamily) async {
    final newSettings = _settings.copyWith(fontFamily: fontFamily);
    await _updateSettings(newSettings);
  }

  Future<void> setReadingMode(ReadingMode readingMode) async {
    final newSettings = _settings.copyWith(readingMode: readingMode);
    await _updateSettings(newSettings);
  }

  Future<void> setLineSpacing(LineSpacing lineSpacing) async {
    final newSettings = _settings.copyWith(lineSpacing: lineSpacing);
    await _updateSettings(newSettings);
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    
    try {
      await _settingsService.saveSettings(newSettings);
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  bool get isDarkMode {
    switch (_settings.themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  void toggleTheme() {
    final newThemeMode = _settings.themeMode == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    setThemeMode(newThemeMode);
  }

  // Custom theme methods
  Future<void> setActiveCustomTheme(CustomTheme? theme) async {
    _activeCustomTheme = theme;
    
    if (theme != null) {
      await _themeService.setActiveTheme(theme.id);
      
      // Batch related updates without intermediate notifications
      AppSettings newSettings = _settings;
      
      // Update font family if different
      if (theme.fontFamily != fontFamily.name) {
        final family = FontFamily.values.firstWhere(
          (f) => f.name == theme.fontFamily,
          orElse: () => FontFamily.inter,
        );
        newSettings = newSettings.copyWith(fontFamily: family);
      }
      
      // Update line spacing if different
      final currentLineHeight = lineSpacing.value;
      if ((theme.lineHeight - currentLineHeight).abs() > 0.01) {
        final spacing = LineSpacing.values.firstWhere(
          (s) => (s.value - theme.lineHeight).abs() < 0.01,
          orElse: () => LineSpacing.normal,
        );
        newSettings = newSettings.copyWith(lineSpacing: spacing);
      }
      
      // Apply all changes at once
      if (newSettings != _settings) {
        _settings = newSettings;
        await _settingsService.saveSettings(newSettings);
      }
    } else {
      await _themeService.clearActiveTheme();
    }
    
    // Single notification after all updates
    notifyListeners();
  }

  Future<void> saveCustomTheme(CustomTheme theme) async {
    await _themeService.saveCustomTheme(theme);
    _availableThemes = await _themeService.getAllThemes();
    notifyListeners();
  }

  Future<void> deleteCustomTheme(String themeId) async {
    await _themeService.deleteCustomTheme(themeId);
    _availableThemes = await _themeService.getAllThemes();
    
    if (_activeCustomTheme?.id == themeId) {
      _activeCustomTheme = null;
    }
    
    notifyListeners();
  }

  Future<CustomTheme?> importTheme(String jsonString) async {
    final theme = await _themeService.importTheme(jsonString);
    if (theme != null) {
      _availableThemes = await _themeService.getAllThemes();
      notifyListeners();
    }
    return theme;
  }

  String exportTheme(CustomTheme theme) {
    return _themeService.exportTheme(theme);
  }

  Future<CustomTheme> duplicateTheme(CustomTheme theme, String newName) async {
    final newTheme = await _themeService.duplicateTheme(theme, newName);
    _availableThemes = await _themeService.getAllThemes();
    notifyListeners();
    return newTheme;
  }

  ThemeData getEffectiveTheme(BuildContext context) {
    if (_activeCustomTheme != null) {
      return _activeCustomTheme!.toThemeData();
    }
    
    // Fall back to default theme behavior
    return isDarkMode 
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  }

  // Display mode methods
  Future<void> setDisplayMode(DisplayMode mode) async {
    _readingSettings = ReadingSettings.forDisplayMode(mode);
    notifyListeners();
    
    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('display_mode', mode.index);
    } catch (e) {
      debugPrint('Failed to save display mode: $e');
    }
  }

  Future<void> updateReadingSettings(ReadingSettings settings) async {
    _readingSettings = settings;
    notifyListeners();
    
    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reading_settings', settings.toJson().toString());
    } catch (e) {
      debugPrint('Failed to save reading settings: $e');
    }
  }

  Future<void> _loadReadingSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final displayModeIndex = prefs.getInt('display_mode');
      
      if (displayModeIndex != null && displayModeIndex < DisplayMode.values.length) {
        _readingSettings = ReadingSettings.forDisplayMode(DisplayMode.values[displayModeIndex]);
      }
    } catch (e) {
      debugPrint('Failed to load reading settings: $e');
    }
  }
}