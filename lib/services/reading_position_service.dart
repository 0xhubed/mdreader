import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_position.dart';

class ReadingPositionService {
  static const String _positionsKey = 'reading_positions';
  static const String _bookmarksKey = 'bookmarks';
  static const int _maxPositions = 50; // Keep positions for last 50 files
  static const int _maxBookmarksPerFile = 10; // Max 10 bookmarks per file

  Future<ReadingPosition?> getReadingPosition(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_positionsKey);
      
      if (jsonString == null) return null;
      
      final Map<String, dynamic> positions = json.decode(jsonString);
      final positionData = positions[filePath];
      
      if (positionData == null) return null;
      
      return ReadingPosition.fromJson(positionData);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveReadingPosition(ReadingPosition position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_positionsKey) ?? '{}';
      final Map<String, dynamic> positions = json.decode(jsonString);
      
      positions[position.filePath] = position.toJson();
      
      // Keep only the most recent positions
      if (positions.length > _maxPositions) {
        final sortedEntries = positions.entries.toList()
          ..sort((a, b) {
            final aTime = DateTime.parse(a.value['lastAccessed']);
            final bTime = DateTime.parse(b.value['lastAccessed']);
            return bTime.compareTo(aTime);
          });
        
        final recentPositions = Map.fromEntries(
          sortedEntries.take(_maxPositions),
        );
        
        await prefs.setString(_positionsKey, json.encode(recentPositions));
      } else {
        await prefs.setString(_positionsKey, json.encode(positions));
      }
    } catch (e) {
      // Silently fail to avoid disrupting reading experience
    }
  }

  Future<List<Bookmark>> getBookmarks(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_bookmarksKey);
      
      if (jsonString == null) return [];
      
      final Map<String, dynamic> bookmarksData = json.decode(jsonString);
      final fileBookmarks = bookmarksData[filePath] as List<dynamic>?;
      
      if (fileBookmarks == null) return [];
      
      return fileBookmarks
          .map((bookmark) => Bookmark.fromJson(bookmark))
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position));
    } catch (e) {
      return [];
    }
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    try {
      final bookmarks = await getBookmarks(bookmark.filePath);
      
      // Check if bookmark already exists at this position
      final existingIndex = bookmarks.indexWhere(
        (b) => (b.position - bookmark.position).abs() < 0.01,
      );
      
      if (existingIndex != -1) {
        // Update existing bookmark
        bookmarks[existingIndex] = bookmark;
      } else {
        // Add new bookmark
        bookmarks.add(bookmark);
        
        // Keep only max bookmarks per file
        if (bookmarks.length > _maxBookmarksPerFile) {
          bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          bookmarks.removeRange(_maxBookmarksPerFile, bookmarks.length);
        }
      }
      
      await _saveBookmarks(bookmark.filePath, bookmarks);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> removeBookmark(String filePath, String bookmarkId) async {
    try {
      final bookmarks = await getBookmarks(filePath);
      bookmarks.removeWhere((b) => b.id == bookmarkId);
      await _saveBookmarks(filePath, bookmarks);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _saveBookmarks(String filePath, List<Bookmark> bookmarks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_bookmarksKey) ?? '{}';
      final Map<String, dynamic> bookmarksData = json.decode(jsonString);
      
      bookmarksData[filePath] = bookmarks.map((b) => b.toJson()).toList();
      
      await prefs.setString(_bookmarksKey, json.encode(bookmarksData));
    } catch (e) {
      // Silently fail
    }
  }

  Future<Map<String, List<Bookmark>>> getAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_bookmarksKey);
      
      if (jsonString == null) return {};
      
      final Map<String, dynamic> bookmarksData = json.decode(jsonString);
      final result = <String, List<Bookmark>>{};
      
      for (final entry in bookmarksData.entries) {
        final bookmarks = (entry.value as List<dynamic>)
            .map((bookmark) => Bookmark.fromJson(bookmark))
            .toList();
        result[entry.key] = bookmarks;
      }
      
      return result;
    } catch (e) {
      return {};
    }
  }

  Future<void> clearReadingPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_positionsKey);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> clearBookmarks(String? filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (filePath == null) {
        // Clear all bookmarks
        await prefs.remove(_bookmarksKey);
      } else {
        // Clear bookmarks for specific file
        final jsonString = prefs.getString(_bookmarksKey) ?? '{}';
        final Map<String, dynamic> bookmarksData = json.decode(jsonString);
        bookmarksData.remove(filePath);
        await prefs.setString(_bookmarksKey, json.encode(bookmarksData));
      }
    } catch (e) {
      // Silently fail
    }
  }

  double calculateScrollPosition(String content, double scrollOffset, double maxScrollExtent) {
    if (maxScrollExtent <= 0) return 0.0;
    return (scrollOffset / maxScrollExtent).clamp(0.0, 1.0);
  }

  double calculateScrollOffset(double position, double maxScrollExtent) {
    return (position * maxScrollExtent).clamp(0.0, maxScrollExtent);
  }
}