import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../models/document.dart';

class FileService {
  static const List<String> _allowedExtensions = ['md', 'markdown', 'txt'];
  static const int _maxFileSizeBytes = 50 * 1024 * 1024; // 50MB limit
  static const List<String> _dangerousPatterns = [
    r'<script[^>]*>.*?</script>',
    r'javascript:',
    r'data:text/html',
    r'onclick\s*=\s*["\x27]',
    r'onload\s*=\s*["\x27]',
    r'onerror\s*=\s*["\x27]',
    r'onmouseover\s*=\s*["\x27]',
    r'onfocus\s*=\s*["\x27]',
    r'onblur\s*=\s*["\x27]',
    r'onsubmit\s*=\s*["\x27]',
    r'onchange\s*=\s*["\x27]',
    r'eval\s*\(',
    r'document\.write\s*\(',
    r'document\.writeln\s*\(',
    r'innerHTML\s*=',
    r'outerHTML\s*=',
    r'document\.cookie',
    r'window\.location',
    r'location\.href',
    r'location\.replace',
    r'location\.assign',
    r'<iframe[^>]*>',
    r'<embed[^>]*>',
    r'<object[^>]*>',
    r'<link[^>]*rel\s*=\s*["\x27]stylesheet["\x27][^>]*>',
    r'<style[^>]*>.*?</style>',
    r'expression\s*\(',
    r'url\s*\(\s*["\x27]?javascript:',
    r'@import\s+["\x27]?javascript:',
    r'vbscript:',
    r'data:text/javascript',
    r'data:application/javascript',
  ];

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

  Future<Document?> readFile(String filePath) async {
    try {
      return await _readFileFromPath(filePath);
    } catch (e) {
      throw FileServiceException('Failed to read file: $e');
    }
  }

  Future<Document> _readFileFromPath(String filePath) async {
    try {
      final file = File(filePath);
      
      // Basic file existence and security checks
      await _performSecurityChecks(file, filePath);
      
      final stat = await file.stat();
      final fileName = _extractFileName(filePath);

      // File type validation
      if (!_isValidMarkdownFile(fileName)) {
        throw FileServiceException('Unsupported file type: ${_getFileExtension(fileName)}');
      }

      // File size validation
      if (stat.size > _maxFileSizeBytes) {
        throw FileServiceException('File too large (max ${formatFileSize(_maxFileSizeBytes)})');
      }

      // Empty file check
      if (stat.size == 0) {
        throw FileServiceException('File is empty');
      }

      // Read and validate file content
      final content = await _readAndValidateContent(file);

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

  Future<void> _performSecurityChecks(File file, String filePath) async {
    // Check file existence
    if (!await file.exists()) {
      throw FileServiceException('File does not exist');
    }

    // Check for directory traversal attempts
    if (filePath.contains('..') || filePath.contains('~')) {
      throw FileServiceException('Invalid file path');
    }

    // Check file permissions
    try {
      final stat = await file.stat();
      
      // Check if it's actually a file and not a directory
      if (stat.type != FileSystemEntityType.file) {
        throw FileServiceException('Selected item is not a file');
      }
      
      // Check file permissions (readable)
      final testRead = await file.openRead(0, 1).isEmpty;
      if (testRead) {
        throw FileServiceException('File appears to be empty or unreadable');
      }
    } catch (e) {
      if (e is FileServiceException) rethrow;
      throw FileServiceException('Cannot access file: $e');
    }
  }

  Future<String> _readAndValidateContent(File file) async {
    try {
      // Try to read as UTF-8 first
      String content;
      try {
        content = await file.readAsString(encoding: utf8);
      } catch (e) {
        // If UTF-8 fails, try latin1
        try {
          content = await file.readAsString(encoding: latin1);
        } catch (e) {
          throw FileServiceException('Unable to decode file content. Please ensure the file is a valid text file.');
        }
      }

      // Security validation - check for potentially dangerous content
      _validateContentSecurity(content);

      // Basic content validation
      if (content.trim().isEmpty) {
        throw FileServiceException('File appears to be empty');
      }

      // Check for binary content indicators
      if (_containsBinaryContent(content)) {
        throw FileServiceException('File appears to contain binary data');
      }

      return content;
    } catch (e) {
      if (e is FileServiceException) rethrow;
      throw FileServiceException('Failed to read file content: $e');
    }
  }

  void _validateContentSecurity(String content) {
    // Remove code blocks from security scanning to avoid false positives
    final contentWithoutCodeBlocks = _removeCodeBlocks(content);
    
    // Check for potentially dangerous patterns
    for (final pattern in _dangerousPatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(contentWithoutCodeBlocks)) {
        throw FileServiceException('File contains potentially unsafe content');
      }
    }

    // Check for excessive HTML tags (might indicate HTML file disguised as markdown)
    // Only check outside of code blocks
    final htmlTagCount = RegExp(r'<[^>]+>').allMatches(contentWithoutCodeBlocks).length;
    final totalLines = contentWithoutCodeBlocks.split('\n').length;
    
    if (htmlTagCount > totalLines * 0.3) {
      throw FileServiceException('File appears to be HTML rather than Markdown');
    }
  }

  String _removeCodeBlocks(String content) {
    // Remove fenced code blocks (```language...```)
    String result = content.replaceAll(RegExp(r'```[\s\S]*?```', multiLine: true), '');
    
    // Remove inline code (`code`)
    result = result.replaceAll(RegExp(r'`[^`]*`'), '');
    
    // Remove indented code blocks (4+ spaces at start of line)
    final lines = result.split('\n');
    final filteredLines = lines.where((line) => 
      !RegExp(r'^\s{4,}').hasMatch(line) || line.trim().isEmpty
    ).toList();
    
    return filteredLines.join('\n');
  }

  bool _containsBinaryContent(String content) {
    // Check for null bytes and other binary indicators
    if (content.contains('\x00')) return true;
    
    // Check for high ratio of non-printable characters
    final nonPrintableCount = content.runes.where((rune) {
      return rune < 32 && rune != 9 && rune != 10 && rune != 13; // Exclude tab, LF, CR
    }).length;
    
    return nonPrintableCount > content.length * 0.1;
  }

  String _extractFileName(String filePath) {
    return filePath.split('/').last;
  }

  String _getFileExtension(String fileName) {
    final parts = fileName.toLowerCase().split('.');
    return parts.length > 1 ? parts.last : 'unknown';
  }

  bool _isValidMarkdownFile(String fileName) {
    final extension = _getFileExtension(fileName);
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