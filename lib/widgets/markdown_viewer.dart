import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';

class MarkdownViewer extends StatelessWidget {
  final String markdownContent;
  final ScrollController? scrollController;

  const MarkdownViewer({
    super.key,
    required this.markdownContent,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Markdown(
          data: markdownContent,
          controller: scrollController,
          selectable: true,
          padding: const EdgeInsets.all(AppConstants.contentPadding),
          styleSheet: _buildMarkdownStyleSheet(context, themeProvider),
          imageDirectory: null,
          onTapLink: (text, href, title) {
            if (href != null) {
              _showLinkDialog(context, href);
            }
          },
        );
      },
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final fontSize = themeProvider.fontSize.value;
    final isDark = themeProvider.isDarkMode;

    final baseTextStyle = GoogleFonts.inter(
      fontSize: fontSize,
      height: AppConstants.lineHeight,
      color: theme.textTheme.bodyLarge?.color,
    );

    final codeTextStyle = GoogleFonts.jetBrainsMono(
      fontSize: fontSize * 0.9,
      color: theme.textTheme.bodyLarge?.color,
    );

    return MarkdownStyleSheet(
      h1: baseTextStyle.copyWith(
        fontSize: fontSize * AppConstants.headingScales['h1']!,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      h2: baseTextStyle.copyWith(
        fontSize: fontSize * AppConstants.headingScales['h2']!,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h3: baseTextStyle.copyWith(
        fontSize: fontSize * AppConstants.headingScales['h3']!,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h4: baseTextStyle.copyWith(
        fontSize: fontSize * AppConstants.headingScales['h4']!,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      h5: baseTextStyle.copyWith(
        fontSize: fontSize * AppConstants.headingScales['h5']!,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      h6: baseTextStyle.copyWith(
        fontSize: fontSize * AppConstants.headingScales['h6']!,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      p: baseTextStyle,
      strong: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
      em: baseTextStyle.copyWith(fontStyle: FontStyle.italic),
      code: codeTextStyle.copyWith(
        backgroundColor: isDark 
            ? AppColors.darkSurface.withOpacity(0.6)
            : AppColors.lightSurface,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurface.withOpacity(0.6)
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      codeblockPadding: const EdgeInsets.all(AppConstants.elementSpacing),
      blockquote: baseTextStyle.copyWith(
        color: theme.textTheme.bodySmall?.color,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: AppConstants.elementSpacing),
      listBullet: baseTextStyle.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      a: baseTextStyle.copyWith(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      h1Padding: const EdgeInsets.only(bottom: AppConstants.elementSpacing),
      h2Padding: const EdgeInsets.only(bottom: AppConstants.elementSpacing),
      h3Padding: const EdgeInsets.only(bottom: AppConstants.elementSpacing / 2),
      h4Padding: const EdgeInsets.only(bottom: AppConstants.elementSpacing / 2),
      h5Padding: const EdgeInsets.only(bottom: AppConstants.elementSpacing / 2),
      h6Padding: const EdgeInsets.only(bottom: AppConstants.elementSpacing / 2),
      pPadding: const EdgeInsets.only(bottom: AppConstants.elementSpacing),
    );
  }

  void _showLinkDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This link cannot be opened as the app is offline-only:'),
              const SizedBox(height: 8),
              SelectableText(
                url,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'monospace',
                ),
              ),
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
}