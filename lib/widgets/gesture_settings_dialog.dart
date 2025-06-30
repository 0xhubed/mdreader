import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/gesture_settings.dart';

class GestureSettingsDialog extends StatefulWidget {
  final GestureSettings initialSettings;
  final ValueChanged<GestureSettings> onSettingsChanged;

  const GestureSettingsDialog({
    Key? key,
    required this.initialSettings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<GestureSettingsDialog> createState() => _GestureSettingsDialogState();
}

class _GestureSettingsDialogState extends State<GestureSettingsDialog> {
  late GestureSettings _settings;
  bool _isRecordingShortcut = false;
  Set<LogicalKeyboardKey> _recordingKeys = {};

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Gesture & Keyboard Settings'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'reset_defaults':
                      setState(() {
                        _settings = GestureSettings.defaultSettings;
                      });
                      break;
                    case 'reading_focused':
                      setState(() {
                        _settings = GestureSettings.readingFocused;
                      });
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reset_defaults',
                    child: ListTile(
                      leading: Icon(Icons.restore),
                      title: Text('Reset to Defaults'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reading_focused',
                    child: ListTile(
                      leading: Icon(Icons.book),
                      title: Text('Reading Focused'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Settings
                  _buildSection(
                    'General Settings',
                    [
                      SwitchListTile(
                        title: const Text('Enable Gestures'),
                        subtitle: const Text('Touch gestures for navigation'),
                        value: _settings.enableGestures,
                        onChanged: (value) {
                          setState(() {
                            _settings = _settings.copyWith(enableGestures: value);
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Enable Keyboard Shortcuts'),
                        subtitle: const Text('Keyboard shortcuts for actions'),
                        value: _settings.enableKeyboardShortcuts,
                        onChanged: (value) {
                          setState(() {
                            _settings = _settings.copyWith(enableKeyboardShortcuts: value);
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Haptic Feedback'),
                        subtitle: const Text('Vibration feedback for gestures'),
                        value: _settings.hapticFeedbackOnGesture,
                        onChanged: (value) {
                          setState(() {
                            _settings = _settings.copyWith(hapticFeedbackOnGesture: value);
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('Gesture Sensitivity'),
                        subtitle: Text('Threshold: ${_settings.gestureThreshold.round()}px'),
                        trailing: SizedBox(
                          width: 150,
                          child: Slider(
                            value: _settings.gestureThreshold,
                            min: 20.0,
                            max: 100.0,
                            divisions: 8,
                            label: '${_settings.gestureThreshold.round()}px',
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(gestureThreshold: value);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Gesture Mappings
                  if (_settings.enableGestures) ...[
                    _buildSection(
                      'Gesture Mappings',
                      GestureType.values.map((gestureType) {
                        final currentAction = _settings.gestureMap[gestureType] ?? GestureAction.none;
                        
                        return ListTile(
                          title: Text(gestureType.displayName),
                          subtitle: Text(currentAction.displayName),
                          trailing: DropdownButton<GestureAction>(
                            value: currentAction,
                            onChanged: (action) {
                              if (action != null) {
                                setState(() {
                                  final newMap = Map<GestureType, GestureAction>.from(_settings.gestureMap);
                                  if (action == GestureAction.none) {
                                    newMap.remove(gestureType);
                                  } else {
                                    newMap[gestureType] = action;
                                  }
                                  _settings = _settings.copyWith(gestureMap: newMap);
                                });
                              }
                            },
                            items: GestureAction.values.map((action) {
                              return DropdownMenuItem(
                                value: action,
                                child: Text(action.displayName),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // Keyboard Shortcuts
                  if (_settings.enableKeyboardShortcuts) ...[
                    _buildSection(
                      'Keyboard Shortcuts',
                      [
                        ..._settings.keyboardShortcuts.map((shortcut) {
                          return ListTile(
                            title: Text(shortcut.displayString),
                            subtitle: Text(shortcut.action.displayName),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  final newShortcuts = List<KeyboardShortcut>.from(_settings.keyboardShortcuts);
                                  newShortcuts.remove(shortcut);
                                  _settings = _settings.copyWith(keyboardShortcuts: newShortcuts);
                                });
                              },
                            ),
                          );
                        }).toList(),
                        
                        ListTile(
                          title: const Text('Add New Shortcut'),
                          subtitle: _isRecordingShortcut 
                              ? Text('Press keys... ${_recordingKeys.map((k) => k.keyLabel).join(' + ')}')
                              : const Text('Tap to record new keyboard shortcut'),
                          leading: const Icon(Icons.add),
                          onTap: _startRecordingShortcut,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              widget.onSettingsChanged(_settings);
              Navigator.pop(context);
            },
            child: const Icon(Icons.check),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _startRecordingShortcut() {
    if (_isRecordingShortcut) return;
    
    setState(() {
      _isRecordingShortcut = true;
      _recordingKeys.clear();
    });
    
    // Show dialog for recording shortcut
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ShortcutRecordingDialog(
        onShortcutRecorded: (keys, action) {
          setState(() {
            _isRecordingShortcut = false;
            if (keys.isNotEmpty && action != GestureAction.none) {
              final newShortcut = KeyboardShortcut(
                keys: keys,
                action: action,
                description: action.displayName,
              );
              
              final newShortcuts = List<KeyboardShortcut>.from(_settings.keyboardShortcuts);
              newShortcuts.add(newShortcut);
              _settings = _settings.copyWith(keyboardShortcuts: newShortcuts);
            }
          });
        },
        onCancelled: () {
          setState(() {
            _isRecordingShortcut = false;
          });
        },
      ),
    );
  }
}

class _ShortcutRecordingDialog extends StatefulWidget {
  final Function(Set<LogicalKeyboardKey>, GestureAction) onShortcutRecorded;
  final VoidCallback onCancelled;

  const _ShortcutRecordingDialog({
    Key? key,
    required this.onShortcutRecorded,
    required this.onCancelled,
  }) : super(key: key);

  @override
  State<_ShortcutRecordingDialog> createState() => _ShortcutRecordingDialogState();
}

class _ShortcutRecordingDialogState extends State<_ShortcutRecordingDialog> {
  Set<LogicalKeyboardKey> _pressedKeys = {};
  GestureAction _selectedAction = GestureAction.none;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: AlertDialog(
        title: const Text('Record Keyboard Shortcut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Press the key combination you want to use:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _pressedKeys.isEmpty 
                    ? 'Press keys...' 
                    : _pressedKeys.map((k) => k.keyLabel).join(' + '),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<GestureAction>(
              value: _selectedAction,
              decoration: const InputDecoration(
                labelText: 'Action',
                border: OutlineInputBorder(),
              ),
              items: GestureAction.values
                  .where((action) => action != GestureAction.none)
                  .map((action) {
                return DropdownMenuItem(
                  value: action,
                  child: Text(action.displayName),
                );
              }).toList(),
              onChanged: (action) {
                setState(() {
                  _selectedAction = action ?? GestureAction.none;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancelled();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _pressedKeys.isNotEmpty && _selectedAction != GestureAction.none
                ? () {
                    Navigator.pop(context);
                    widget.onShortcutRecorded(_pressedKeys, _selectedAction);
                  }
                : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    setState(() {
      if (event is KeyDownEvent) {
        _pressedKeys.add(event.logicalKey);
      } else if (event is KeyUpEvent) {
        // Don't remove keys immediately on key up to allow multi-key combinations
      }
    });
  }
}