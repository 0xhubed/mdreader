import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'markdown_viewer.dart';

class StreamingMarkdownViewer extends StatefulWidget {
  final String markdownContent;
  final ScrollController? scrollController;

  const StreamingMarkdownViewer({
    super.key,
    required this.markdownContent,
    this.scrollController,
  });

  @override
  State<StreamingMarkdownViewer> createState() => _StreamingMarkdownViewerState();
}

class _StreamingMarkdownViewerState extends State<StreamingMarkdownViewer> {
  static const int _chunkSize = 50000; // 50KB chunks
  static const int _maxVisibleChunks = 5; // Keep max 5 chunks in memory
  
  late List<String> _chunks;
  late ScrollController _scrollController;
  final List<int> _loadedChunks = [];
  bool _isLargeFile = false;
  bool _needsSort = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _initializeChunking();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _initializeChunking() {
    final contentLength = widget.markdownContent.length;
    _isLargeFile = contentLength > _chunkSize;
    
    if (_isLargeFile) {
      _chunks = _createChunks(widget.markdownContent);
      _loadedChunks.add(0); // Always load first chunk
    }
  }

  List<String> _createChunks(String content) {
    final chunks = <String>[];
    final lines = content.split('\n');
    final buffer = StringBuffer();
    int currentSize = 0;
    
    for (final line in lines) {
      final lineSize = line.length + 1; // +1 for newline
      
      if (currentSize + lineSize > _chunkSize && buffer.isNotEmpty) {
        chunks.add(buffer.toString());
        buffer.clear();
        currentSize = 0;
      }
      
      buffer.writeln(line);
      currentSize += lineSize;
    }
    
    if (buffer.isNotEmpty) {
      chunks.add(buffer.toString());
    }
    
    return chunks;
  }

  void _onScroll() {
    if (!_isLargeFile) return;
    
    final scrollPosition = _scrollController.position;
    final totalHeight = scrollPosition.maxScrollExtent;
    final currentPosition = scrollPosition.pixels;
    
    // Calculate which chunk should be visible based on scroll position
    final progress = currentPosition / totalHeight;
    final targetChunk = (progress * _chunks.length).floor().clamp(0, _chunks.length - 1);
    
    _loadChunkIfNeeded(targetChunk);
    _unloadDistantChunks(targetChunk);
  }

  void _loadChunkIfNeeded(int chunkIndex) {
    if (!_loadedChunks.contains(chunkIndex)) {
      setState(() {
        _loadedChunks.add(chunkIndex);
        _needsSort = true;
        
        // Also load adjacent chunks for smooth scrolling
        if (chunkIndex > 0 && !_loadedChunks.contains(chunkIndex - 1)) {
          _loadedChunks.add(chunkIndex - 1);
        }
        if (chunkIndex < _chunks.length - 1 && !_loadedChunks.contains(chunkIndex + 1)) {
          _loadedChunks.add(chunkIndex + 1);
        }
      });
    }
  }

  void _unloadDistantChunks(int currentChunk) {
    if (_loadedChunks.length <= _maxVisibleChunks) return;
    
    // Calculate distances and keep only the closest chunks
    final chunkDistances = <int, int>{};
    for (final loadedChunk in _loadedChunks) {
      chunkDistances[loadedChunk] = (loadedChunk - currentChunk).abs();
    }
    
    // Sort by distance and keep only the closest chunks
    final sortedChunks = chunkDistances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    final chunksToKeep = sortedChunks
        .take(_maxVisibleChunks)
        .map((e) => e.key)
        .toList();
    
    setState(() {
      _loadedChunks.clear();
      _loadedChunks.addAll(chunksToKeep);
      _needsSort = true;
    });
  }

  String _getVisibleContent() {
    if (!_isLargeFile) {
      return widget.markdownContent;
    }
    
    // Only sort when chunks have changed
    if (_needsSort) {
      _loadedChunks.sort();
      _needsSort = false;
    }
    
    final buffer = StringBuffer();
    
    for (final chunkIndex in _loadedChunks) {
      if (chunkIndex < _chunks.length) {
        buffer.write(_chunks[chunkIndex]);
      }
    }
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLargeFile) {
      return Column(
        children: [
          _buildPerformanceIndicator(),
          Expanded(
            child: Stack(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: MarkdownViewer(
                    key: ValueKey('large_${_loadedChunks.join('_')}'),
                    markdownContent: _getVisibleContent(),
                    scrollController: _scrollController,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildProgressIndicator(context),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return Stack(
      children: [
        Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: MarkdownViewer(
            key: ValueKey('small_${widget.markdownContent.hashCode}'),
            markdownContent: widget.markdownContent,
            scrollController: _scrollController,
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: _buildProgressIndicator(context),
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicator() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.contentPadding,
            vertical: AppConstants.elementSpacing / 2,
          ),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode 
                ? Colors.orange.withOpacity(0.1)
                : Colors.orange.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.speed,
                size: 16,
                color: Colors.orange.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Large file detected - Using optimized rendering (${_loadedChunks.length}/${_chunks.length} sections loaded)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.withOpacity(0.8),
                  ),
                ),
              ),
              Text(
                _formatFileSize(widget.markdownContent.length),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return StreamBuilder<double>(
      stream: Stream.periodic(const Duration(milliseconds: 100), (_) {
        if (_scrollController.hasClients) {
          final position = _scrollController.position;
          final progress = position.pixels / position.maxScrollExtent;
          return progress.clamp(0.0, 1.0);
        }
        return 0.0;
      }),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        final percentage = (progress * 100).toInt();
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '$percentage%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}