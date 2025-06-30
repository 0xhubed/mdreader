import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class ThemeProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  AppSettings _settings = const AppSettings();
  bool _isLoading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  AppThemeMode get themeMode => _settings.themeMode;
  FontSize get fontSize => _settings.fontSize;
  FontFamily get fontFamily => _settings.fontFamily;
  ReadingMode get readingMode => _settings.readingMode;
  LineSpacing get lineSpacing => _settings.lineSpacing;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _settings = await _settingsService.loadSettings();
    } catch (e) {
      _settings = const AppSettings();
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
}