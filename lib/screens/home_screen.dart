import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/recent_files_provider.dart';
import '../utils/constants.dart';
import '../models/app_settings.dart';
import '../widgets/recent_files_widget.dart';
import '../widgets/theme_gallery.dart';
import 'reader_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
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

          return _buildHomeContent(context);
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.contentPadding),
      child: Column(
        children: [
          _buildOpenFileSection(context),
          const SizedBox(height: AppConstants.sectionSpacing),
          Expanded(
            child: Consumer<RecentFilesProvider>(
              builder: (context, recentFilesProvider, _) {
                if (recentFilesProvider.hasRecentFiles) {
                  return RecentFilesWidget(
                    onFileSelected: (filePath) => _openSpecificFile(context, filePath),
                  );
                } else {
                  return _buildEmptyRecentFiles(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenFileSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.contentPadding),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: AppConstants.elementSpacing),
            Text(
              AppStrings.noDocumentTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.elementSpacing / 2),
            Text(
              AppStrings.noDocumentSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.elementSpacing),
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
      ),
    );
  }

  Widget _buildEmptyRecentFiles(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: theme.disabledColor,
          ),
          const SizedBox(height: AppConstants.elementSpacing),
          Text(
            'No Recent Files',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: AppConstants.elementSpacing / 2),
          Text(
            'Files you open will appear here for quick access',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
            textAlign: TextAlign.center,
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

  void _openSpecificFile(BuildContext context, String filePath) {
    context.read<DocumentProvider>().openFile(filePath);
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
              // Custom theme selector
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: Text(themeProvider.activeCustomTheme?.name ?? 'Default'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ThemeGallery(),
                    ),
                  );
                },
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

}