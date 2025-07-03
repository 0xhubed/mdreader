import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_file.dart';

class RecentFilesService {
  static const String _recentFilesKey = 'recent_files';
  static const int _maxRecentFiles = 10;

  Future<List<RecentFile>> getRecentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentFilesKey);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<RecentFile> recentFiles = jsonList
          .map((json) => RecentFile.fromJson(json))
          .where((file) => File(file.path).existsSync())
          .toList();
      
      // Save cleaned list back to preferences
      await _saveRecentFiles(recentFiles);
      
      return recentFiles;
    } catch (e) {
      return [];
    }
  }

  Future<void> addRecentFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return;

      final stat = await file.stat();
      final content = await file.readAsString();
      
      final recentFile = RecentFile(
        path: filePath,
        name: _getFileName(filePath),
        lastModified: stat.modified,
        lastAccessed: DateTime.now(),
        size: stat.size,
        preview: _generatePreview(content),
      );

      final recentFiles = await getRecentFiles();
      
      // Remove if already exists
      recentFiles.removeWhere((f) => f.path == filePath);
      
      // Add to beginning
      recentFiles.insert(0, recentFile);
      
      // Keep only max recent files
      if (recentFiles.length > _maxRecentFiles) {
        recentFiles.removeRange(_maxRecentFiles, recentFiles.length);
      }
      
      await _saveRecentFiles(recentFiles);
    } catch (e) {
      // Silently fail to avoid disrupting the main flow
    }
  }

  Future<void> removeRecentFile(String filePath) async {
    try {
      final recentFiles = await getRecentFiles();
      recentFiles.removeWhere((f) => f.path == filePath);
      await _saveRecentFiles(recentFiles);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> clearRecentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentFilesKey);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _saveRecentFiles(List<RecentFile> recentFiles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(recentFiles.map((f) => f.toJson()).toList());
      await prefs.setString(_recentFilesKey, jsonString);
    } catch (e) {
      // Silently fail
    }
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  String _generatePreview(String content) {
    // Clean markdown content for preview
    String preview = content
        .replaceAll(RegExp(r'#+ '), '') // Remove headers
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Remove bold
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // Remove italic
        .replaceAll(RegExp(r'`(.*?)`'), r'$1') // Remove inline code
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // Remove links
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '') // Remove images
        .replaceAll(RegExp(r'\n+'), ' ') // Replace newlines with spaces
        .trim();

    // Limit to 100 characters
    if (preview.length > 100) {
      preview = '${preview.substring(0, 97)}...';
    }

    return preview.isEmpty ? 'No preview available' : preview;
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}