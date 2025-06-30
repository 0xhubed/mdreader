import '../models/table_of_contents.dart';

class TableOfContentsService {
  static List<TocItem> generateTOC(String markdownContent) {
    final lines = markdownContent.split('\n');
    final tocItems = <TocItem>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.startsWith('#')) {
        final heading = _parseHeading(line, i);
        if (heading != null) {
          tocItems.add(heading);
        }
      }
    }
    
    return _buildHierarchy(tocItems);
  }

  static TocItem? _parseHeading(String line, int lineNumber) {
    final match = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
    if (match == null) return null;
    
    final level = match.group(1)!.length;
    final title = match.group(2)!.trim();
    
    if (title.isEmpty) return null;
    
    return TocItem(
      title: title,
      level: level,
      lineNumber: lineNumber,
      id: _generateId(title),
    );
  }

  static String _generateId(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  static List<TocItem> _buildHierarchy(List<TocItem> flatItems) {
    if (flatItems.isEmpty) return [];
    
    final result = <TocItem>[];
    final stack = <TocItem>[];
    
    for (final item in flatItems) {
      // Remove items from stack that are at same or deeper level
      while (stack.isNotEmpty && stack.last.level >= item.level) {
        stack.removeLast();
      }
      
      if (stack.isEmpty) {
        // This is a root item
        result.add(item);
      } else {
        // This is a child of the last item in stack
        stack.last.children.add(item);
      }
      
      stack.add(item);
    }
    
    return result;
  }

  static int estimateScrollPosition(String content, int targetLineNumber) {
    final lines = content.split('\n');
    if (targetLineNumber >= lines.length) return content.length;
    
    int charCount = 0;
    for (int i = 0; i < targetLineNumber && i < lines.length; i++) {
      charCount += lines[i].length + 1; // +1 for newline
    }
    
    return charCount;
  }

  static double calculateScrollRatio(String content, int targetLineNumber) {
    final totalLines = content.split('\n').length;
    if (totalLines == 0) return 0.0;
    
    return (targetLineNumber / totalLines).clamp(0.0, 1.0);
  }
}