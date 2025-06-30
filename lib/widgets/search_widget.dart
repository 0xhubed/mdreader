import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/search_result.dart';
import '../providers/theme_provider.dart';
import '../services/search_service.dart';
import '../utils/constants.dart';

class SearchWidget extends StatefulWidget {
  final String documentContent;
  final Function(SearchResult) onResultTapped;
  final VoidCallback onClose;

  const SearchWidget({
    super.key,
    required this.documentContent,
    required this.onResultTapped,
    required this.onClose,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<SearchResult> _searchResults = [];
  int _currentResultIndex = -1;
  bool _caseSensitive = false;
  bool _useRegex = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _currentResultIndex = -1;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    List<SearchResult> results;
    
    if (_useRegex) {
      results = SearchService.searchWithRegex(
        widget.documentContent,
        query,
        caseSensitive: _caseSensitive,
      );
    } else {
      results = SearchService.searchInDocument(widget.documentContent, query);
      if (!_caseSensitive) {
        // Filter results for case-insensitive search
        results = results.where((result) {
          return result.lineText.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    }

    setState(() {
      _searchResults = results;
      _currentResultIndex = results.isNotEmpty ? 0 : -1;
      _isSearching = false;
    });

    if (results.isNotEmpty) {
      widget.onResultTapped(results[0]);
    }
  }

  void _navigateToNext() {
    if (_searchResults.isEmpty) return;
    
    setState(() {
      _currentResultIndex = (_currentResultIndex + 1) % _searchResults.length;
    });
    
    widget.onResultTapped(_searchResults[_currentResultIndex]);
  }

  void _navigateToPrevious() {
    if (_searchResults.isEmpty) return;
    
    setState(() {
      _currentResultIndex = _currentResultIndex <= 0 
          ? _searchResults.length - 1 
          : _currentResultIndex - 1;
    });
    
    widget.onResultTapped(_searchResults[_currentResultIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = Theme.of(context);
        
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchBar(theme),
              if (_searchResults.isNotEmpty || _isSearching)
                _buildSearchResults(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.contentPadding),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.search,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: _useRegex ? 'Search with regex...' : 'Search in document...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: theme.textTheme.bodyMedium,
                  onSubmitted: (_) => _navigateToNext(),
                ),
              ),
              if (_searchResults.isNotEmpty) ...[
                Text(
                  '${_currentResultIndex + 1}/${_searchResults.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _navigateToPrevious,
                  icon: const Icon(Icons.keyboard_arrow_up),
                  iconSize: 20,
                  tooltip: 'Previous result',
                ),
                IconButton(
                  onPressed: _navigateToNext,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  iconSize: 20,
                  tooltip: 'Next result',
                ),
              ],
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    switch (value) {
                      case 'case_sensitive':
                        _caseSensitive = !_caseSensitive;
                        break;
                      case 'regex':
                        _useRegex = !_useRegex;
                        break;
                    }
                  });
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'case_sensitive',
                    child: Row(
                      children: [
                        Icon(_caseSensitive ? Icons.check_box : Icons.check_box_outline_blank),
                        const SizedBox(width: 8),
                        const Text('Case sensitive'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'regex',
                    child: Row(
                      children: [
                        Icon(_useRegex ? Icons.check_box : Icons.check_box_outline_blank),
                        const SizedBox(width: 8),
                        const Text('Regular expression'),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
                iconSize: 20,
                tooltip: 'Close search',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_isSearching) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.contentPadding),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Searching...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.contentPadding),
        child: Text(
          'No results found',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      );
    }

    final stats = SearchService.getSearchStatistics(_searchResults);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.contentPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${stats['totalMatches']} matches in ${stats['totalLines']} lines',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}