import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/custom_theme.dart';
import '../providers/theme_provider.dart';
import 'theme_editor_dialog.dart';

class ThemeGallery extends StatelessWidget {
  const ThemeGallery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final themes = themeProvider.availableThemes;
        final activeTheme = themeProvider.activeCustomTheme;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Theme Gallery'),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_upload),
                onPressed: () => _importTheme(context),
                tooltip: 'Import Theme',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _createNewTheme(context),
                tooltip: 'Create Custom Theme',
              ),
            ],
          ),
          body: themes.isEmpty
              ? const Center(
                  child: Text('No themes available'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    childAspectRatio: 16 / 9,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: themes.length,
                  itemBuilder: (context, index) {
                    final theme = themes[index];
                    final isActive = activeTheme?.id == theme.id;
                    
                    return ThemeCard(
                      theme: theme,
                      isActive: isActive,
                      onTap: () => _applyTheme(context, theme),
                      onEdit: theme.isBuiltIn ? null : () => _editTheme(context, theme),
                      onDuplicate: () => _duplicateTheme(context, theme),
                      onExport: () => _exportTheme(context, theme),
                      onDelete: theme.isBuiltIn ? null : () => _deleteTheme(context, theme),
                    );
                  },
                ),
        );
      },
    );
  }

  void _applyTheme(BuildContext context, CustomTheme theme) {
    final themeProvider = context.read<ThemeProvider>();
    themeProvider.setActiveCustomTheme(theme);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied theme: ${theme.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _createNewTheme(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeEditorDialog(),
    );
  }

  void _editTheme(BuildContext context, CustomTheme theme) {
    showDialog(
      context: context,
      builder: (context) => ThemeEditorDialog(theme: theme),
    );
  }

  void _duplicateTheme(BuildContext context, CustomTheme theme) async {
    final controller = TextEditingController(text: '${theme.name} Copy');
    
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Theme'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Theme Name',
            hintText: 'Enter new theme name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
    
    if (name != null && name.isNotEmpty) {
      final themeProvider = context.read<ThemeProvider>();
      await themeProvider.duplicateTheme(theme, name);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme duplicated successfully'),
        ),
      );
    }
  }

  void _exportTheme(BuildContext context, CustomTheme theme) {
    final themeProvider = context.read<ThemeProvider>();
    final json = themeProvider.exportTheme(theme);
    
    // In a real app, you would save this to a file or share it
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export: ${theme.name}'),
        content: SingleChildScrollView(
          child: SelectableText(
            json,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteTheme(BuildContext context, CustomTheme theme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Theme'),
        content: Text('Are you sure you want to delete "${theme.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final themeProvider = context.read<ThemeProvider>();
      await themeProvider.deleteCustomTheme(theme.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme deleted'),
        ),
      );
    }
  }

  void _importTheme(BuildContext context) async {
    final controller = TextEditingController();
    
    final jsonString = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Theme'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Theme JSON',
            hintText: 'Paste theme JSON here',
          ),
          maxLines: 10,
          minLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    
    if (jsonString != null && jsonString.isNotEmpty) {
      final themeProvider = context.read<ThemeProvider>();
      final theme = await themeProvider.importTheme(jsonString);
      
      if (theme != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme imported successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to import theme. Invalid format.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ThemeCard extends StatelessWidget {
  final CustomTheme theme;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onExport;
  final VoidCallback? onDelete;

  const ThemeCard({
    Key? key,
    required this.theme,
    required this.isActive,
    required this.onTap,
    this.onEdit,
    required this.onDuplicate,
    required this.onExport,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    
    return Card(
      elevation: isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Theme preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors[CustomTheme.backgroundColorKey],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title preview
                      Text(
                        'Title Preview',
                        style: TextStyle(
                          color: colors[CustomTheme.textPrimaryColorKey],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: theme.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Body text preview
                      Text(
                        'This is how body text will look with this theme.',
                        style: TextStyle(
                          color: colors[CustomTheme.textSecondaryColorKey],
                          fontSize: 14,
                          fontFamily: theme.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Code preview
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors[CustomTheme.codeBackgroundColorKey],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'code { preview }',
                          style: TextStyle(
                            color: colors[CustomTheme.codeTextColorKey],
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Theme info and actions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              theme.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (theme.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                theme.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (theme.isBuiltIn)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Built-in',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'duplicate':
                              onDuplicate();
                              break;
                            case 'export':
                              onExport();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Text('Duplicate'),
                          ),
                          const PopupMenuItem(
                            value: 'export',
                            child: Text('Export'),
                          ),
                          if (onDelete != null) ...[
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}