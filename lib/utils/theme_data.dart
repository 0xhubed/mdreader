import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import '../models/app_settings.dart';

class AppThemes {
  static ThemeData lightTheme(FontSize fontSize) {
    final baseTextStyle = GoogleFonts.inter(
      fontSize: fontSize.value,
      height: AppConstants.lineHeight,
      color: AppColors.lightText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        onPrimary: Colors.white,
        onSurface: AppColors.lightText,
        onBackground: AppColors.lightText,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _buildTextTheme(baseTextStyle, false),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      dividerColor: AppColors.lightTextSecondary.withOpacity(0.2),
    );
  }

  static ThemeData darkTheme(FontSize fontSize) {
    final baseTextStyle = GoogleFonts.inter(
      fontSize: fontSize.value,
      height: AppConstants.lineHeight,
      color: AppColors.darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        onPrimary: AppColors.darkBackground,
        onSurface: AppColors.darkText,
        onBackground: AppColors.darkText,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _buildTextTheme(baseTextStyle, true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBackground,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      dividerColor: AppColors.darkTextSecondary.withOpacity(0.2),
    );
  }

  static TextTheme _buildTextTheme(TextStyle baseStyle, bool isDark) {
    final primaryColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return TextTheme(
      displayLarge: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * AppConstants.headingScales['h1']!,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      displayMedium: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * AppConstants.headingScales['h2']!,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      displaySmall: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * AppConstants.headingScales['h3']!,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineLarge: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * AppConstants.headingScales['h4']!,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineMedium: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * AppConstants.headingScales['h5']!,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      headlineSmall: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * AppConstants.headingScales['h6']!,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      bodyLarge: baseStyle.copyWith(color: primaryColor),
      bodyMedium: baseStyle.copyWith(color: primaryColor),
      bodySmall: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * 0.875,
        color: secondaryColor,
      ),
      labelLarge: baseStyle.copyWith(
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      labelMedium: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * 0.875,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: baseStyle.copyWith(
        fontSize: baseStyle.fontSize! * 0.75,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
    );
  }
}