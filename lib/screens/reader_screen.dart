import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/recent_files_provider.dart';
import '../providers/reading_position_provider.dart';
import '../widgets/streaming_markdown_viewer.dart';
import '../widgets/table_of_contents_widget.dart';
import '../widgets/search_widget.dart';
import '../widgets/display_mode_selector.dart';
import '../utils/constants.dart';
import '../models/app_settings.dart';
import '../models/reading_settings.dart';
import '../models/table_of_contents.dart';
import '../models/search_result.dart';
import '../models/reading_position.dart';
import '../services/table_of_contents_service.dart';
import '../services/search_service.dart';
import 'home_screen.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late ScrollController _scrollController;
  List<TocItem> _tocItems = [];
  TocItem? _currentTocItem;
  bool _isSearchVisible = false;
  bool _isAppBarVisible = true;
  Timer? _autoHideTimer;
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final documentProvider = context.read<DocumentProvider>();
      final recentFilesProvider = context.read<RecentFilesProvider>();
      
      if (documentProvider.hasDocument) {
        recentFilesProvider.addRecentFile(documentProvider.currentDocument!.filePath);
        _generateTableOfContents(documentProvider.currentDocument!.content);
        _loadReadingPosition();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _autoHideTimer?.cancel();
    _scrollDebounce?.cancel();
    super.dispose();
  }

  void _generateTableOfContents(String content) {
    setState(() {
      _tocItems = TableOfContentsService.generateTOC(content);
    });
  }

  void _onTocItemTapped(TocItem item) {
    Navigator.of(context).pop(); // Close drawer
    
    final documentProvider = context.read<DocumentProvider>();
    if (!documentProvider.hasDocument) return;
    
    final content = documentProvider.currentDocument!.content;
    final scrollRatio = TableOfContentsService.calculateScrollRatio(content, item.lineNumber);
    
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final targetOffset = maxScrollExtent * scrollRatio;
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    
    setState(() {
      _currentTocItem = item;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  void _onSearchResultTapped(SearchResult result) {
    final documentProvider = context.read<DocumentProvider>();
    if (!documentProvider.hasDocument) return;
    
    final content = documentProvider.currentDocument!.content;
    final scrollRatio = SearchService.calculateScrollPosition(content, result.lineNumber);
    
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final targetOffset = maxScrollExtent * scrollRatio;
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _closeSearch() {
    setState(() {
      _isSearchVisible = false;
    });
  }

  void _onScroll() {
    // Debounce scroll position saving
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 1000), () {
      _saveReadingPosition();
    });
    
    // Trigger auto-hide behavior on scroll (which is a clear user interaction)
    final themeProvider = context.read<ThemeProvider>();
    final readingSettings = themeProvider.readingSettings;
    if (readingSettings.autoHideControls) {
      _handleUserInteraction(readingSettings);
    }
  }

  Future<void> _loadReadingPosition() async {
    final documentProvider = context.read<DocumentProvider>();
    if (!documentProvider.hasDocument) return;


    final positionProvider = context.read<ReadingPositionProvider>();
    final position = await positionProvider.getReadingPosition(
      documentProvider.currentDocument!.filePath,
    );

    if (position != null && mounted) {
      // Restore scroll position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final maxScrollExtent = _scrollController.position.maxScrollExtent;
          final targetOffset = positionProvider.calculateScrollOffset(
            position.scrollPosition,
            maxScrollExtent,
          );
          
          _scrollController.jumpTo(targetOffset);
        }
      });
    }

  }

  Future<void> _saveReadingPosition() async {
    final documentProvider = context.read<DocumentProvider>();
    if (!documentProvider.hasDocument || !_scrollController.hasClients) return;

    final positionProvider = context.read<ReadingPositionProvider>();
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentOffset = _scrollController.offset;

    final scrollPosition = positionProvider.calculateScrollPosition(
      documentProvider.currentDocument!.content,
      currentOffset,
      maxScrollExtent,
    );

    final readingPosition = ReadingPosition(
      filePath: documentProvider.currentDocument!.filePath,
      scrollPosition: scrollPosition,
      lastAccessed: DateTime.now(),
      currentSection: _currentTocItem?.title,
    );

    await positionProvider.saveReadingPosition(readingPosition);
  }





  @override
  Widget build(BuildContext context) {
    return Selector<DocumentProvider, bool>(
      selector: (_, provider) => provider.hasDocument,
      builder: (context, hasDocument, _) {
        if (!hasDocument) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          });
          return const SizedBox.shrink();
        }

        final documentProvider = context.read<DocumentProvider>();
        final document = documentProvider.currentDocument!;
        
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            final readingSettings = themeProvider.readingSettings;

        return Scaffold(
          drawer: (_tocItems.isNotEmpty && readingSettings.showTableOfContents)
              ? Drawer(
                  child: TableOfContentsWidget(
                    tocItems: _tocItems,
                    onItemTapped: _onTocItemTapped,
                    currentItem: _currentTocItem,
                  ),
                )
              : null,
          appBar: (_shouldShowAppBar(readingSettings) && _isAppBarVisible) ? AppBar(
            title: Text(
              document.fileName,
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              onPressed: () => _navigateHome(context),
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back to home',
            ),
            actions: [
              IconButton(
                onPressed: _toggleSearch,
                icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
                tooltip: _isSearchVisible ? 'Close search' : 'Search in document',
              ),
              if (_tocItems.isNotEmpty && readingSettings.showTableOfContents)
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.list_alt),
                      tooltip: 'Table of contents',
                    );
                  },
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'More options',
                onSelected: (value) {
                  switch (value) {
                    case 'info':
                      _showDocumentInfo(context, document);
                      break;
                    case 'settings':
                      _showSettingsDialog(context);
                      break;
                    case 'reading_settings':
                      _showReadingSettingsDialog(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'info',
                    child: ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Document Info'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reading_settings',
                    child: ListTile(
                      leading: Icon(Icons.tune),
                      title: Text('Reading Settings'),
                    ),
                  ),
                ],
              ),
            ],
          ) : null,
          body: Column(
            children: [
              if (_isSearchVisible && _shouldShowSearch(readingSettings))
                SearchWidget(
                  documentContent: document.content,
                  onResultTapped: _onSearchResultTapped,
                  onClose: _closeSearch,
                ),
              Expanded(
                child: Padding(
                  padding: readingSettings.contentPadding,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor * readingSettings.textScaleFactor,
                    ),
                    child: StreamingMarkdownViewer(
                      markdownContent: document.content,
                      scrollController: _scrollController,
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(readingSettings),
          bottomNavigationBar: _shouldShowBottomBar(readingSettings) 
              ? Container(
                  padding: const EdgeInsets.all(AppConstants.contentPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openNewFile(context),
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Open New File'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
          },
        );
      },
    );
  }

  void _navigateHome(BuildContext context) {
    context.read<DocumentProvider>().clearDocument();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  void _openNewFile(BuildContext context) {
    context.read<DocumentProvider>().pickAndOpenFile();
  }

  void _showDocumentInfo(BuildContext context, document) {
    final documentProvider = context.read<DocumentProvider>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Document Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('File Name', document.fileName),
              const SizedBox(height: AppConstants.elementSpacing / 2),
              _buildInfoRow('File Size', documentProvider.formattedFileSize),
              const SizedBox(height: AppConstants.elementSpacing / 2),
              _buildInfoRow('Last Modified', documentProvider.formattedLastModified),
              const SizedBox(height: AppConstants.elementSpacing / 2),
              _buildInfoRow('Path', document.filePath),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  void _showReadingSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReadingSettingsDialog(),
    );
  }


  // Helper methods to determine UI visibility based on display mode
  bool _shouldShowAppBar(ReadingSettings settings) {
    // Always allow app bar to be shown initially
    // The auto-hide logic will handle hiding it when appropriate
    return true;
  }

  bool _shouldShowBottomBar(ReadingSettings settings) {
    return true; // Always show bottom bar in normal mode
  }

  bool _shouldShowSearch(ReadingSettings settings) {
    return true; // Always allow search in normal mode
  }

  void _handleUserInteraction(ReadingSettings settings) {
    // Only handle auto-hide if the user has actually interacted
    // and the app bar is currently visible (to avoid triggering on first load)
    if (settings.autoHideControls && _isAppBarVisible) {
      _startAutoHideTimer(settings);
    }
    
    // Show UI temporarily on interaction if it was hidden
    if (settings.autoHideControls && !_isAppBarVisible) {
      setState(() {
        _isAppBarVisible = true;
      });
      _startAutoHideTimer(settings);
    }
  }

  void _startAutoHideTimer(ReadingSettings settings) {
    _autoHideTimer?.cancel();
    
    if (settings.autoHideControls) {
      _autoHideTimer = Timer(settings.autoHideDelay, () {
        if (mounted) {
          setState(() {
            _isAppBarVisible = false;
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Don't automatically start auto-hide timer when the widget is built
    // Auto-hide should only be triggered by user interaction
  }

  Widget? _buildFloatingActionButton(ReadingSettings settings) {
    // Show FAB when app bar is hidden and auto-hide is enabled
    if (settings.autoHideControls && !_isAppBarVisible) {
      return FloatingActionButton(
        mini: true,
        onPressed: () {
          // Show the app bar temporarily
          setState(() {
            _isAppBarVisible = true;
          });
          // Don't start the auto-hide timer immediately
        },
        child: const Icon(Icons.menu),
        tooltip: 'Show menu',
      );
    }
    return null;
  }
}

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.settingsTitle),
      content: SizedBox(
        width: 400,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              ListTile(
                title: const Text(AppStrings.themeLabel),
                trailing: DropdownButton<AppThemeMode>(
                  value: themeProvider.themeMode,
                  onChanged: (AppThemeMode? newValue) {
                    if (newValue != null) {
                      themeProvider.setThemeMode(newValue);
                    }
                  },
                  items: AppThemeMode.values.map((AppThemeMode mode) {
                    return DropdownMenuItem<AppThemeMode>(
                      value: mode,
                      child: Text(_getThemeModeDisplayName(mode)),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: const Text(AppStrings.fontSizeLabel),
                trailing: DropdownButton<FontSize>(
                  value: themeProvider.fontSize,
                  onChanged: (FontSize? newValue) {
                    if (newValue != null) {
                      themeProvider.setFontSize(newValue);
                    }
                  },
                  items: FontSize.values.map((FontSize size) {
                    return DropdownMenuItem<FontSize>(
                      value: size,
                      child: Text(size.displayName),
                    );
                  }).toList(),
                ),
              ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}