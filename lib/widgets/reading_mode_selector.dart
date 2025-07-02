import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_settings.dart';

class ReadingModeSelector extends StatelessWidget {
  final bool showLabels;
  final bool isHorizontal;

  const ReadingModeSelector({
    Key? key,
    this.showLabels = true,
    this.isHorizontal = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final currentMode = themeProvider.readingMode;
        
        if (isHorizontal) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ReadingMode.values.map((mode) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildModeChip(context, mode, currentMode, themeProvider),
                );
              }).toList(),
            ),
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: ReadingMode.values.map((mode) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildModeTile(context, mode, currentMode, themeProvider),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildModeChip(
    BuildContext context,
    ReadingMode mode,
    ReadingMode currentMode,
    ThemeProvider themeProvider,
  ) {
    final isSelected = mode == currentMode;
    final colors = _getModePreviewColors(mode, themeProvider.isDarkMode);
    
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => themeProvider.setReadingMode(mode),
      avatar: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          border: Border.all(
            color: colors.textColor.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(
              color: colors.textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      label: showLabels ? Text(mode.displayName) : const SizedBox.shrink(),
      backgroundColor: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildModeTile(
    BuildContext context,
    ReadingMode mode,
    ReadingMode currentMode,
    ThemeProvider themeProvider,
  ) {
    final isSelected = mode == currentMode;
    final colors = _getModePreviewColors(mode, themeProvider.isDarkMode);
    
    return ListTile(
      selected: isSelected,
      onTap: () => themeProvider.setReadingMode(mode),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : colors.textColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(
              color: colors.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(mode.displayName),
      subtitle: Text(_getModeDescription(mode)),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }

  String _getModeDescription(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.normal:
        return 'Default theme colors';
      case ReadingMode.highContrast:
        return 'Maximum readability';
    }
  }

  ReadingModeColors _getModePreviewColors(ReadingMode mode, bool isDarkMode) {
    switch (mode) {
      case ReadingMode.normal:
        return ReadingModeColors(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          textColor: isDarkMode ? Colors.white : Colors.black87,
        );
      case ReadingMode.highContrast:
        return ReadingModeColors(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          textColor: isDarkMode ? Colors.white : Colors.black,
        );
    }
  }
}

class ReadingModeColors {
  final Color backgroundColor;
  final Color textColor;

  const ReadingModeColors({
    required this.backgroundColor,
    required this.textColor,
  });
}

class ReadingModeQuickToggle extends StatelessWidget {
  const ReadingModeQuickToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final currentMode = themeProvider.readingMode;
        final nextMode = _getNextMode(currentMode);
        
        return IconButton(
          icon: _getModeIcon(currentMode),
          tooltip: 'Switch to ${nextMode.displayName}',
          onPressed: () {
            themeProvider.setReadingMode(nextMode);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reading mode: ${nextMode.displayName}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  ReadingMode _getNextMode(ReadingMode current) {
    final modes = ReadingMode.values;
    final currentIndex = modes.indexOf(current);
    final nextIndex = (currentIndex + 1) % modes.length;
    return modes[nextIndex];
  }

  Widget _getModeIcon(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.normal:
        return const Icon(Icons.auto_awesome);
      case ReadingMode.highContrast:
        return const Icon(Icons.contrast);
    }
  }
}