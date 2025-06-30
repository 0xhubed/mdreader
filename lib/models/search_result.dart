class SearchResult {
  final int lineNumber;
  final String lineText;
  final int matchStart;
  final int matchEnd;
  final String query;

  const SearchResult({
    required this.lineNumber,
    required this.lineText,
    required this.matchStart,
    required this.matchEnd,
    required this.query,
  });

  String get matchedText => lineText.substring(matchStart, matchEnd);

  String get beforeMatch => lineText.substring(0, matchStart);

  String get afterMatch => lineText.substring(matchEnd);

  Map<String, dynamic> toJson() {
    return {
      'lineNumber': lineNumber,
      'lineText': lineText,
      'matchStart': matchStart,
      'matchEnd': matchEnd,
      'query': query,
    };
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      lineNumber: json['lineNumber'] ?? 0,
      lineText: json['lineText'] ?? '',
      matchStart: json['matchStart'] ?? 0,
      matchEnd: json['matchEnd'] ?? 0,
      query: json['query'] ?? '',
    );
  }

  SearchResult copyWith({
    int? lineNumber,
    String? lineText,
    int? matchStart,
    int? matchEnd,
    String? query,
  }) {
    return SearchResult(
      lineNumber: lineNumber ?? this.lineNumber,
      lineText: lineText ?? this.lineText,
      matchStart: matchStart ?? this.matchStart,
      matchEnd: matchEnd ?? this.matchEnd,
      query: query ?? this.query,
    );
  }

  @override
  String toString() {
    return 'SearchResult(lineNumber: $lineNumber, matchStart: $matchStart, matchEnd: $matchEnd, query: $query)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResult &&
        other.lineNumber == lineNumber &&
        other.lineText == lineText &&
        other.matchStart == matchStart &&
        other.matchEnd == matchEnd &&
        other.query == query;
  }

  @override
  int get hashCode => Object.hash(lineNumber, lineText, matchStart, matchEnd, query);

  /// Get a preview of the match with context
  String getPreview({int contextLength = 30}) {
    final start = (matchStart - contextLength).clamp(0, lineText.length);
    final end = (matchEnd + contextLength).clamp(0, lineText.length);
    
    String preview = lineText.substring(start, end);
    
    if (start > 0) preview = '...$preview';
    if (end < lineText.length) preview = '$preview...';
    
    return preview;
  }

  /// Check if this result is on the same line as another result
  bool isSameLineAs(SearchResult other) {
    return lineNumber == other.lineNumber;
  }

  /// Get the character position in the entire document
  int getDocumentPosition(String documentContent) {
    final lines = documentContent.split('\n');
    int position = 0;
    
    for (int i = 0; i < lineNumber && i < lines.length; i++) {
      position += lines[i].length + 1; // +1 for newline
    }
    
    return position + matchStart;
  }
}