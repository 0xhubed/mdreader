import 'package:flutter/foundation.dart';
import '../models/document.dart';
import '../services/file_service.dart';

enum DocumentState {
  initial,
  loading,
  loaded,
  error,
}

class DocumentProvider with ChangeNotifier {
  final FileService _fileService = FileService();
  
  DocumentState _state = DocumentState.initial;
  Document? _currentDocument;
  String? _errorMessage;

  DocumentState get state => _state;
  Document? get currentDocument => _currentDocument;
  String? get errorMessage => _errorMessage;
  bool get hasDocument => _currentDocument != null;
  bool get isLoading => _state == DocumentState.loading;
  bool get hasError => _state == DocumentState.error;

  Future<void> pickAndOpenFile() async {
    _setState(DocumentState.loading);
    
    try {
      final document = await _fileService.pickAndReadFile();
      
      if (document != null) {
        _currentDocument = document;
        _errorMessage = null;
        _setState(DocumentState.loaded);
      } else {
        _setState(DocumentState.initial);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(DocumentState.error);
    }
  }

  Future<void> openFile(String filePath) async {
    _setState(DocumentState.loading);
    
    try {
      final document = await _fileService.readFile(filePath);
      
      if (document != null) {
        _currentDocument = document;
        _errorMessage = null;
        _setState(DocumentState.loaded);
      } else {
        _errorMessage = 'Failed to read file';
        _setState(DocumentState.error);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(DocumentState.error);
    }
  }

  void clearDocument() {
    _currentDocument = null;
    _errorMessage = null;
    _setState(DocumentState.initial);
  }

  void clearError() {
    if (_state == DocumentState.error) {
      _errorMessage = null;
      _setState(_currentDocument != null ? DocumentState.loaded : DocumentState.initial);
    }
  }

  void _setState(DocumentState newState) {
    _state = newState;
    notifyListeners();
  }

  String get formattedFileSize {
    if (_currentDocument == null) return '';
    return _fileService.formatFileSize(_currentDocument!.fileSize);
  }

  String get formattedLastModified {
    if (_currentDocument == null) return '';
    final date = _currentDocument!.lastModified;
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}