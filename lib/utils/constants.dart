import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'MDReader';
  static const String appVersion = '1.0.0';
  
  static const double contentPadding = 16.0;
  static const double elementSpacing = 16.0;
  static const double sectionSpacing = 24.0;
  
  static const double borderRadius = 8.0;
  static const double buttonHeight = 48.0;
  
  static const List<String> supportedExtensions = ['md', 'markdown', 'txt'];
  
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  
  static const double lineHeight = 1.6;
  
  static const Map<String, double> headingScales = {
    'h1': 2.0,
    'h2': 1.5,
    'h3': 1.25,
    'h4': 1.125,
    'h5': 1.0,
    'h6': 0.875,
  };
}

class AppColors {
  static const Color lightPrimary = Color(0xFF2563EB);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightText = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  
  static const Color darkPrimary = Color(0xFF60A5FA);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
}

class AppTextStyles {
  static const String fontFamily = 'System';
  
  static const double smallFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 18.0;
}

class AppStrings {
  static const String appName = 'MDReader';
  static const String noDocumentTitle = 'Welcome to MDReader';
  static const String noDocumentSubtitle = 'Select a Markdown file to get started';
  static const String openFileButtonText = 'Open File';
  static const String settingsTitle = 'Settings';
  static const String themeLabel = 'Theme';
  static const String fontSizeLabel = 'Font Size';
  static const String errorTitle = 'Error';
  static const String fileErrorMessage = 'Unable to open file. Please try another file.';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
}

class AppDurations {
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}