import 'package:uuid/uuid.dart';

class ReadingPosition {
  final String filePath;
  final double scrollPosition; // 0.0 to 1.0
  final DateTime lastAccessed;
  final String? currentSection; // Current heading/section
  final int? currentLine;

  const ReadingPosition({
    required this.filePath,
    required this.scrollPosition,
    required this.lastAccessed,
    this.currentSection,
    this.currentLine,
  });

  factory ReadingPosition.fromJson(Map<String, dynamic> json) {
    return ReadingPosition(
      filePath: json['filePath'] ?? '',
      scrollPosition: (json['scrollPosition'] ?? 0.0).toDouble(),
      lastAccessed: DateTime.parse(json['lastAccessed'] ?? DateTime.now().toIso8601String()),
      currentSection: json['currentSection'],
      currentLine: json['currentLine'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'scrollPosition': scrollPosition,
      'lastAccessed': lastAccessed.toIso8601String(),
      'currentSection': currentSection,
      'currentLine': currentLine,
    };
  }

  ReadingPosition copyWith({
    String? filePath,
    double? scrollPosition,
    DateTime? lastAccessed,
    String? currentSection,
    int? currentLine,
  }) {
    return ReadingPosition(
      filePath: filePath ?? this.filePath,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      currentSection: currentSection ?? this.currentSection,
      currentLine: currentLine ?? this.currentLine,
    );
  }

  @override
  String toString() {
    return 'ReadingPosition(filePath: $filePath, scrollPosition: $scrollPosition, lastAccessed: $lastAccessed, currentSection: $currentSection, currentLine: $currentLine)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingPosition &&
        other.filePath == filePath &&
        other.scrollPosition == scrollPosition &&
        other.lastAccessed == lastAccessed &&
        other.currentSection == currentSection &&
        other.currentLine == currentLine;
  }

  @override
  int get hashCode => Object.hash(filePath, scrollPosition, lastAccessed, currentSection, currentLine);

  /// Get progress percentage (0-100)
  double get progressPercentage => (scrollPosition * 100).clamp(0.0, 100.0);

  /// Check if this is a recent position (accessed within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(lastAccessed);
    return difference.inHours < 24;
  }

  /// Get a display-friendly description of the position
  String get displayDescription {
    if (currentSection != null) {
      return 'At "$currentSection" (${progressPercentage.toStringAsFixed(1)}%)';
    }
    return '${progressPercentage.toStringAsFixed(1)}% through document';
  }
}

class Bookmark {
  final String id;
  final String filePath;
  final double position; // 0.0 to 1.0
  final String title;
  final String? note;
  final DateTime createdAt;
  final String? section; // Current heading/section

  Bookmark({
    String? id,
    required this.filePath,
    required this.position,
    required this.title,
    this.note,
    DateTime? createdAt,
    this.section,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] ?? const Uuid().v4(),
      filePath: json['filePath'] ?? '',
      position: (json['position'] ?? 0.0).toDouble(),
      title: json['title'] ?? '',
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      section: json['section'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'position': position,
      'title': title,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'section': section,
    };
  }

  Bookmark copyWith({
    String? id,
    String? filePath,
    double? position,
    String? title,
    String? note,
    DateTime? createdAt,
    String? section,
  }) {
    return Bookmark(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      position: position ?? this.position,
      title: title ?? this.title,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      section: section ?? this.section,
    );
  }

  @override
  String toString() {
    return 'Bookmark(id: $id, filePath: $filePath, position: $position, title: $title, section: $section, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark &&
        other.id == id &&
        other.filePath == filePath &&
        other.position == position &&
        other.title == title &&
        other.note == note &&
        other.createdAt == createdAt &&
        other.section == section;
  }

  @override
  int get hashCode => Object.hash(id, filePath, position, title, note, createdAt, section);

  /// Get progress percentage (0-100)
  double get progressPercentage => (position * 100).clamp(0.0, 100.0);

  /// Get a display-friendly description
  String get displayDescription {
    if (section != null) {
      return 'At "$section" (${progressPercentage.toStringAsFixed(1)}%)';
    }
    return '${progressPercentage.toStringAsFixed(1)}% through document';
  }

  /// Check if this bookmark was created recently (within last 7 days)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 7;
  }

  /// Get formatted creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}