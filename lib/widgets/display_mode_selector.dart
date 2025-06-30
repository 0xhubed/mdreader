import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/reading_settings.dart';

class DisplayModeSelector extends StatelessWidget {
  final bool showInDrawer;

  const DisplayModeSelector({
    Key? key,
    this.showInDrawer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final currentMode = themeProvider.displayMode;
        
        if (showInDrawer) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Display Mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...DisplayMode.values.map((mode) {
                return ListTile(
                  leading: Icon(mode.icon),
                  title: Text(mode.displayName),
                  subtitle: Text(mode.description),
                  trailing: currentMode == mode
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  selected: currentMode == mode,
                  onTap: () {
                    themeProvider.setDisplayMode(mode);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ],
          );
        }
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: DisplayMode.values.map((mode) {
              final isSelected = mode == currentMode;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  selected: isSelected,
                  onSelected: (_) => themeProvider.setDisplayMode(mode),
                  avatar: Icon(
                    mode.icon,
                    size: 18,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  label: Text(mode.displayName),
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class DisplayModeQuickToggle extends StatelessWidget {
  const DisplayModeQuickToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DisplayMode>(
      icon: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return Icon(themeProvider.displayMode.icon);
        },
      ),
      tooltip: 'Display Mode',
      onSelected: (mode) {
        context.read<ThemeProvider>().setDisplayMode(mode);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Display mode: ${mode.displayName}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      itemBuilder: (context) {
        final themeProvider = context.read<ThemeProvider>();
        final currentMode = themeProvider.displayMode;
        
        return DisplayMode.values.map((mode) {
          return PopupMenuItem<DisplayMode>(
            value: mode,
            child: Row(
              children: [
                Icon(
                  mode.icon,
                  color: mode == currentMode
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mode.displayName,
                        style: TextStyle(
                          color: mode == currentMode
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight: mode == currentMode
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      Text(
                        mode.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (mode == currentMode)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

class ReadingSettingsDialog extends StatefulWidget {
  const ReadingSettingsDialog({Key? key}) : super(key: key);

  @override
  State<ReadingSettingsDialog> createState() => _ReadingSettingsDialogState();
}

class _ReadingSettingsDialogState extends State<ReadingSettingsDialog> {
  late ReadingSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = context.read<ThemeProvider>().readingSettings;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reading Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Show Scrollbar'),
              subtitle: const Text('Display scrollbar indicator'),
              value: _settings.showScrollbar,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(showScrollbar: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Show Progress'),
              subtitle: const Text('Display reading progress indicator'),
              value: _settings.showProgress,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(showProgress: value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Auto-hide Controls'),
              subtitle: const Text('Hide UI elements after inactivity'),
              value: _settings.autoHideControls,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(autoHideControls: value);
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Text Scale',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _settings.textScaleFactor,
              min: 0.8,
              max: 2.0,
              divisions: 12,
              label: '${(_settings.textScaleFactor * 100).round()}%',
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(textScaleFactor: value);
                });
              },
            ),
            Text(
              'Text size: ${(_settings.textScaleFactor * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<ThemeProvider>().updateReadingSettings(_settings);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}