import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location_picker_plus/themes/location_picker_plus_theme.dart';
import 'package:location_picker_plus/utils/adaptive_debouncer.dart';

class AutocompleteDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final Function(T?)? onChanged;
  final String hint;
  final bool isLoading;
  final LocationPickerTheme theme;
  final bool isExpanded;
  final bool enabled;
  final Widget Function(T) itemBuilder;
  final String Function(T) displayTextBuilder;
  final bool Function(T, String)? searchFilter;

  const AutocompleteDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    required this.isLoading,
    required this.theme,
    required this.itemBuilder,
    required this.displayTextBuilder,
    this.isExpanded = true,
    this.enabled = true,
    this.searchFilter,
  });

  @override
  State<AutocompleteDropdown<T>> createState() =>
      _AutocompleteDropdownState<T>();
}

class _AutocompleteDropdownState<T> extends State<AutocompleteDropdown<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<T> _suggestions = [];
  bool _showSuggestions = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();

  // 🚀 BLAZING FAST optimizations
  late final SearchDebouncer _debouncer = SearchDebouncer();
  final Map<String, List<T>> _searchCache = {};

  @override
  void initState() {
    super.initState();
    _updateControllerText();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(AutocompleteDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateControllerText();
    }
    if (widget.items != oldWidget.items) {
      _filterSuggestions(_controller.text);
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _hideOverlay();
    _searchCache.clear();
    super.dispose();
  }

  void _updateControllerText() {
    final text = widget.value != null
        ? widget.displayTextBuilder(widget.value as T)
        : '';
    if (_controller.text != text) {
      _controller.text = text;
    }
  }

  void _onTextChanged() {
    final query = _controller.text;

    // 🚀 Use adaptive debouncing for blazing fast search
    _debouncer.search(query, _filterSuggestions);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Delay hiding to allow selection
      Timer(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus && mounted) {
          _hideSuggestions();
        }
      });
    } else {
      // Show suggestions when focused and has text
      if (_controller.text.isNotEmpty) {
        _filterSuggestions(_controller.text);
      }
    }
  }

  void _filterSuggestions(String query) {
    if (!mounted || !widget.enabled) return;

    if (query.isEmpty) {
      _hideSuggestions();
      return;
    }

    // Debug: Check if we have items
    if (widget.items.isEmpty) {
      _hideSuggestions();
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filteredItems = widget.items.where((item) {
      if (widget.searchFilter != null) {
        return widget.searchFilter!(item, lowerQuery);
      }
      return widget.displayTextBuilder(item).toLowerCase().contains(lowerQuery);
    }).toList();

    // Sort by relevance
    filteredItems.sort((a, b) {
      final aText = widget.displayTextBuilder(a).toLowerCase();
      final bText = widget.displayTextBuilder(b).toLowerCase();

      // Exact matches first
      final aExact = aText == lowerQuery ? 0 : 1;
      final bExact = bText == lowerQuery ? 0 : 1;
      if (aExact != bExact) return aExact.compareTo(bExact);

      // Starts with matches second
      final aStarts = aText.startsWith(lowerQuery) ? 0 : 1;
      final bStarts = bText.startsWith(lowerQuery) ? 0 : 1;
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);

      return aText.compareTo(bText);
    });

    setState(() {
      _suggestions = filteredItems.take(10).toList(); // Limit to 10 suggestions
      _showSuggestions = _suggestions.isNotEmpty;
    });

    if (_showSuggestions && _focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _hideSuggestions() {
    setState(() {
      _showSuggestions = false;
      _suggestions.clear();
    });
    _hideOverlay();
  }

  void _showOverlay() {
    _hideOverlay(); // Remove existing overlay
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate if dropdown should appear above or below
    final spaceBelow = screenHeight - position.dy - size.height;
    final spaceAbove = position.dy;
    final showAbove = spaceBelow < 200 && spaceAbove > spaceBelow;

    double top;
    if (showAbove) {
      top =
          position.dy -
          (widget.theme.maxHeight ?? 200).clamp(0, spaceAbove - 10);
    } else {
      top = position.dy + size.height + 4;
    }

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent barrier to detect taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _hideSuggestions();
                _focusNode.unfocus();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          // Suggestions dropdown
          Positioned(
            left: position.dx.clamp(0, screenWidth - size.width),
            top: top,
            width: size.width,
            child: Material(
              elevation: widget.theme.elevation ?? 8,
              borderRadius:
                  widget.theme.borderRadius ?? BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: widget.theme.maxHeight ?? 200,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.theme.dropdownBackgroundColor ??
                      Theme.of(context).cardColor,
                  borderRadius:
                      widget.theme.borderRadius ?? BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _suggestions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No matches found'),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                        itemBuilder: (context, index) {
                          final item = _suggestions[index];
                          final isSelected = widget.value == item;

                          return InkWell(
                            onTap: () {
                              _selectSuggestion(item);
                            },
                            child: Container(
                              padding:
                                  widget.theme.padding ??
                                  const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.theme.itemHighlightColor ??
                                          Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.1)
                                    : null,
                              ),
                              child: widget.itemBuilder(item),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectSuggestion(T item) {
    widget.onChanged?.call(item);
    _hideSuggestions();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _textFieldKey,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled && !widget.isLoading,
          decoration:
              widget.theme.inputDecoration ??
              InputDecoration(
                hintText: widget.hint,
                hintStyle: widget.theme.hintStyle,
                border: const OutlineInputBorder(),
                contentPadding:
                    widget.theme.padding ??
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                suffixIcon: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      )
                    : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: widget.theme.iconColor ?? Colors.grey[600],
                        ),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged?.call(null);
                          _hideSuggestions();
                        },
                      )
                    : Icon(
                        Icons.search,
                        color: widget.theme.iconColor ?? Colors.grey[600],
                      ),
              ),
          style:
              widget.theme.itemTextStyle ??
              Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
