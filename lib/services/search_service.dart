import '../models/search_result.dart';

class SearchService {
  static List<SearchResult> searchInDocument(String content, String query) {
    if (query.isEmpty || content.isEmpty) return [];
    
    final results = <SearchResult>[];
    final lines = content.split('\n');
    final normalizedQuery = query.toLowerCase();
    
    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final normalizedLine = line.toLowerCase();
      
      int startIndex = 0;
      while (true) {
        final matchIndex = normalizedLine.indexOf(normalizedQuery, startIndex);
        if (matchIndex == -1) break;
        
        final result = SearchResult(
          lineNumber: lineIndex,
          lineText: line,
          matchStart: matchIndex,
          matchEnd: matchIndex + query.length,
          query: query,
        );
        
        results.add(result);
        startIndex = matchIndex + 1;
      }
    }
    
    return results;
  }

  static List<SearchResult> searchWithRegex(String content, String pattern, {bool caseSensitive = false}) {
    if (pattern.isEmpty || content.isEmpty) return [];
    
    final results = <SearchResult>[];
    final lines = content.split('\n');
    
    try {
      final regex = RegExp(pattern, caseSensitive: caseSensitive);
      
      for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        final line = lines[lineIndex];
        final matches = regex.allMatches(line);
        
        for (final match in matches) {
          final result = SearchResult(
            lineNumber: lineIndex,
            lineText: line,
            matchStart: match.start,
            matchEnd: match.end,
            query: pattern,
          );
          
          results.add(result);
        }
      }
    } catch (e) {
      // Invalid regex pattern
      return [];
    }
    
    return results;
  }

  static double calculateScrollPosition(String content, int targetLineNumber) {
    final lines = content.split('\n');
    if (targetLineNumber >= lines.length) return 1.0;
    
    return (targetLineNumber / lines.length).clamp(0.0, 1.0);
  }

  static String highlightMatches(String text, String query, {bool caseSensitive = false}) {
    if (query.isEmpty) return text;
    
    final pattern = RegExp.escape(query);
    final regex = RegExp(pattern, caseSensitive: caseSensitive);
    
    return text.replaceAllMapped(regex, (match) {
      return '<mark>${match.group(0)}</mark>';
    });
  }

  static String getContextAroundMatch(String lineText, int matchStart, int matchEnd, {int contextLength = 50}) {
    final start = (matchStart - contextLength).clamp(0, lineText.length);
    final end = (matchEnd + contextLength).clamp(0, lineText.length);
    
    String context = lineText.substring(start, end);
    
    // Add ellipsis if we're not at the beginning/end
    if (start > 0) context = '...$context';
    if (end < lineText.length) context = '$context...';
    
    return context;
  }

  static Map<String, dynamic> getSearchStatistics(List<SearchResult> results) {
    if (results.isEmpty) {
      return {
        'totalMatches': 0,
        'totalLines': 0,
        'averageMatchesPerLine': 0.0,
      };
    }
    
    final uniqueLines = results.map((r) => r.lineNumber).toSet();
    
    return {
      'totalMatches': results.length,
      'totalLines': uniqueLines.length,
      'averageMatchesPerLine': results.length / uniqueLines.length,
    };
  }
}