import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recent_files_provider.dart';
import '../models/recent_file.dart';
import '../utils/constants.dart';

class RecentFilesWidget extends StatelessWidget {
  final Function(String) onFileSelected;

  const RecentFilesWidget({
    super.key,
    required this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecentFilesProvider>(
      builder: (context, recentFilesProvider, child) {
        if (recentFilesProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!recentFilesProvider.hasRecentFiles) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, recentFilesProvider),
            const SizedBox(height: AppConstants.elementSpacing),
            Expanded(
              child: _buildRecentFilesList(context, recentFilesProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, RecentFilesProvider provider) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Files',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () => _showClearDialog(context, provider),
          child: const Text('Clear All'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.disabledColor,
          ),
          const SizedBox(height: AppConstants.elementSpacing),
          Text(
            'No Recent Files',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: AppConstants.elementSpacing / 2),
          Text(
            'Open a markdown file to see it here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFilesList(BuildContext context, RecentFilesProvider provider) {
    return ListView.builder(
      itemCount: provider.recentFiles.length,
      itemBuilder: (context, index) {
        final file = provider.recentFiles[index];
        return _buildRecentFileCard(context, file, provider);
      },
    );
  }

  Widget _buildRecentFileCard(BuildContext context, RecentFile file, RecentFilesProvider provider) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.elementSpacing),
      child: InkWell(
        onTap: () => onFileSelected(file.path),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.elementSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          file.preview,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.formatDate(file.lastAccessed),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: AppConstants.elementSpacing),
                            Icon(
                              Icons.storage,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.formatFileSize(file.size),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'remove') {
                        provider.removeRecentFile(file.path);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.remove_circle_outline),
                            SizedBox(width: 8),
                            Text('Remove from recent'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, RecentFilesProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Recent Files'),
          content: const Text('Are you sure you want to clear all recent files? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.clearRecentFiles();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}