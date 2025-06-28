import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/markdown_viewer.dart';
import '../utils/constants.dart';
import '../models/app_settings.dart';
import 'home_screen.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentProvider>(
      builder: (context, documentProvider, _) {
        if (!documentProvider.hasDocument) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          });
          return const SizedBox.shrink();
        }

        final document = documentProvider.currentDocument!;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              document.fileName,
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              onPressed: () => _navigateHome(context),
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back to home',
            ),
            actions: [
              IconButton(
                onPressed: () => _showDocumentInfo(context, document),
                icon: const Icon(Icons.info_outline),
                tooltip: 'Document info',
              ),
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
          body: MarkdownViewer(
            markdownContent: document.content,
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(AppConstants.contentPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openNewFile(context),
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Open New File'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateHome(BuildContext context) {
    context.read<DocumentProvider>().clearDocument();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  void _openNewFile(BuildContext context) {
    context.read<DocumentProvider>().pickAndOpenFile();
  }

  void _showDocumentInfo(BuildContext context, document) {
    final documentProvider = context.read<DocumentProvider>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Document Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('File Name', document.fileName),
              const SizedBox(height: AppConstants.elementSpacing / 2),
              _buildInfoRow('File Size', documentProvider.formattedFileSize),
              const SizedBox(height: AppConstants.elementSpacing / 2),
              _buildInfoRow('Last Modified', documentProvider.formattedLastModified),
              const SizedBox(height: AppConstants.elementSpacing / 2),
              _buildInfoRow('Path', document.filePath),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
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