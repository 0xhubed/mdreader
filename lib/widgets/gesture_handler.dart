import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/gesture_settings.dart';
import '../models/app_settings.dart';
import '../models/reading_settings.dart';
import '../providers/theme_provider.dart';
import '../providers/accessibility_provider.dart';

typedef GestureActionCallback = void Function(GestureAction action);

class GestureHandler extends StatefulWidget {
  final Widget child;
  final GestureActionCallback onGestureAction;
  final GestureSettings? gestureSettings;
  final ScrollController? scrollController;

  const GestureHandler({
    Key? key,
    required this.child,
    required this.onGestureAction,
    this.gestureSettings,
    this.scrollController,
  }) : super(key: key);

  @override
  State<GestureHandler> createState() => _GestureHandlerState();
}

class _GestureHandlerState extends State<GestureHandler> {
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  late GestureSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.gestureSettings ?? GestureSettings.defaultSettings;
  }

  @override
  void didUpdateWidget(GestureHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gestureSettings != oldWidget.gestureSettings) {
      _settings = widget.gestureSettings ?? GestureSettings.defaultSettings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AccessibilityProvider>(
      builder: (context, themeProvider, accessibilityProvider, _) {
        return KeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKeyEvent: _settings.enableKeyboardShortcuts ? _handleKeyEvent : null,
          child: GestureDetector(
            // Single tap
            onTap: _settings.enableGestures
                ? () => _handleGesture(GestureType.tap, accessibilityProvider)
                : null,
            
            // Double tap
            onDoubleTap: _settings.enableGestures
                ? () => _handleGesture(GestureType.doubleTap, accessibilityProvider)
                : null,
            
            // Long press
            onLongPress: _settings.enableGestures
                ? () => _handleGesture(GestureType.longPress, accessibilityProvider)
                : null,
            
            // Pan gestures for swipes
            onPanEnd: _settings.enableGestures
                ? (details) => _handlePanEnd(details, accessibilityProvider)
                : null,
            
            child: InteractiveViewer(
              onInteractionStart: _settings.enableGestures ? _handleInteractionStart : null,
              onInteractionUpdate: _settings.enableGestures ? _handleInteractionUpdate : null,
              onInteractionEnd: _settings.enableGestures ? _handleInteractionEnd : null,
              minScale: 0.5,
              maxScale: 3.0,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
      
      // Check for keyboard shortcuts
      for (final shortcut in _settings.keyboardShortcuts) {
        if (shortcut.matches(_pressedKeys)) {
          _executeAction(shortcut.action);
          break;
        }
      }
    }
  }

  void _handleGesture(GestureType gestureType, AccessibilityProvider accessibilityProvider) {
    final action = _settings.gestureMap[gestureType];
    if (action != null && action != GestureAction.none) {
      if (_settings.hapticFeedbackOnGesture) {
        accessibilityProvider.provideFeedback(HapticFeedback.lightImpact);
      }
      _executeAction(action);
    }
  }

  void _handlePanEnd(DragEndDetails details, AccessibilityProvider accessibilityProvider) {
    final velocity = details.velocity.pixelsPerSecond;
    final threshold = _settings.gestureThreshold;
    
    GestureType? gestureType;
    
    if (velocity.dx.abs() > velocity.dy.abs()) {
      // Horizontal swipe
      if (velocity.dx > threshold) {
        gestureType = GestureType.swipeRight;
      } else if (velocity.dx < -threshold) {
        gestureType = GestureType.swipeLeft;
      }
    } else {
      // Vertical swipe
      if (velocity.dy > threshold) {
        gestureType = GestureType.swipeDown;
      } else if (velocity.dy < -threshold) {
        gestureType = GestureType.swipeUp;
      }
    }
    
    if (gestureType != null) {
      _handleGesture(gestureType, accessibilityProvider);
    }
  }

  double _previousScale = 1.0;
  int _pointerCount = 0;

  void _handleInteractionStart(ScaleStartDetails details) {
    _previousScale = 1.0;
    _pointerCount = details.pointerCount;
  }

  void _handleInteractionUpdate(ScaleUpdateDetails details) {
    if (_pointerCount == 2) {
      final currentScale = details.scale;
      final scaleDelta = currentScale - _previousScale;
      
      if (scaleDelta > 0.1) {
        // Pinch out (zoom in)
        _handleGesture(GestureType.pinchOut, context.read<AccessibilityProvider>());
        _previousScale = currentScale;
      } else if (scaleDelta < -0.1) {
        // Pinch in (zoom out)
        _handleGesture(GestureType.pinchIn, context.read<AccessibilityProvider>());
        _previousScale = currentScale;
      }
    }
  }

  void _handleInteractionEnd(ScaleEndDetails details) {
    // Handle multi-finger taps based on pointer count
    if (_pointerCount == 2) {
      _handleGesture(GestureType.twoFingerTap, context.read<AccessibilityProvider>());
    } else if (_pointerCount == 3) {
      _handleGesture(GestureType.threeFingerTap, context.read<AccessibilityProvider>());
    }
  }

  void _executeAction(GestureAction action) {
    widget.onGestureAction(action);
  }
}

// Helper class for implementing gesture actions in screens
class GestureActionHandler {
  final BuildContext context;
  final ScrollController? scrollController;

  GestureActionHandler(this.context, {this.scrollController});

  void handleAction(GestureAction action) {
    switch (action) {
      case GestureAction.none:
        break;
        
      case GestureAction.scrollUp:
        _scrollUp();
        break;
        
      case GestureAction.scrollDown:
        _scrollDown();
        break;
        
      case GestureAction.goToTop:
        _goToTop();
        break;
        
      case GestureAction.goToBottom:
        _goToBottom();
        break;
        
      case GestureAction.toggleTheme:
        context.read<ThemeProvider>().toggleTheme();
        break;
        
      case GestureAction.toggleReadingMode:
        _toggleReadingMode();
        break;
        
      case GestureAction.toggleDisplayMode:
        _toggleDisplayMode();
        break;
        
      case GestureAction.zoomIn:
        _adjustTextScale(0.1);
        break;
        
      case GestureAction.zoomOut:
        _adjustTextScale(-0.1);
        break;
        
      case GestureAction.resetZoom:
        _resetTextScale();
        break;
        
      case GestureAction.goBack:
        Navigator.of(context).maybePop();
        break;
        
      default:
        // Other actions need to be handled by the implementing screen
        break;
    }
  }

  void _scrollUp() {
    if (scrollController?.hasClients == true) {
      final currentOffset = scrollController!.offset;
      final targetOffset = (currentOffset - 300).clamp(0.0, scrollController!.position.maxScrollExtent);
      
      scrollController!.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollDown() {
    if (scrollController?.hasClients == true) {
      final currentOffset = scrollController!.offset;
      final targetOffset = (currentOffset + 300).clamp(0.0, scrollController!.position.maxScrollExtent);
      
      scrollController!.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToTop() {
    if (scrollController?.hasClients == true) {
      scrollController!.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToBottom() {
    if (scrollController?.hasClients == true) {
      scrollController!.animateTo(
        scrollController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleReadingMode() {
    final themeProvider = context.read<ThemeProvider>();
    final currentMode = themeProvider.readingMode;
    final modes = ReadingMode.values;
    final currentIndex = modes.indexOf(currentMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    
    themeProvider.setReadingMode(modes[nextIndex]);
  }

  void _toggleDisplayMode() {
    final themeProvider = context.read<ThemeProvider>();
    final currentMode = themeProvider.displayMode;
    final modes = DisplayMode.values;
    final currentIndex = modes.indexOf(currentMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    
    themeProvider.setDisplayMode(modes[nextIndex]);
  }

  void _adjustTextScale(double delta) {
    final accessibilityProvider = context.read<AccessibilityProvider>();
    final currentScale = accessibilityProvider.textScaleFactor;
    final newScale = (currentScale + delta).clamp(0.5, 3.0);
    
    accessibilityProvider.setTextScaleFactor(newScale);
  }

  void _resetTextScale() {
    final accessibilityProvider = context.read<AccessibilityProvider>();
    accessibilityProvider.setTextScaleFactor(1.0);
  }
}