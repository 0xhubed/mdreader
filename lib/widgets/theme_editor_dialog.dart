import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../models/custom_theme.dart';
import '../models/app_settings.dart';
import '../providers/theme_provider.dart';

class ThemeEditorDialog extends StatefulWidget {
  final CustomTheme? theme;

  const ThemeEditorDialog({Key? key, this.theme}) : super(key: key);

  @override
  State<ThemeEditorDialog> createState() => _ThemeEditorDialogState();
}

class _ThemeEditorDialogState extends State<ThemeEditorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isDark;
  late Map<String, Color> _colors;
  late String _selectedFontFamily;
  late double _fontSize;
  late double _lineHeight;
  
  @override
  void initState() {
    super.initState();
    
    final theme = widget.theme;
    if (theme != null) {
      _nameController = TextEditingController(text: theme.name);
      _descriptionController = TextEditingController(text: theme.description);
      _isDark = theme.isDark;
      _colors = Map.from(theme.colors);
      _selectedFontFamily = theme.fontFamily;
      _fontSize = theme.fontSize;
      _lineHeight = theme.lineHeight;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _isDark = false;
      _colors = CustomTheme.defaultLightColors();
      _selectedFontFamily = 'Inter';
      _fontSize = 16.0;
      _lineHeight = 1.5;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.theme == null ? 'Create Theme' : 'Edit Theme'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: _saveTheme,
                child: const Text('Save'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Basic info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Theme Name',
                          hintText: 'Enter theme name',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter theme description',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Dark Theme'),
                        subtitle: const Text('Theme is optimized for dark mode'),
                        value: _isDark,
                        onChanged: (value) {
                          setState(() {
                            _isDark = value;
                            _colors = value
                                ? CustomTheme.defaultDarkColors()
                                : CustomTheme.defaultLightColors();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                
                // Typography settings
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Typography',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedFontFamily,
                        decoration: const InputDecoration(
                          labelText: 'Font Family',
                        ),
                        items: FontFamily.values
                            .map((font) => DropdownMenuItem(
                                  value: font.name,
                                  child: Text(font.displayName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedFontFamily = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Font Size: ${_fontSize.toStringAsFixed(0)}px'),
                                Slider(
                                  value: _fontSize,
                                  min: 12,
                                  max: 24,
                                  divisions: 12,
                                  label: '${_fontSize.toStringAsFixed(0)}px',
                                  onChanged: (value) {
                                    setState(() {
                                      _fontSize = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Line Height: ${_lineHeight.toStringAsFixed(1)}'),
                                Slider(
                                  value: _lineHeight,
                                  min: 1.0,
                                  max: 2.5,
                                  divisions: 15,
                                  label: _lineHeight.toStringAsFixed(1),
                                  onChanged: (value) {
                                    setState(() {
                                      _lineHeight = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                
                // Color settings
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Colors',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ..._buildColorPickers(),
                    ],
                  ),
                ),
                
                // Preview
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _colors[CustomTheme.backgroundColorKey],
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Heading 1',
                              style: TextStyle(
                                color: _colors[CustomTheme.textPrimaryColorKey],
                                fontSize: _fontSize * 2,
                                fontWeight: FontWeight.bold,
                                fontFamily: _selectedFontFamily,
                                height: _lineHeight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This is a paragraph of body text to preview how the theme looks. '
                              'It includes multiple lines to show line height settings.',
                              style: TextStyle(
                                color: _colors[CustomTheme.textPrimaryColorKey],
                                fontSize: _fontSize,
                                fontFamily: _selectedFontFamily,
                                height: _lineHeight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Secondary text color preview',
                              style: TextStyle(
                                color: _colors[CustomTheme.textSecondaryColorKey],
                                fontSize: _fontSize * 0.875,
                                fontFamily: _selectedFontFamily,
                                height: _lineHeight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _colors[CustomTheme.codeBackgroundColorKey],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'const example = "code preview";',
                                style: TextStyle(
                                  color: _colors[CustomTheme.codeTextColorKey],
                                  fontSize: _fontSize * 0.875,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This is a link',
                              style: TextStyle(
                                color: _colors[CustomTheme.linkColorKey],
                                fontSize: _fontSize,
                                fontFamily: _selectedFontFamily,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColorPickers() {
    final colorEntries = [
      ('Primary', CustomTheme.primaryColorKey),
      ('Secondary', CustomTheme.secondaryColorKey),
      ('Background', CustomTheme.backgroundColorKey),
      ('Surface', CustomTheme.surfaceColorKey),
      ('Text Primary', CustomTheme.textPrimaryColorKey),
      ('Text Secondary', CustomTheme.textSecondaryColorKey),
      ('Code Background', CustomTheme.codeBackgroundColorKey),
      ('Code Text', CustomTheme.codeTextColorKey),
      ('Link', CustomTheme.linkColorKey),
      ('Divider', CustomTheme.dividerColorKey),
    ];

    return colorEntries.map((entry) {
      final label = entry.$1;
      final key = entry.$2;
      final color = _colors[key]!;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(label),
            ),
            InkWell(
              onTap: () => _pickColor(key),
              child: Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }).toList();
  }

  void _pickColor(String colorKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _colors[colorKey]!,
            onColorChanged: (color) {
              setState(() {
                _colors[colorKey] = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _saveTheme() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a theme name'),
        ),
      );
      return;
    }

    final themeProvider = context.read<ThemeProvider>();
    
    final theme = CustomTheme(
      id: widget.theme?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: _descriptionController.text.trim(),
      isDark: _isDark,
      colors: _colors,
      textScales: CustomTheme.defaultTextScales(),
      fontFamily: _selectedFontFamily,
      fontSize: _fontSize,
      lineHeight: _lineHeight,
      createdAt: widget.theme?.createdAt ?? DateTime.now(),
      modifiedAt: widget.theme != null ? DateTime.now() : null,
      isBuiltIn: false,
    );

    await themeProvider.saveCustomTheme(theme);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.theme == null 
            ? 'Theme created successfully' 
            : 'Theme updated successfully'),
      ),
    );
  }
}