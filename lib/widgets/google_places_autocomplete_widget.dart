import 'package:flutter/material.dart';
import 'dart:async';
import '../services/google_places_service.dart';
import '../models/location_result.dart';
import '../themes/location_picker_plus_theme.dart';

class GooglePlacesAutocompleteWidget extends StatefulWidget {
  final Function(LocationResult?)? onLocationSelected;
  final Function(String)? onTextChanged;
  final String? hintText;
  final String? apiKey;
  final LocationPickerTheme? theme;
  final String? initialValue;
  final String? country; // ISO 3166-1 alpha-2 country code
  final List<String> types; // establishment, address, geocode, etc.
  final Widget? suffixIcon;
  final bool enabled;
  final TextEditingController? controller;

  const GooglePlacesAutocompleteWidget({
    super.key,
    this.onLocationSelected,
    this.onTextChanged,
    this.hintText = 'Search for a place...',
    this.apiKey,
    this.theme,
    this.initialValue,
    this.country,
    this.types = const [],
    this.suffixIcon,
    this.enabled = true,
    this.controller,
  });

  @override
  State<GooglePlacesAutocompleteWidget> createState() =>
      _GooglePlacesAutocompleteWidgetState();
}

class _GooglePlacesAutocompleteWidgetState
    extends State<GooglePlacesAutocompleteWidget> {
  late TextEditingController _controller;
  final GooglePlacesService _placesService = GooglePlacesService.instance;
  final FocusNode _focusNode = FocusNode();

  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;
  String? _sessionToken;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  late LocationPickerTheme _theme;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _theme = widget.theme ?? LocationPickerTheme.defaultTheme();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    // Initialize Google Places service if API key is provided
    if (widget.apiKey != null && widget.apiKey!.isNotEmpty) {
      _placesService.initialize(widget.apiKey!);
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    widget.onTextChanged?.call(text);

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (text.trim().isEmpty) {
      setState(() {
        _predictions.clear();
        _errorMessage = null;
      });
      _removeOverlay();
      return;
    }

    // Debounce the search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchPlaces(text);
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (_predictions.isNotEmpty) {
        _showOverlay();
      }
    } else {
      // Delay removal to allow tapping on suggestions
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
      // Generate session token for billing optimization
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
        _removeOverlay();
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 56),
        child: Material(
          elevation: _theme.elevation ?? 4,
          borderRadius: _theme.borderRadius,
          color: _theme.dropdownBackgroundColor ?? Colors.white,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: _theme.maxHeight ?? 300,
              minWidth: 200, // Minimum width
              maxWidth: MediaQuery.of(context).size.width - 32, // Max width with padding
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return InkWell(
                  onTap: () => _onPredictionSelected(prediction),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: index < _predictions.length - 1
                          ? Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 0.5,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (prediction.mainText != null)
                                Text(
                                  prediction.mainText!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (prediction.secondaryText != null)
                                Text(
                                  prediction.secondaryText!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (prediction.mainText == null)
                                Text(
                                  prediction.description,
                                  style: const TextStyle(fontSize: 14),
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
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _onPredictionSelected(PlacePrediction prediction) async {
    _removeOverlay();

    // Update text field
    _controller.text = prediction.description;

    // Remove focus to hide keyboard
    _focusNode.unfocus();

    // Get place details
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locationResult = await _placesService.getPlaceDetails(
        placeId: prediction.placeId,
        sessionToken: _sessionToken,
      );

      // Reset session token after getting details to complete the session
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

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            decoration: (_theme.inputDecoration ?? InputDecoration()).copyWith(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            widget.onLocationSelected?.call(null);
                            _removeOverlay();
                          },
                        )
                      : widget.suffixIcon,
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty && _predictions.isNotEmpty) {
                _onPredictionSelected(_predictions.first);
              }
            },
          ),
          if (_errorMessage != null)
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
  }
}