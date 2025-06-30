import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table_of_contents.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class TableOfContentsWidget extends StatefulWidget {
  final List<TocItem> tocItems;
  final Function(TocItem) onItemTapped;
  final TocItem? currentItem;

  const TableOfContentsWidget({
    super.key,
    required this.tocItems,
    required this.onItemTapped,
    this.currentItem,
  });

  @override
  State<TableOfContentsWidget> createState() => _TableOfContentsWidgetState();
}

class _TableOfContentsWidgetState extends State<TableOfContentsWidget> {
  final Set<String> _expandedItems = <String>{};

  @override
  void initState() {
    super.initState();
    // Expand all items by default
    _expandAllItems();
  }

  void _expandAllItems() {
    for (final item in widget.tocItems) {
      _expandItem(item);
    }
  }

  void _expandItem(TocItem item) {
    if (item.hasChildren) {
      _expandedItems.add(item.id);
      for (final child in item.children) {
        _expandItem(child);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tocItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppConstants.elementSpacing),
            Expanded(
              child: _buildTocList(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.contentPadding),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.list_alt,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Table of Contents',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'expand_all':
                  setState(() {
                    _expandAllItems();
                  });
                  break;
                case 'collapse_all':
                  setState(() {
                    _expandedItems.clear();
                  });
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'expand_all',
                child: Row(
                  children: [
                    Icon(Icons.expand_more),
                    SizedBox(width: 8),
                    Text('Expand All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'collapse_all',
                child: Row(
                  children: [
                    Icon(Icons.expand_less),
                    SizedBox(width: 8),
                    Text('Collapse All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 48,
            color: theme.disabledColor,
          ),
          const SizedBox(height: AppConstants.elementSpacing),
          Text(
            'No Headings Found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: AppConstants.elementSpacing / 2),
          Text(
            'This document doesn\'t contain any headings',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTocList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.tocItems.length,
      itemBuilder: (context, index) {
        return _buildTocItem(context, widget.tocItems[index]);
      },
    );
  }

  Widget _buildTocItem(BuildContext context, TocItem item) {
    final theme = Theme.of(context);
    final isCurrentItem = widget.currentItem?.id == item.id;
    final isExpanded = _expandedItems.contains(item.id);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => widget.onItemTapped(item),
          child: Container(
            padding: EdgeInsets.only(
              left: AppConstants.contentPadding + (item.indentLevel * 16.0),
              right: AppConstants.contentPadding,
              top: AppConstants.elementSpacing / 2,
              bottom: AppConstants.elementSpacing / 2,
            ),
            decoration: BoxDecoration(
              color: isCurrentItem 
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : null,
              border: isCurrentItem 
                  ? Border(
                      left: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (item.hasChildren)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedItems.remove(item.id);
                        } else {
                          _expandedItems.add(item.id);
                        }
                      });
                    },
                    child: Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: _getFontSizeForLevel(item.level),
                      fontWeight: _getFontWeightForLevel(item.level),
                      color: isCurrentItem 
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'H${item.level}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (item.hasChildren && isExpanded)
          ...item.children.map((child) => _buildTocItem(context, child)),
      ],
    );
  }

  double _getFontSizeForLevel(int level) {
    switch (level) {
      case 1: return 16.0;
      case 2: return 15.0;
      case 3: return 14.0;
      case 4: return 13.0;
      case 5: return 12.0;
      case 6: return 11.0;
      default: return 11.0;
    }
  }

  FontWeight _getFontWeightForLevel(int level) {
    switch (level) {
      case 1: return FontWeight.w600;
      case 2: return FontWeight.w500;
      case 3: return FontWeight.w500;
      default: return FontWeight.normal;
    }
  }
}