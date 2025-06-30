class TocItem {
  final String title;
  final int level;
  final int lineNumber;
  final String id;
  final List<TocItem> children;

  TocItem({
    required this.title,
    required this.level,
    required this.lineNumber,
    required this.id,
    List<TocItem>? children,
  }) : children = children ?? [];

  TocItem copyWith({
    String? title,
    int? level,
    int? lineNumber,
    String? id,
    List<TocItem>? children,
  }) {
    return TocItem(
      title: title ?? this.title,
      level: level ?? this.level,
      lineNumber: lineNumber ?? this.lineNumber,
      id: id ?? this.id,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'level': level,
      'lineNumber': lineNumber,
      'id': id,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  factory TocItem.fromJson(Map<String, dynamic> json) {
    return TocItem(
      title: json['title'] ?? '',
      level: json['level'] ?? 1,
      lineNumber: json['lineNumber'] ?? 0,
      id: json['id'] ?? '',
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => TocItem.fromJson(child as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'TocItem(title: $title, level: $level, lineNumber: $lineNumber, id: $id, children: ${children.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TocItem &&
        other.title == title &&
        other.level == level &&
        other.lineNumber == lineNumber &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(title, level, lineNumber, id);

  /// Get all items in a flat list (including children)
  List<TocItem> get flattenedItems {
    final result = <TocItem>[this];
    for (final child in children) {
      result.addAll(child.flattenedItems);
    }
    return result;
  }

  /// Check if this item has any children
  bool get hasChildren => children.isNotEmpty;

  /// Get the indent level for display (0-based)
  int get indentLevel => level - 1;

  /// Get display prefix (for outline numbering if needed)
  String get prefix {
    switch (level) {
      case 1: return '• ';
      case 2: return '  ◦ ';
      case 3: return '    ▪ ';
      case 4: return '      - ';
      case 5: return '        · ';
      case 6: return '          ‣ ';
      default: return '            ';
    }
  }
}