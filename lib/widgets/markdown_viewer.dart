import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';
import 'package:markdown/markdown.dart' as md;
import 'syntax_highlighter.dart' as custom;

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
        final readingSettings = themeProvider.readingSettings;
        
        return Markdown(
          data: markdownContent,
          controller: scrollController,
          selectable: true,
          padding: const EdgeInsets.all(AppConstants.contentPadding),
          styleSheet: _buildMarkdownStyleSheet(context, themeProvider),
          imageDirectory: null,
          extensionSet: md.ExtensionSet(
            md.ExtensionSet.gitHubFlavored.blockSyntaxes,
            [
              md.EmojiSyntax(),
              ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
            ],
          ),
          builders: {
            'table': CustomTableBuilder(),
            'th': CustomTableCellBuilder(),
            'td': CustomTableCellBuilder(),
            'input': TaskListBuilder(),
            'code': CodeBlockBuilder(themeProvider),
          },
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
    final fontFamily = themeProvider.fontFamily;
    final lineSpacing = themeProvider.lineSpacing.value;
    final readingMode = themeProvider.readingMode;

    // Get the appropriate font family
    final fontFamilyFunction = _getFontFamily(fontFamily);
    
    // Get reading mode colors
    final colors = _getReadingModeColors(readingMode, isDark, theme);

    final baseTextStyle = fontFamilyFunction(
      fontSize: fontSize,
      height: lineSpacing,
      color: colors.textColor,
    );

    final codeTextStyle = GoogleFonts.jetBrainsMono(
      fontSize: fontSize * 0.9,
      color: colors.textColor,
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

  Function _getFontFamily(FontFamily fontFamily) {
    switch (fontFamily) {
      case FontFamily.inter:
        return GoogleFonts.inter;
      case FontFamily.openSans:
        return GoogleFonts.openSans;
      case FontFamily.roboto:
        return GoogleFonts.roboto;
      case FontFamily.sourceSerif:
        return GoogleFonts.sourceSerif4;
      case FontFamily.playfair:
        return GoogleFonts.playfairDisplay;
      case FontFamily.lora:
        return GoogleFonts.lora;
      case FontFamily.merriweather:
        return GoogleFonts.merriweather;
    }
  }

  ReadingModeColors _getReadingModeColors(ReadingMode readingMode, bool isDark, ThemeData theme) {
    switch (readingMode) {
      case ReadingMode.normal:
        return ReadingModeColors(
          backgroundColor: theme.scaffoldBackgroundColor,
          textColor: theme.textTheme.bodyLarge?.color ?? Colors.black,
          surfaceColor: theme.cardColor,
        );
      case ReadingMode.highContrast:
        return ReadingModeColors(
          backgroundColor: isDark ? Colors.black : Colors.white,
          textColor: isDark ? Colors.white : Colors.black,
          surfaceColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
        );
    }
  }
}

class ReadingModeColors {
  final Color backgroundColor;
  final Color textColor;
  final Color surfaceColor;

  ReadingModeColors({
    required this.backgroundColor,
    required this.textColor,
    required this.surfaceColor,
  });
}

class CustomTableBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final List<Widget> rows = <Widget>[];
    
    for (final child in element.children!) {
      if (child is md.Element) {
        if (child.tag == 'thead' || child.tag == 'tbody') {
          for (final row in child.children!) {
            if (row is md.Element) {
              rows.add(_buildTableRow(row, child.tag == 'thead'));
            }
          }
        } else if (child.tag == 'tr') {
          rows.add(_buildTableRow(child, false));
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.elementSpacing),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 56,
          dataRowHeight: 48,
          columns: _buildColumns(element),
          rows: _buildDataRows(element),
          border: TableBorder.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(md.Element row, bool isHeader) {
    final List<Widget> cells = <Widget>[];
    
    for (final cell in row.children!) {
      if (cell is md.Element) {
        cells.add(
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              cell.textContent,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }
    }

    return Row(children: cells);
  }

  List<DataColumn> _buildColumns(md.Element table) {
    final List<DataColumn> columns = <DataColumn>[];
    
    for (final child in table.children!) {
      if (child is md.Element && child.tag == 'thead') {
        for (final row in child.children!) {
          if (row is md.Element) {
            for (final cell in row.children!) {
              if (cell is md.Element) {
                columns.add(DataColumn(
                  label: Text(
                    cell.textContent,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ));
              }
            }
            break;
          }
        }
        break;
      }
    }
    
    return columns;
  }

  List<DataRow> _buildDataRows(md.Element table) {
    final List<DataRow> rows = <DataRow>[];
    
    for (final child in table.children!) {
      if (child is md.Element && child.tag == 'tbody') {
        for (final row in child.children!) {
          if (row is md.Element) {
            final List<DataCell> cells = <DataCell>[];
            for (final cell in row.children!) {
              if (cell is md.Element) {
                cells.add(DataCell(Text(cell.textContent)));
              }
            }
            rows.add(DataRow(cells: cells));
          }
        }
      }
    }
    
    return rows;
  }
}

class CustomTableCellBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        element.textContent,
        style: preferredStyle,
      ),
    );
  }
}

class TaskListBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final bool isChecked = element.attributes['checked'] != null;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Icon(
        isChecked ? Icons.check_box : Icons.check_box_outline_blank,
        size: 20,
        color: isChecked ? Colors.green : Colors.grey,
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final ThemeProvider themeProvider;

  CodeBlockBuilder(this.themeProvider);

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String code = element.textContent;
    String? language = element.attributes['class']?.replaceFirst('language-', '');
    
    if (language == null && element.children != null && element.children!.isNotEmpty) {
      // Try to get language from code element
      final codeElement = element.children!.first;
      if (codeElement is md.Element) {
        language = codeElement.attributes['class']?.replaceFirst('language-', '');
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.elementSpacing),
      child: custom.SyntaxHighlighter(
        code: code,
        language: custom.SupportedLanguages.normalizeLanguage(language),
        isDarkMode: themeProvider.isDarkMode,
        fontSize: themeProvider.fontSize.value,
      ),
    );
  }
}