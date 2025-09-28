import 'dart:async';

import 'package:flutter/material.dart';

import '../models/location_result.dart';
import '../services/google_places_service.dart';

/// Enhanced Google Places widget with comprehensive customization options
/// Provides maximum flexibility for styling and behavior customization
class EnhancedGooglePlacesWidget extends StatefulWidget {
  // Core functionality
  final Function(LocationResult?)? onLocationSelected;
  final Function(String)? onTextChanged;
  final Function(List<PlacePrediction>)? onSuggestionsChanged;
  final String? apiKey;
  final String? initialValue;
  final String? country;
  final List<String> types;
  final bool enabled;
  final TextEditingController? controller;

  // Input field customization
  final InputDecoration? inputDecoration;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? loadingWidget;
  final Widget? clearIcon;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final Border? border;
  final Border? focusedBorder;
  final Border? errorBorder;
  final Color? fillColor;
  final bool? filled;
  final double? borderWidth;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;

  // Dropdown/Suggestions customization
  final double? suggestionHeight;
  final double? maxSuggestionHeight;
  final BorderRadius? suggestionBorderRadius;
  final Color? suggestionBackgroundColor;
  final Color? suggestionHoverColor;
  final Color? suggestionSelectedColor;
  final double? suggestionElevation;
  final EdgeInsetsGeometry? suggestionPadding;
  final TextStyle? suggestionTextStyle;
  final TextStyle? suggestionSubtextStyle;
  final Widget Function(PlacePrediction)? customSuggestionBuilder;
  final Widget? noResultsWidget;
  final Widget? errorWidget;
  final Offset? suggestionOffset;
  final double? suggestionSpacing;

  // Icons customization
  final Widget? locationIcon;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? iconPadding;

  // Animation and interaction
  final Duration? debounceDelay;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final bool showAnimations;
  final bool autoFocus;
  final bool showClearButton;
  final bool showLoadingIndicator;

  // Layout and positioning
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;

  // Error handling
  final String? Function(String?)? validator;
  final Widget Function(String)? errorBuilder;
  final bool showInlineErrors;

  // Accessibility
  final String? semanticsLabel;
  final String? semanticsHint;

  const EnhancedGooglePlacesWidget({
    super.key,
    // Core
    this.onLocationSelected,
    this.onTextChanged,
    this.onSuggestionsChanged,
    this.apiKey,
    this.initialValue,
    this.country,
    this.types = const [],
    this.enabled = true,
    this.controller,

    // Input customization
    this.inputDecoration,
    this.textStyle,
    this.hintStyle,
    this.hintText = 'Search for a place...',
    this.prefixIcon,
    this.suffixIcon,
    this.loadingWidget,
    this.clearIcon,
    this.contentPadding,
    this.borderRadius,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.fillColor,
    this.filled,
    this.borderWidth,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,

    // Suggestions customization
    this.suggestionHeight,
    this.maxSuggestionHeight = 300,
    this.suggestionBorderRadius,
    this.suggestionBackgroundColor,
    this.suggestionHoverColor,
    this.suggestionSelectedColor,
    this.suggestionElevation = 4,
    this.suggestionPadding,
    this.suggestionTextStyle,
    this.suggestionSubtextStyle,
    this.customSuggestionBuilder,
    this.noResultsWidget,
    this.errorWidget,
    this.suggestionOffset,
    this.suggestionSpacing = 4,

    // Icons
    this.locationIcon,
    this.iconSize = 20,
    this.iconColor,
    this.iconPadding,

    // Animation
    this.debounceDelay = const Duration(milliseconds: 300),
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.showAnimations = true,
    this.autoFocus = false,
    this.showClearButton = true,
    this.showLoadingIndicator = true,

    // Layout
    this.width,
    this.height,
    this.margin,
    this.alignment,

    // Error handling
    this.validator,
    this.errorBuilder,
    this.showInlineErrors = true,

    // Accessibility
    this.semanticsLabel,
    this.semanticsHint,
  });

  @override
  State<EnhancedGooglePlacesWidget> createState() =>
      _EnhancedGooglePlacesWidgetState();
}

class _EnhancedGooglePlacesWidgetState extends State<EnhancedGooglePlacesWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  final GooglePlacesService _placesService = GooglePlacesService.instance;
  final FocusNode _focusNode = FocusNode();

  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _validationError;
  Timer? _debounceTimer;
  String? _sessionToken;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    // Initialize animations
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve ?? Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<double>(begin: -10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve ?? Curves.easeInOut,
      ),
    );

    // Initialize Google Places service
    if (widget.apiKey != null && widget.apiKey!.isNotEmpty) {
      _placesService.initialize(widget.apiKey!);
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _animationController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    widget.onTextChanged?.call(text);

    // Validate input
    if (widget.validator != null) {
      setState(() {
        _validationError = widget.validator!(text);
      });
    }

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (text.trim().isEmpty) {
      setState(() {
        _predictions.clear();
        _errorMessage = null;
      });
      _removeOverlay();
      widget.onSuggestionsChanged?.call([]);
      return;
    }

    // Debounce the search
    _debounceTimer = Timer(
      widget.debounceDelay ?? const Duration(milliseconds: 300),
      () {
        _searchPlaces(text);
      },
    );
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (_predictions.isNotEmpty) {
        _showOverlay();
      }
    } else {
      Timer(const Duration(milliseconds: 150), () {
        _removeOverlay();
      });
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (!_placesService.isInitialized) {
      setState(() {
        _errorMessage = 'Google Places API key not configured';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _sessionToken ??= _placesService.generateSessionToken();

      final predictions = await _placesService.getAutocompletePredictions(
        query: query,
        sessionToken: _sessionToken,
        country: widget.country,
        types: widget.types,
      );

      if (mounted) {
        setState(() {
          _predictions = predictions;
          _isLoading = false;
        });

        widget.onSuggestionsChanged?.call(predictions);

        if (predictions.isNotEmpty && _focusNode.hasFocus) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _predictions.clear();
        });
        widget.onSuggestionsChanged?.call([]);
        _removeOverlay();
      }
    }
  }

  void _showOverlay() {
    if (!widget.showAnimations) {
      _showOverlayInternal();
      return;
    }

    _removeOverlay();
    _showOverlayInternal();
    _animationController.forward();
  }

  void _showOverlayInternal() {
    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset =
        widget.suggestionOffset ??
        Offset(0, size.height + (widget.suggestionSpacing ?? 4));

    _overlayEntry = OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: offset,
        child: Material(
          elevation: widget.suggestionElevation ?? 4,
          borderRadius:
              widget.suggestionBorderRadius ?? BorderRadius.circular(8),
          color:
              widget.suggestionBackgroundColor ?? Theme.of(context).cardColor,
          child: widget.showAnimations
              ? AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: _buildSuggestionsList(size.width),
                    ),
                  ),
                )
              : _buildSuggestionsList(size.width),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildSuggestionsList(double width) {
    if (_predictions.isEmpty) {
      return widget.noResultsWidget ??
          Container(
            width: width,
            padding: const EdgeInsets.all(16),
            child: Text(
              'No results found',
              style:
                  widget.suggestionSubtextStyle ??
                  TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          );
    }

    return Container(
      width: width,
      constraints: BoxConstraints(maxHeight: widget.maxSuggestionHeight ?? 300),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _predictions.length,
        itemBuilder: (context, index) {
          final prediction = _predictions[index];

          if (widget.customSuggestionBuilder != null) {
            return InkWell(
              onTap: () => _onPredictionSelected(prediction),
              child: widget.customSuggestionBuilder!(prediction),
            );
          }

          return _buildDefaultSuggestionItem(prediction, index);
        },
      ),
    );
  }

  Widget _buildDefaultSuggestionItem(PlacePrediction prediction, int index) {
    return InkWell(
      onTap: () => _onPredictionSelected(prediction),
      onHover: (hovering) {
        // Add hover effect if needed
      },
      child: Container(
        height: widget.suggestionHeight,
        padding:
            widget.suggestionPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.suggestionSelectedColor,
          border: index < _predictions.length - 1
              ? Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                )
              : null,
        ),
        child: Row(
          children: [
            Padding(
              padding: widget.iconPadding ?? const EdgeInsets.only(right: 12),
              child:
                  widget.locationIcon ??
                  Icon(
                    Icons.location_on,
                    size: widget.iconSize,
                    color: widget.iconColor ?? Colors.grey[600],
                  ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prediction.mainText != null)
                    Text(
                      prediction.mainText!,
                      style:
                          widget.suggestionTextStyle ??
                          const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (prediction.secondaryText != null)
                    Text(
                      prediction.secondaryText!,
                      style:
                          widget.suggestionSubtextStyle ??
                          TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (prediction.mainText == null)
                    Text(
                      prediction.description,
                      style:
                          widget.suggestionTextStyle ??
                          const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      if (widget.showAnimations) {
        _animationController.reverse().then((_) {
          _overlayEntry?.remove();
          _overlayEntry = null;
        });
      } else {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    }
  }

  Future<void> _onPredictionSelected(PlacePrediction prediction) async {
    _removeOverlay();
    _controller.text = prediction.description;
    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locationResult = await _placesService.getPlaceDetails(
        placeId: prediction.placeId,
        sessionToken: _sessionToken,
      );

      _sessionToken = null;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        widget.onLocationSelected?.call(locationResult);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });

        widget.onLocationSelected?.call(null);
      }
    }
  }

  Widget _buildSuffixIcon() {
    if (_isLoading && widget.showLoadingIndicator) {
      return widget.loadingWidget ??
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    }

    if (_controller.text.isNotEmpty && widget.showClearButton) {
      return widget.clearIcon ??
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              widget.onLocationSelected?.call(null);
              _removeOverlay();
            },
          );
    }

    return widget.suffixIcon ?? const SizedBox.shrink();
  }

  InputDecoration _buildInputDecoration() {
    final baseDecoration = widget.inputDecoration ?? InputDecoration();

    return baseDecoration.copyWith(
      hintText: widget.hintText,
      hintStyle: widget.hintStyle,
      prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
      suffixIcon: _buildSuffixIcon(),
      contentPadding: widget.contentPadding,
      filled: widget.filled,
      fillColor: widget.fillColor,
      border: widget.border != null
          ? OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.borderColor ?? Colors.grey,
                width: widget.borderWidth ?? 1,
              ),
            )
          : null,
      focusedBorder: widget.focusedBorder != null
          ? OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    widget.focusedBorderColor ?? Theme.of(context).primaryColor,
                width: widget.borderWidth ?? 1,
              ),
            )
          : null,
      errorBorder: widget.errorBorder != null
          ? OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    widget.errorBorderColor ??
                    Theme.of(context).colorScheme.error,
                width: widget.borderWidth ?? 1,
              ),
            )
          : null,
      errorText: widget.showInlineErrors ? _validationError : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            key: _textFieldKey,
            width: widget.width,
            height: widget.height,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              style: widget.textStyle,
              decoration: _buildInputDecoration(),
              onSubmitted: (value) {
                if (value.isNotEmpty && _predictions.isNotEmpty) {
                  _onPredictionSelected(_predictions.first);
                }
              },
            ),
          ),

          // Custom error display
          if (_errorMessage != null && widget.errorBuilder != null)
            widget.errorBuilder!(_errorMessage!),

          if (_errorMessage != null &&
              widget.errorBuilder == null &&
              widget.showInlineErrors)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );

    // Apply container styling
    if (widget.margin != null || widget.alignment != null) {
      child = Container(
        margin: widget.margin,
        alignment: widget.alignment,
        child: child,
      );
    }

    // Add semantics for accessibility
    if (widget.semanticsLabel != null || widget.semanticsHint != null) {
      child = Semantics(
        label: widget.semanticsLabel,
        hint: widget.semanticsHint,
        child: child,
      );
    }

    return child;
  }
}
