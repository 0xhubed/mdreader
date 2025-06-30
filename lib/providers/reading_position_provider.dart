import 'package:flutter/foundation.dart';
import '../models/reading_position.dart';
import '../services/reading_position_service.dart';

class ReadingPositionProvider with ChangeNotifier {
  final ReadingPositionService _service = ReadingPositionService();
  
  Map<String, List<Bookmark>> _allBookmarks = {};
  ReadingPosition? _currentPosition;
  bool _isLoading = false;

  Map<String, List<Bookmark>> get allBookmarks => _allBookmarks;
  ReadingPosition? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;

  Future<void> loadBookmarks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _allBookmarks = await _service.getAllBookmarks();
    } catch (e) {
      debugPrint('Failed to load bookmarks: $e');
      _allBookmarks = {};
    }
    
    _isLoading = false;
    notifyListeners();
  }

  List<Bookmark> getBookmarksForFile(String filePath) {
    return _allBookmarks[filePath] ?? [];
  }

  Future<ReadingPosition?> getReadingPosition(String filePath) async {
    try {
      final position = await _service.getReadingPosition(filePath);
      if (position != null) {
        _currentPosition = position;
        notifyListeners();
      }
      return position;
    } catch (e) {
      debugPrint('Failed to get reading position: $e');
      return null;
    }
  }

  Future<void> saveReadingPosition(ReadingPosition position) async {
    try {
      await _service.saveReadingPosition(position);
      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save reading position: $e');
    }
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    try {
      await _service.addBookmark(bookmark);
      
      // Update local bookmarks
      final fileBookmarks = getBookmarksForFile(bookmark.filePath);
      final existingIndex = fileBookmarks.indexWhere(
        (b) => (b.position - bookmark.position).abs() < 0.01,
      );
      
      if (existingIndex != -1) {
        fileBookmarks[existingIndex] = bookmark;
      } else {
        fileBookmarks.add(bookmark);
        fileBookmarks.sort((a, b) => a.position.compareTo(b.position));
      }
      
      _allBookmarks[bookmark.filePath] = fileBookmarks;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add bookmark: $e');
    }
  }

  Future<void> removeBookmark(String filePath, String bookmarkId) async {
    try {
      await _service.removeBookmark(filePath, bookmarkId);
      
      // Update local bookmarks
      final fileBookmarks = getBookmarksForFile(filePath);
      fileBookmarks.removeWhere((b) => b.id == bookmarkId);
      _allBookmarks[filePath] = fileBookmarks;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to remove bookmark: $e');
    }
  }

  Future<void> clearReadingPositions() async {
    try {
      await _service.clearReadingPositions();
      _currentPosition = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear reading positions: $e');
    }
  }

  Future<void> clearBookmarks(String? filePath) async {
    try {
      await _service.clearBookmarks(filePath);
      
      if (filePath == null) {
        _allBookmarks.clear();
      } else {
        _allBookmarks.remove(filePath);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear bookmarks: $e');
    }
  }

  double calculateScrollPosition(String content, double scrollOffset, double maxScrollExtent) {
    return _service.calculateScrollPosition(content, scrollOffset, maxScrollExtent);
  }

  double calculateScrollOffset(double position, double maxScrollExtent) {
    return _service.calculateScrollOffset(position, maxScrollExtent);
  }
}