import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(settingsJson);
        return AppSettings.fromJson(settingsMap);
      }
      
      return const AppSettings();
    } catch (e) {
      return const AppSettings();
    }
  }

  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings.toJson());
      return await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_settingsKey);
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateThemeMode(AppThemeMode themeMode) async {
    final currentSettings = await loadSettings();
    final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
    return await saveSettings(updatedSettings);
  }

  Future<bool> updateFontSize(FontSize fontSize) async {
    final currentSettings = await loadSettings();
    final updatedSettings = currentSettings.copyWith(fontSize: fontSize);
    return await saveSettings(updatedSettings);
  }
}