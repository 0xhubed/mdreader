import 'package:flutter/foundation.dart';
import '../models/recent_file.dart';
import '../services/recent_files_service.dart';

class RecentFilesProvider with ChangeNotifier {
  final RecentFilesService _recentFilesService = RecentFilesService();
  
  List<RecentFile> _recentFiles = [];
  bool _isLoading = false;

  List<RecentFile> get recentFiles => _recentFiles;
  bool get isLoading => _isLoading;
  bool get hasRecentFiles => _recentFiles.isNotEmpty;

  Future<void> loadRecentFiles() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _recentFiles = await _recentFilesService.getRecentFiles();
    } catch (e) {
      debugPrint('Failed to load recent files: $e');
      _recentFiles = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecentFile(String filePath) async {
    try {
      await _recentFilesService.addRecentFile(filePath);
      await loadRecentFiles();
    } catch (e) {
      debugPrint('Failed to add recent file: $e');
    }
  }

  Future<void> removeRecentFile(String filePath) async {
    try {
      await _recentFilesService.removeRecentFile(filePath);
      _recentFiles.removeWhere((file) => file.path == filePath);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to remove recent file: $e');
    }
  }

  Future<void> clearRecentFiles() async {
    try {
      await _recentFilesService.clearRecentFiles();
      _recentFiles.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear recent files: $e');
    }
  }

  String formatFileSize(int bytes) {
    return _recentFilesService.formatFileSize(bytes);
  }

  String formatDate(DateTime date) {
    return _recentFilesService.formatDate(date);
  }
}