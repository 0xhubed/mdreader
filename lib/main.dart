import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/document_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/recent_files_provider.dart';
import 'providers/reading_position_provider.dart';
import 'screens/home_screen.dart';
import 'utils/theme_data.dart';
import 'utils/constants.dart';
import 'models/app_settings.dart' as models;

void main() {
  runApp(const MDReaderApp());
}

class MDReaderApp extends StatelessWidget {
  const MDReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RecentFilesProvider()),
        ChangeNotifierProvider(create: (_) => ReadingPositionProvider()),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Parallelize initialization for better performance
      await Future.wait([
        context.read<ThemeProvider>().initialize(),
        context.read<RecentFilesProvider>().loadRecentFiles(),
        context.read<ReadingPositionProvider>().loadBookmarks(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        if (themeProvider.isLoading) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Use custom theme if active, otherwise use default themes
        final customTheme = themeProvider.activeCustomTheme;
        final theme = customTheme != null
            ? customTheme.toThemeData()
            : AppThemes.lightTheme(themeProvider.fontSize);
        final darkTheme = customTheme != null && customTheme.isDark
            ? customTheme.toThemeData()
            : AppThemes.darkTheme(themeProvider.fontSize);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: customTheme != null 
              ? (customTheme.isDark ? ThemeMode.dark : ThemeMode.light)
              : _getMaterialThemeMode(themeProvider.themeMode),
          home: const HomeScreen(),
        );
      },
    );
  }

  ThemeMode _getMaterialThemeMode(models.AppThemeMode themeMode) {
    switch (themeMode) {
      case models.AppThemeMode.light:
        return ThemeMode.light;
      case models.AppThemeMode.dark:
        return ThemeMode.dark;
      case models.AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}