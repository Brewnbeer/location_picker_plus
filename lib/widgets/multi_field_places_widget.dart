import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location_result.dart';
import '../services/google_places_service.dart';
import '../themes/location_picker_plus_theme.dart';

/// A multi-field address widget that provides Google Places recommendations
/// for each address component while allowing manual entry
class MultiFieldPlacesWidget extends StatefulWidget {
  final String? apiKey;
  final String? country;
  final List<String> types;
  final LocationPickerTheme? theme;

  // Callbacks
  final Function(AddressComponents?)? onAddressChanged;
  final Function(LocationResult?)? onPlaceSelected;

  // Initial values
  final String? initialStreet;
  final String? initialCity;
  final String? initialState;
  final String? initialCountry;
  final String? initialPostalCode;

  // Labels and hints
  final String streetLabel;
  final String cityLabel;
  final String stateLabel;
  final String countryLabel;
  final String postalCodeLabel;

  final String streetHint;
  final String cityHint;
  final String stateHint;
  final String countryHint;
  final String postalCodeHint;

  // Configuration
  final bool showStreetField;
  final bool showCityField;
  final bool showStateField;
  final bool showCountryField;
  final bool showPostalCodeField;
  final bool enableSuggestions;

  const MultiFieldPlacesWidget({
    super.key,
    this.apiKey,
    this.country,
    this.types = const [],
    this.theme,
    this.onAddressChanged,
    this.onPlaceSelected,
    this.initialStreet,
    this.initialCity,
    this.initialState,
    this.initialCountry,
    this.initialPostalCode,
    this.streetLabel = 'Street Address',
    this.cityLabel = 'City',
    this.stateLabel = 'State/Province',
    this.countryLabel = 'Country',
    this.postalCodeLabel = 'Postal Code',
    this.streetHint = 'Enter street address...',
    this.cityHint = 'Enter city...',
    this.stateHint = 'Enter state or province...',
    this.countryHint = 'Enter country...',
    this.postalCodeHint = 'Enter postal code...',
    this.showStreetField = true,
    this.showCityField = true,
    this.showStateField = true,
    this.showCountryField = true,
    this.showPostalCodeField = true,
    this.enableSuggestions = true,
  });

  @override
  State<MultiFieldPlacesWidget> createState() => _MultiFieldPlacesWidgetState();
}

class _MultiFieldPlacesWidgetState extends State<MultiFieldPlacesWidget> {
  late LocationPickerTheme _theme;
  final GooglePlacesService _placesService = GooglePlacesService.instance;

  // Controllers for each field
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;

  // Focus nodes for each field
  final FocusNode _streetFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _stateFocusNode = FocusNode();
  final FocusNode _countryFocusNode = FocusNode();
  final FocusNode _postalCodeFocusNode = FocusNode();

  // Suggestions for each field
  List<PlacePrediction> _streetSuggestions = [];
  List<PlacePrediction> _citySuggestions = [];
  List<PlacePrediction> _stateSuggestions = [];
  List<PlacePrediction> _countrySuggestions = [];

  // Loading states
  bool _isLoadingStreet = false;
  bool _isLoadingCity = false;
  bool _isLoadingState = false;
  bool _isLoadingCountry = false;

  // Timers for debouncing
  Timer? _streetDebounceTimer;
  Timer? _cityDebounceTimer;
  Timer? _stateDebounceTimer;
  Timer? _countryDebounceTimer;

  // Overlay entries for suggestions
  OverlayEntry? _streetOverlay;
  OverlayEntry? _cityOverlay;
  OverlayEntry? _stateOverlay;
  OverlayEntry? _countryOverlay;

  // Layer links for positioning
  final LayerLink _streetLayerLink = LayerLink();
  final LayerLink _cityLayerLink = LayerLink();
  final LayerLink _stateLayerLink = LayerLink();
  final LayerLink _countryLayerLink = LayerLink();

  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? LocationPickerTheme.defaultTheme();

    // Initialize controllers with initial values
    _streetController = TextEditingController(text: widget.initialStreet ?? '');
    _cityController = TextEditingController(text: widget.initialCity ?? '');
    _stateController = TextEditingController(text: widget.initialState ?? '');
    _countryController = TextEditingController(text: widget.initialCountry ?? '');
    _postalCodeController = TextEditingController(text: widget.initialPostalCode ?? '');

    // Initialize Google Places service
    if (widget.apiKey != null && widget.apiKey!.isNotEmpty) {
      _placesService.initialize(widget.apiKey!);
    }

    // Add listeners
    _streetController.addListener(() => _onTextChanged(_streetController.text, FieldType.street));
    _cityController.addListener(() => _onTextChanged(_cityController.text, FieldType.city));
    _stateController.addListener(() => _onTextChanged(_stateController.text, FieldType.state));
    _countryController.addListener(() => _onTextChanged(_countryController.text, FieldType.country));
    _postalCodeController.addListener(_notifyAddressChanged);

    // Add focus listeners
    _streetFocusNode.addListener(() => _onFocusChanged(FieldType.street));
    _cityFocusNode.addListener(() => _onFocusChanged(FieldType.city));
    _stateFocusNode.addListener(() => _onFocusChanged(FieldType.state));
    _countryFocusNode.addListener(() => _onFocusChanged(FieldType.country));
  }

  @override
  void dispose() {
    _streetDebounceTimer?.cancel();
    _cityDebounceTimer?.cancel();
    _stateDebounceTimer?.cancel();
    _countryDebounceTimer?.cancel();

    _removeAllOverlays();

    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();

    _streetFocusNode.dispose();
    _cityFocusNode.dispose();
    _stateFocusNode.dispose();
    _countryFocusNode.dispose();
    _postalCodeFocusNode.dispose();

    super.dispose();
  }

  void _onTextChanged(String text, FieldType fieldType) {
    _notifyAddressChanged();

    if (!widget.enableSuggestions || text.trim().isEmpty) {
      _clearSuggestions(fieldType);
      return;
    }

    // Cancel previous timer
    Timer? timer = _getDebounceTimer(fieldType);
    timer?.cancel();

    // Set new timer
    timer = Timer(const Duration(milliseconds: 300), () {
      _searchPlaces(text, fieldType);
    });
    _setDebounceTimer(fieldType, timer);
  }

  void _onFocusChanged(FieldType fieldType) {
    final focusNode = _getFocusNode(fieldType);
    final suggestions = _getSuggestions(fieldType);

    if (focusNode.hasFocus && suggestions.isNotEmpty) {
      _showOverlay(fieldType);
    } else {
      Timer(const Duration(milliseconds: 150), () {
        _removeOverlay(fieldType);
      });
    }
  }

  Future<void> _searchPlaces(String query, FieldType fieldType) async {
    if (!_placesService.isInitialized) return;

    _setLoadingState(fieldType, true);

    try {
      _sessionToken ??= _placesService.generateSessionToken();

      // Use different search types based on field
      List<String> searchTypes = [];
      switch (fieldType) {
        case FieldType.street:
          searchTypes = ['address'];
          break;
        case FieldType.city:
          searchTypes = ['(cities)'];
          break;
        case FieldType.state:
          searchTypes = ['administrative_area_level_1'];
          break;
        case FieldType.country:
          searchTypes = ['country'];
          break;
      }

      final predictions = await _placesService.getAutocompletePredictions(
        query: query,
        sessionToken: _sessionToken,
        country: widget.country,
        types: searchTypes.isNotEmpty ? searchTypes : widget.types,
      );

      if (mounted) {
        _setSuggestions(fieldType, predictions);
        _setLoadingState(fieldType, false);

        final focusNode = _getFocusNode(fieldType);
        if (predictions.isNotEmpty && focusNode.hasFocus) {
          _showOverlay(fieldType);
        } else {
          _removeOverlay(fieldType);
        }
      }
    } catch (e) {
      if (mounted) {
        _clearSuggestions(fieldType);
        _setLoadingState(fieldType, false);
      }
    }
  }

  void _showOverlay(FieldType fieldType) {
    _removeOverlay(fieldType);

    final layerLink = _getLayerLink(fieldType);
    final suggestions = _getSuggestions(fieldType);

    if (suggestions.isEmpty) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 56),
        child: Material(
          elevation: _theme.elevation ?? 4,
          borderRadius: _theme.borderRadius,
          color: _theme.dropdownBackgroundColor ?? Colors.white,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: _theme.maxHeight ?? 200,
              minWidth: 200,
              maxWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) => _buildSuggestionItem(
                suggestions[index],
                fieldType,
                index,
                suggestions.length,
              ),
            ),
          ),
        ),
      ),
    );

    _setOverlayEntry(fieldType, overlayEntry);
    Overlay.of(context).insert(overlayEntry);
  }

  Widget _buildSuggestionItem(PlacePrediction prediction, FieldType fieldType, int index, int total) {
    return InkWell(
      onTap: () => _onSuggestionSelected(prediction, fieldType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: index < total - 1
              ? Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prediction.mainText != null)
                    Text(
                      prediction.mainText!,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (prediction.secondaryText != null)
                    Text(
                      prediction.secondaryText!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
  }

  Future<void> _onSuggestionSelected(PlacePrediction prediction, FieldType fieldType) async {
    _removeOverlay(fieldType);

    final controller = _getController(fieldType);
    final focusNode = _getFocusNode(fieldType);

    controller.text = _extractRelevantText(prediction, fieldType);
    focusNode.unfocus();

    try {
      final locationResult = await _placesService.getPlaceDetails(
        placeId: prediction.placeId,
        sessionToken: _sessionToken,
      );

      if (locationResult != null) {
        // Auto-fill other fields if they're empty
        _autoFillFields(locationResult);
        widget.onPlaceSelected?.call(locationResult);
      }

      _sessionToken = null;
    } catch (e) {
      // Handle error silently or show user feedback
    }

    _notifyAddressChanged();
  }

  String _extractRelevantText(PlacePrediction prediction, FieldType fieldType) {
    switch (fieldType) {
      case FieldType.street:
        return prediction.mainText ?? prediction.description;
      case FieldType.city:
        return prediction.mainText ?? prediction.description.split(',').first.trim();
      case FieldType.state:
        return prediction.mainText ?? prediction.description.split(',').first.trim();
      case FieldType.country:
        return prediction.mainText ?? prediction.description.split(',').first.trim();
    }
  }

  void _autoFillFields(LocationResult locationResult) {
    if (_cityController.text.isEmpty && locationResult.city != null) {
      _cityController.text = locationResult.city!;
    }
    if (_stateController.text.isEmpty && locationResult.state != null) {
      _stateController.text = locationResult.state!;
    }
    if (_countryController.text.isEmpty && locationResult.country != null) {
      _countryController.text = locationResult.country!;
    }
    if (_postalCodeController.text.isEmpty && locationResult.postalCode != null) {
      _postalCodeController.text = locationResult.postalCode!;
    }
  }

  void _notifyAddressChanged() {
    final addressComponents = AddressComponents(
      street: _streetController.text.trim().isNotEmpty ? _streetController.text : null,
      city: _cityController.text.trim().isNotEmpty ? _cityController.text : null,
      state: _stateController.text.trim().isNotEmpty ? _stateController.text : null,
      country: _countryController.text.trim().isNotEmpty ? _countryController.text : null,
      postalCode: _postalCodeController.text.trim().isNotEmpty ? _postalCodeController.text : null,
    );
    widget.onAddressChanged?.call(addressComponents);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required LayerLink layerLink,
    required String label,
    required String hint,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _theme.labelStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: layerLink,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: (_theme.inputDecoration ?? InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            )).copyWith(
              hintText: hint,
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        _notifyAddressChanged();
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showStreetField) ...[
          _buildTextField(
            controller: _streetController,
            focusNode: _streetFocusNode,
            layerLink: _streetLayerLink,
            label: widget.streetLabel,
            hint: widget.streetHint,
            isLoading: _isLoadingStreet,
          ),
          const SizedBox(height: 16),
        ],

        Row(
          children: [
            if (widget.showCityField) ...[
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  focusNode: _cityFocusNode,
                  layerLink: _cityLayerLink,
                  label: widget.cityLabel,
                  hint: widget.cityHint,
                  isLoading: _isLoadingCity,
                ),
              ),
              if (widget.showStateField) const SizedBox(width: 16),
            ],

            if (widget.showStateField) ...[
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  focusNode: _stateFocusNode,
                  layerLink: _stateLayerLink,
                  label: widget.stateLabel,
                  hint: widget.stateHint,
                  isLoading: _isLoadingState,
                ),
              ),
            ],
          ],
        ),

        if (widget.showCityField || widget.showStateField) const SizedBox(height: 16),

        Row(
          children: [
            if (widget.showCountryField) ...[
              Expanded(
                child: _buildTextField(
                  controller: _countryController,
                  focusNode: _countryFocusNode,
                  layerLink: _countryLayerLink,
                  label: widget.countryLabel,
                  hint: widget.countryHint,
                  isLoading: _isLoadingCountry,
                ),
              ),
              if (widget.showPostalCodeField) const SizedBox(width: 16),
            ],

            if (widget.showPostalCodeField) ...[
              Expanded(
                child: _buildTextField(
                  controller: _postalCodeController,
                  focusNode: _postalCodeFocusNode,
                  layerLink: _streetLayerLink, // Reuse layerlink as postal code doesn't need suggestions
                  label: widget.postalCodeLabel,
                  hint: widget.postalCodeHint,
                  isLoading: false,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Helper methods for managing state by field type
  Timer? _getDebounceTimer(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.street: return _streetDebounceTimer;
      case FieldType.city: return _cityDebounceTimer;
      case FieldType.state: return _stateDebounceTimer;
      case FieldType.country: return _countryDebounceTimer;
    }
  }

  void _setDebounceTimer(FieldType fieldType, Timer timer) {
    switch (fieldType) {
      case FieldType.street: _streetDebounceTimer = timer; break;
      case FieldType.city: _cityDebounceTimer = timer; break;
      case FieldType.state: _stateDebounceTimer = timer; break;
      case FieldType.country: _countryDebounceTimer = timer; break;
    }
  }

  List<PlacePrediction> _getSuggestions(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.street: return _streetSuggestions;
      case FieldType.city: return _citySuggestions;
      case FieldType.state: return _stateSuggestions;
      case FieldType.country: return _countrySuggestions;
    }
  }

  void _setSuggestions(FieldType fieldType, List<PlacePrediction> suggestions) {
    setState(() {
      switch (fieldType) {
        case FieldType.street: _streetSuggestions = suggestions; break;
        case FieldType.city: _citySuggestions = suggestions; break;
        case FieldType.state: _stateSuggestions = suggestions; break;
        case FieldType.country: _countrySuggestions = suggestions; break;
      }
    });
  }

  void _clearSuggestions(FieldType fieldType) {
    setState(() {
      switch (fieldType) {
        case FieldType.street: _streetSuggestions.clear(); break;
        case FieldType.city: _citySuggestions.clear(); break;
        case FieldType.state: _stateSuggestions.clear(); break;
        case FieldType.country: _countrySuggestions.clear(); break;
      }
    });
    _removeOverlay(fieldType);
  }

  void _setLoadingState(FieldType fieldType, bool loading) {
    setState(() {
      switch (fieldType) {
        case FieldType.street: _isLoadingStreet = loading; break;
        case FieldType.city: _isLoadingCity = loading; break;
        case FieldType.state: _isLoadingState = loading; break;
        case FieldType.country: _isLoadingCountry = loading; break;
      }
    });
  }

  TextEditingController _getController(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.street: return _streetController;
      case FieldType.city: return _cityController;
      case FieldType.state: return _stateController;
      case FieldType.country: return _countryController;
    }
  }

  FocusNode _getFocusNode(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.street: return _streetFocusNode;
      case FieldType.city: return _cityFocusNode;
      case FieldType.state: return _stateFocusNode;
      case FieldType.country: return _countryFocusNode;
    }
  }

  LayerLink _getLayerLink(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.street: return _streetLayerLink;
      case FieldType.city: return _cityLayerLink;
      case FieldType.state: return _stateLayerLink;
      case FieldType.country: return _countryLayerLink;
    }
  }

  void _setOverlayEntry(FieldType fieldType, OverlayEntry entry) {
    switch (fieldType) {
      case FieldType.street: _streetOverlay = entry; break;
      case FieldType.city: _cityOverlay = entry; break;
      case FieldType.state: _stateOverlay = entry; break;
      case FieldType.country: _countryOverlay = entry; break;
    }
  }

  void _removeOverlay(FieldType fieldType) {
    OverlayEntry? overlay;
    switch (fieldType) {
      case FieldType.street:
        overlay = _streetOverlay;
        _streetOverlay = null;
        break;
      case FieldType.city:
        overlay = _cityOverlay;
        _cityOverlay = null;
        break;
      case FieldType.state:
        overlay = _stateOverlay;
        _stateOverlay = null;
        break;
      case FieldType.country:
        overlay = _countryOverlay;
        _countryOverlay = null;
        break;
    }
    overlay?.remove();
  }

  void _removeAllOverlays() {
    _streetOverlay?.remove();
    _cityOverlay?.remove();
    _stateOverlay?.remove();
    _countryOverlay?.remove();
  }
}

enum FieldType { street, city, state, country }

/// Data class for holding address components
class AddressComponents {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  const AddressComponents({
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  @override
  String toString() {
    final parts = <String>[];
    if (street != null) parts.add(street!);
    if (city != null) parts.add(city!);
    if (state != null) parts.add(state!);
    if (country != null) parts.add(country!);
    if (postalCode != null) parts.add(postalCode!);
    return parts.join(', ');
  }
}