class RecentFile {
  final String path;
  final String name;
  final DateTime lastModified;
  final DateTime lastAccessed;
  final int size;
  final String preview;

  const RecentFile({
    required this.path,
    required this.name,
    required this.lastModified,
    required this.lastAccessed,
    required this.size,
    required this.preview,
  });

  factory RecentFile.fromJson(Map<String, dynamic> json) {
    return RecentFile(
      path: json['path'] ?? '',
      name: json['name'] ?? '',
      lastModified: DateTime.parse(json['lastModified'] ?? DateTime.now().toIso8601String()),
      lastAccessed: DateTime.parse(json['lastAccessed'] ?? DateTime.now().toIso8601String()),
      size: json['size'] ?? 0,
      preview: json['preview'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'lastModified': lastModified.toIso8601String(),
      'lastAccessed': lastAccessed.toIso8601String(),
      'size': size,
      'preview': preview,
    };
  }

  RecentFile copyWith({
    String? path,
    String? name,
    DateTime? lastModified,
    DateTime? lastAccessed,
    int? size,
    String? preview,
  }) {
    return RecentFile(
      path: path ?? this.path,
      name: name ?? this.name,
      lastModified: lastModified ?? this.lastModified,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      size: size ?? this.size,
      preview: preview ?? this.preview,
    );
  }

  @override
  String toString() {
    return 'RecentFile(path: $path, name: $name, lastModified: $lastModified, lastAccessed: $lastAccessed, size: $size, preview: $preview)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentFile &&
        other.path == path &&
        other.name == name &&
        other.lastModified == lastModified &&
        other.lastAccessed == lastAccessed &&
        other.size == size &&
        other.preview == preview;
  }

  @override
  int get hashCode => Object.hash(path, name, lastModified, lastAccessed, size, preview);
}