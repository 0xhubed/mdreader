import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mdreader/main.dart';
import 'package:mdreader/providers/document_provider.dart';
import 'package:mdreader/providers/theme_provider.dart';
import 'package:mdreader/screens/home_screen.dart';
import 'package:mdreader/models/app_settings.dart';
import 'package:mdreader/utils/constants.dart';

void main() {
  group('MDReader App Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const MDReaderApp());
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Home screen shows welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DocumentProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
          ),
        ),
      );
      
      await tester.pump();
      
      expect(find.text(AppStrings.noDocumentTitle), findsOneWidget);
      expect(find.text(AppStrings.noDocumentSubtitle), findsOneWidget);
      expect(find.text(AppStrings.openFileButtonText), findsOneWidget);
    });

    testWidgets('Theme toggle button is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DocumentProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
          ),
        ),
      );
      
      await tester.pump();
      
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('Settings button opens settings dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => DocumentProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
          ),
        ),
      );
      
      await tester.pump();
      
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);
      
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();
      
      expect(find.text(AppStrings.settingsTitle), findsOneWidget);
      expect(find.text(AppStrings.themeLabel), findsOneWidget);
      expect(find.text(AppStrings.fontSizeLabel), findsOneWidget);
    });
  });

  group('DocumentProvider Tests', () {
    test('Initial state is correct', () {
      final provider = DocumentProvider();
      
      expect(provider.state, DocumentState.initial);
      expect(provider.currentDocument, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.hasDocument, isFalse);
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
    });

    test('Clear document resets state', () {
      final provider = DocumentProvider();
      provider.clearDocument();
      
      expect(provider.state, DocumentState.initial);
      expect(provider.currentDocument, isNull);
      expect(provider.errorMessage, isNull);
    });
  });

  group('ThemeProvider Tests', () {
    test('Initial settings are correct', () {
      final provider = ThemeProvider();
      
      expect(provider.settings.themeMode, AppThemeMode.system);
      expect(provider.settings.fontSize, FontSize.medium);
    });
  });
}