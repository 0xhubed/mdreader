import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/document_provider.dart';
import 'providers/theme_provider.dart';
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeProvider>().initialize();
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

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: AppThemes.lightTheme(themeProvider.fontSize),
          darkTheme: AppThemes.darkTheme(themeProvider.fontSize),
          themeMode: _getMaterialThemeMode(themeProvider.themeMode),
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