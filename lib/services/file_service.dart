import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/document.dart';

class FileService {
  static const List<String> _allowedExtensions = ['md', 'markdown', 'txt'];

  Future<Document?> pickAndReadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        return await _readFileFromPath(filePath);
      }
      return null;
    } catch (e) {
      throw FileServiceException('Failed to pick file: $e');
    }
  }

  Future<Document> _readFileFromPath(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw FileServiceException('File does not exist');
      }

      final stat = await file.stat();
      final content = await file.readAsString();
      final fileName = _extractFileName(filePath);

      if (!_isValidMarkdownFile(fileName)) {
        throw FileServiceException('Unsupported file type');
      }

      if (stat.size > 10 * 1024 * 1024) { // 10MB limit
        throw FileServiceException('File too large (max 10MB)');
      }

      return Document.fromFile(
        fileName: fileName,
        filePath: filePath,
        content: content,
        lastModified: stat.modified,
        fileSize: stat.size,
      );
    } catch (e) {
      if (e is FileServiceException) rethrow;
      throw FileServiceException('Failed to read file: $e');
    }
  }

  String _extractFileName(String filePath) {
    return filePath.split('/').last;
  }

  bool _isValidMarkdownFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return _allowedExtensions.contains(extension);
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool isMarkdownFile(String fileName) {
    return _isValidMarkdownFile(fileName);
  }
}

class FileServiceException implements Exception {
  final String message;
  FileServiceException(this.message);

  @override
  String toString() => 'FileServiceException: $message';
}