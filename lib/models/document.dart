class Document {
  final String fileName;
  final String filePath;
  final String content;
  final DateTime lastModified;
  final int fileSize;

  Document({
    required this.fileName,
    required this.filePath,
    required this.content,
    required this.lastModified,
    required this.fileSize,
  });

  factory Document.fromFile({
    required String fileName,
    required String filePath,
    required String content,
    required DateTime lastModified,
    required int fileSize,
  }) {
    return Document(
      fileName: fileName,
      filePath: filePath,
      content: content,
      lastModified: lastModified,
      fileSize: fileSize,
    );
  }

  Document copyWith({
    String? fileName,
    String? filePath,
    String? content,
    DateTime? lastModified,
    int? fileSize,
  }) {
    return Document(
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      lastModified: lastModified ?? this.lastModified,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  String toString() {
    return 'Document(fileName: $fileName, filePath: $filePath, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document && other.filePath == filePath;
  }

  @override
  int get hashCode => filePath.hashCode;
}