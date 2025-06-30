import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/accessibility_settings.dart';
import '../providers/accessibility_provider.dart';

class AccessibilitySettingsDialog extends StatefulWidget {
  const AccessibilitySettingsDialog({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettingsDialog> createState() => _AccessibilitySettingsDialogState();
}

class _AccessibilitySettingsDialogState extends State<AccessibilitySettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibilityProvider, _) {
        final settings = accessibilityProvider.settings;
        
        return Dialog(
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 700),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Accessibility Settings'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      switch (value) {
                        case 'auto_configure':
                          await accessibilityProvider.autoConfigureFromSystem(context);
                          break;
                        case 'high_accessibility':
                          await accessibilityProvider.applyPreset(
                            AccessibilitySettings.highAccessibility,
                          );
                          break;
                        case 'visual_impairment':
                          await accessibilityProvider.applyPreset(
                            AccessibilitySettings.visualImpairment,
                          );
                          break;
                        case 'motor_impairment':
                          await accessibilityProvider.applyPreset(
                            AccessibilitySettings.motorImpairment,
                          );
                          break;
                        case 'reset':
                          await accessibilityProvider.resetToDefaults();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'auto_configure',
                        child: ListTile(
                          leading: Icon(Icons.auto_fix_high),
                          title: Text('Auto Configure'),
                          subtitle: Text('Based on system settings'),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'high_accessibility',
                        child: ListTile(
                          leading: Icon(Icons.accessibility_new),
                          title: Text('High Accessibility'),
                          subtitle: Text('Maximum accessibility features'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'visual_impairment',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('Visual Impairment'),
                          subtitle: Text('Optimized for visual needs'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'motor_impairment',
                        child: ListTile(
                          leading: Icon(Icons.touch_app),
                          title: Text('Motor Impairment'),
                          subtitle: Text('Larger touch targets'),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'reset',
                        child: ListTile(
                          leading: Icon(Icons.restore),
                          title: Text('Reset to Defaults'),
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
                      // Screen Reader Section
                      _buildSection(
                        'Screen Reader Support',
                        [
                          SwitchListTile(
                            title: const Text('Enable Screen Reader'),
                            subtitle: const Text('Optimize for screen reading software'),
                            value: settings.enableScreenReader,
                            onChanged: accessibilityProvider.setScreenReaderEnabled,
                          ),
                          SwitchListTile(
                            title: const Text('Voice Over Support'),
                            subtitle: const Text('Enhanced voice navigation'),
                            value: settings.enableVoiceOver,
                            onChanged: accessibilityProvider.setVoiceOverEnabled,
                          ),
                        ],
                      ),
                      
                      // Visual Section
                      _buildSection(
                        'Visual Accessibility',
                        [
                          SwitchListTile(
                            title: const Text('High Contrast Mode'),
                            subtitle: const Text('Increase color contrast for better visibility'),
                            value: settings.highContrastMode,
                            onChanged: accessibilityProvider.setHighContrastMode,
                          ),
                          SwitchListTile(
                            title: const Text('Large Text'),
                            subtitle: const Text('Use larger text sizes'),
                            value: settings.largeText,
                            onChanged: accessibilityProvider.setLargeText,
                          ),
                          SwitchListTile(
                            title: const Text('Bold Text'),
                            subtitle: const Text('Make text bold for better readability'),
                            value: settings.boldText,
                            onChanged: accessibilityProvider.setBoldText,
                          ),
                          ListTile(
                            title: const Text('Text Scale Factor'),
                            subtitle: Text('Current: ${(settings.textScaleFactor * 100).round()}%'),
                            trailing: SizedBox(
                              width: 150,
                              child: Slider(
                                value: settings.textScaleFactor,
                                min: 0.8,
                                max: 2.0,
                                divisions: 12,
                                label: '${(settings.textScaleFactor * 100).round()}%',
                                onChanged: accessibilityProvider.setTextScaleFactor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Motor/Touch Section
                      _buildSection(
                        'Motor & Touch',
                        [
                          ListTile(
                            title: const Text('Button Size'),
                            subtitle: Text('Current: ${settings.buttonSize.round()}px'),
                            trailing: SizedBox(
                              width: 150,
                              child: Slider(
                                value: settings.buttonSize,
                                min: 40.0,
                                max: 80.0,
                                divisions: 8,
                                label: '${settings.buttonSize.round()}px',
                                onChanged: accessibilityProvider.setButtonSize,
                              ),
                            ),
                          ),
                          SwitchListTile(
                            title: const Text('Show Focus Indicators'),
                            subtitle: const Text('Highlight focused elements'),
                            value: settings.showFocusIndicators,
                            onChanged: accessibilityProvider.setFocusIndicators,
                          ),
                          SwitchListTile(
                            title: const Text('Reduced Motion'),
                            subtitle: const Text('Minimize animations and transitions'),
                            value: settings.reducedMotion,
                            onChanged: accessibilityProvider.setReducedMotion,
                          ),
                        ],
                      ),
                      
                      // Feedback Section
                      _buildSection(
                        'Feedback',
                        [
                          SwitchListTile(
                            title: const Text('Haptic Feedback'),
                            subtitle: const Text('Vibration feedback for interactions'),
                            value: settings.hapticFeedback,
                            onChanged: accessibilityProvider.setHapticFeedback,
                          ),
                          SwitchListTile(
                            title: const Text('Sound Feedback'),
                            subtitle: const Text('Audio cues for interactions'),
                            value: settings.soundFeedback,
                            onChanged: accessibilityProvider.setSoundFeedback,
                          ),
                        ],
                      ),
                      
                      // Summary
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Features',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                accessibilityProvider.accessibilitySummary,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
}

// Quick accessibility toggle widget
class AccessibilityQuickToggle extends StatelessWidget {
  const AccessibilityQuickToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibilityProvider, _) {
        final hasFeatures = accessibilityProvider.settings.hasAnyFeatureEnabled;
        
        return IconButton(
          icon: Icon(
            hasFeatures ? Icons.accessibility : Icons.accessibility_new,
            color: hasFeatures ? Theme.of(context).colorScheme.primary : null,
          ),
          tooltip: 'Accessibility Settings',
          onPressed: () {
            accessibilityProvider.provideFeedback();
            showDialog(
              context: context,
              builder: (context) => const AccessibilitySettingsDialog(),
            );
          },
        );
      },
    );
  }
}

// Accessible button widget that respects accessibility settings
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;

  const AccessibleButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibilityProvider, _) {
        final buttonSize = accessibilityProvider.getEffectiveButtonSize(context);
        
        return Semantics(
          label: semanticLabel,
          button: true,
          child: Tooltip(
            message: tooltip ?? '',
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton(
                onPressed: onPressed == null ? null : () {
                  accessibilityProvider.provideFeedback();
                  onPressed!();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}