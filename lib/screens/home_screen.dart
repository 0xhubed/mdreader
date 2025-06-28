import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../models/app_settings.dart';
import 'reader_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: 'Toggle theme',
              );
            },
          ),
          IconButton(
            onPressed: () => _showSettingsDialog(context),
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, documentProvider, _) {
          if (documentProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (documentProvider.hasError) {
            return _buildErrorState(context, documentProvider);
          }

          if (documentProvider.hasDocument) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ReaderScreen(),
                ),
              );
            });
            return const SizedBox.shrink();
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.contentPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          Text(
            AppStrings.noDocumentTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.elementSpacing),
          Text(
            AppStrings.noDocumentSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.sectionSpacing * 2),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openFile(context),
              icon: const Icon(Icons.folder_open),
              label: const Text(AppStrings.openFileButtonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DocumentProvider documentProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.contentPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          Text(
            AppStrings.errorTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.elementSpacing),
          Text(
            documentProvider.errorMessage ?? AppStrings.genericErrorMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.sectionSpacing * 2),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                documentProvider.clearError();
                _openFile(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ),
          const SizedBox(height: AppConstants.elementSpacing),
          TextButton(
            onPressed: () => documentProvider.clearError(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _openFile(BuildContext context) {
    context.read<DocumentProvider>().pickAndOpenFile();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }
}

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.settingsTitle),
      content: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(AppStrings.themeLabel),
                trailing: DropdownButton<AppThemeMode>(
                  value: themeProvider.themeMode,
                  onChanged: (AppThemeMode? newValue) {
                    if (newValue != null) {
                      themeProvider.setThemeMode(newValue);
                    }
                  },
                  items: AppThemeMode.values.map((AppThemeMode mode) {
                    return DropdownMenuItem<AppThemeMode>(
                      value: mode,
                      child: Text(_getThemeModeDisplayName(mode)),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: const Text(AppStrings.fontSizeLabel),
                trailing: DropdownButton<FontSize>(
                  value: themeProvider.fontSize,
                  onChanged: (FontSize? newValue) {
                    if (newValue != null) {
                      themeProvider.setFontSize(newValue);
                    }
                  },
                  items: FontSize.values.map((FontSize size) {
                    return DropdownMenuItem<FontSize>(
                      value: size,
                      child: Text(size.displayName),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}