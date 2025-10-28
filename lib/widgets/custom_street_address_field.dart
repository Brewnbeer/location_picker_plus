import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/google_places_service.dart';
import '../models/location_result.dart';

class AddressFormData {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool isFromGooglePlaces;

  AddressFormData({
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isFromGooglePlaces = false,
  });

  @override
  String toString() {
    return 'AddressFormData(street: $street, city: $city, state: $state, country: $country, postalCode: $postalCode, isFromGooglePlaces: $isFromGooglePlaces)';
  }
}

class CustomStreetAddressField extends StatefulWidget {
  final String? initialStreet;
  final String? initialCity;
  final String? initialState;
  final String? initialCountry;
  final String? initialPostalCode;
  final double? initialLatitude;
  final double? initialLongitude;
  final ValueChanged<AddressFormData>? onAddressChanged;
  final ValueChanged<LocationResult?>? onPlaceSelected;
  final ValueChanged<Position?>? onLocationSelected;
  final String? hintText;
  final String? googleApiKey;
  final bool enableLocationPicker;
  final bool showAllFields;
  final Map<String, String>? fieldErrors;
  final ValueChanged<String>? onFieldErrorCleared;
  final bool isLocked;

  const CustomStreetAddressField({
    super.key,
    this.initialStreet,
    this.initialCity,
    this.initialState,
    this.initialCountry,
    this.initialPostalCode,
    this.initialLatitude,
    this.initialLongitude,
    this.onAddressChanged,
    this.onPlaceSelected,
    this.onLocationSelected,
    this.hintText = 'Search for addresses in India or US...',
    this.googleApiKey,
    this.enableLocationPicker = false,
    this.showAllFields = true,
    this.fieldErrors,
    this.onFieldErrorCleared,
    this.isLocked = false,
  });

  @override
  State<CustomStreetAddressField> createState() =>
      _CustomStreetAddressFieldState();
}

class _CustomStreetAddressFieldState extends State<CustomStreetAddressField> {
  // Controllers for all address fields
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  Timer? _debounceTimer;
  List<PlacePrediction> _googlePredictions = [];
  bool _isLoadingPredictions = false;
  bool _isLoadingLocation = false;
  GooglePlacesService? _placesService;
  bool _isFromGooglePlaces = false;
  bool _isFromGPS = false;

  // Store initial coordinates to preserve them when locked
  double? _lockedLatitude;
  double? _lockedLongitude;

  // Restrict to India and US only
  final String _restrictedCountries = 'in|us';

  @override
  void initState() {
    super.initState();

    // Store initial coordinates if provided (for locked addresses)
    _lockedLatitude = widget.initialLatitude;
    _lockedLongitude = widget.initialLongitude;

    debugPrint('🔒 CustomStreetAddressField initState - Locked coordinates: lat=$_lockedLatitude, lon=$_lockedLongitude, isLocked=${widget.isLocked}');

    // Initialize controllers with initial values
    _updateControllersWithInitialValues();

    // Always initialize Google Places service
    _placesService = GooglePlacesService.instance;
    if (widget.googleApiKey != null) {
      _placesService!.initialize(widget.googleApiKey!);
    }
    streetController.addListener(_onSearchChanged);

    // Listen to manual changes in other fields
    cityController.addListener(_onManualAddressChange);
    stateController.addListener(_onManualAddressChange);
    countryController.addListener(_onManualAddressChange);
    postalCodeController.addListener(_onManualAddressChange);

    // If locked and has initial data, emit it immediately after the frame is built
    if (widget.isLocked && _lockedLatitude != null && _lockedLongitude != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🔒 Emitting initial locked address data with coordinates');
        _emitAddressChange();
      });
    }
  }

  @override
  void didUpdateWidget(CustomStreetAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update locked coordinates if they changed
    if (oldWidget.initialLatitude != widget.initialLatitude ||
        oldWidget.initialLongitude != widget.initialLongitude) {
      _lockedLatitude = widget.initialLatitude;
      _lockedLongitude = widget.initialLongitude;
      debugPrint('🔒 didUpdateWidget - Updated locked coordinates: lat=$_lockedLatitude, lon=$_lockedLongitude');
    }

    // Update controllers if initial values changed
    if (oldWidget.initialStreet != widget.initialStreet ||
        oldWidget.initialCity != widget.initialCity ||
        oldWidget.initialState != widget.initialState ||
        oldWidget.initialCountry != widget.initialCountry ||
        oldWidget.initialPostalCode != widget.initialPostalCode) {
      _updateControllersWithInitialValues();
    }
  }

  void _updateControllersWithInitialValues() {
    // Temporarily remove listeners to prevent emitting address changes during initialization
    streetController.removeListener(_onSearchChanged);
    cityController.removeListener(_onManualAddressChange);
    stateController.removeListener(_onManualAddressChange);
    countryController.removeListener(_onManualAddressChange);
    postalCodeController.removeListener(_onManualAddressChange);

    streetController.text = widget.initialStreet ?? '';
    cityController.text = widget.initialCity ?? '';
    stateController.text = widget.initialState ?? '';
    countryController.text = widget.initialCountry ?? '';
    postalCodeController.text = widget.initialPostalCode ?? '';

    // Re-add listeners after initialization
    streetController.addListener(_onSearchChanged);
    cityController.addListener(_onManualAddressChange);
    stateController.addListener(_onManualAddressChange);
    countryController.addListener(_onManualAddressChange);
    postalCodeController.addListener(_onManualAddressChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    streetController.removeListener(_onSearchChanged);
    cityController.removeListener(_onManualAddressChange);
    stateController.removeListener(_onManualAddressChange);
    countryController.removeListener(_onManualAddressChange);
    postalCodeController.removeListener(_onManualAddressChange);

    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  void _onManualAddressChange() {
    // When user manually types in any field, mark as not from Google Places
    _isFromGooglePlaces = false;
    _emitAddressChange();
  }

  void _onSearchChanged() {
    if (_placesService == null || !_placesService!.isInitialized) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = streetController.text.trim();
      if (query.isNotEmpty && query.length > 2) {
        _searchGooglePlaces(query);
      } else {
        setState(() {
          _googlePredictions.clear();
          _isLoadingPredictions = false;
        });
      }
    });

    // Mark as not from Google Places when manually typing
    _isFromGooglePlaces = false;
  }

  Future<void> _searchGooglePlaces(String query) async {
    if (_placesService == null || !_placesService!.isInitialized) return;

    setState(() {
      _isLoadingPredictions = true;
    });

    try {
      final predictions = await _placesService!.getAutocompletePredictions(
        query: query,
        country: _restrictedCountries,
      );

      if (mounted) {
        setState(() {
          _isLoadingPredictions = false;
          _googlePredictions = predictions;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPredictions = false;
          _googlePredictions.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching places: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _onPlaceSelected(PlacePrediction prediction) async {
    if (_placesService == null || !_placesService!.isInitialized) return;

    try {
      final locationResult = await _placesService!.getPlaceDetails(
        placeId: prediction.placeId,
      );

      if (locationResult != null && mounted) {
        setState(() {
          // Fill all fields from Google Places
          streetController.text = prediction.description;
          cityController.text = locationResult.city ?? '';
          stateController.text = locationResult.state ?? '';
          countryController.text = locationResult.country ?? '';
          postalCodeController.text = locationResult.postalCode ?? '';
          _googlePredictions.clear();
          _isFromGooglePlaces = true;
        });

        // Emit the complete address data
        _emitAddressChange(
          latitude: locationResult.latitude,
          longitude: locationResult.longitude,
        );

        widget.onPlaceSelected?.call(locationResult);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting place details: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _detectCurrentLocation() async {
    if (widget.isLocked) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;

        setState(() {
          // Fill all fields from GPS data
          streetController.text = place.street ?? '';
          cityController.text = place.locality ?? '';
          stateController.text = place.administrativeArea ?? '';
          countryController.text = place.country ?? '';
          postalCodeController.text = place.postalCode ?? '';
          _googlePredictions.clear();
          _isFromGooglePlaces = false;
          _isFromGPS = true;
          _isLoadingLocation = false;
        });

        // Emit the complete address data with coordinates
        _emitAddressChange(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        // Call the location selected callback
        widget.onLocationSelected?.call(position);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location detected successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error detecting location: ${e.toString()}')),
        );
      }
    }
  }

  void _emitAddressChange({double? latitude, double? longitude}) {
    // If the widget is locked, always use the locked coordinates
    // Otherwise use the provided coordinates (from Google Places selection)
    final finalLatitude = widget.isLocked ? _lockedLatitude : latitude;
    final finalLongitude = widget.isLocked ? _lockedLongitude : longitude;

    debugPrint('🔒 _emitAddressChange - isLocked=${widget.isLocked}, input lat=$latitude, lon=$longitude, final lat=$finalLatitude, lon=$finalLongitude');

    final addressData = AddressFormData(
      street: streetController.text.isEmpty ? null : streetController.text,
      city: cityController.text.isEmpty ? null : cityController.text,
      state: stateController.text.isEmpty ? null : stateController.text,
      country: countryController.text.isEmpty ? null : countryController.text,
      postalCode: postalCodeController.text.isEmpty
          ? null
          : postalCodeController.text,
      latitude: finalLatitude,
      longitude: finalLongitude,
      isFromGooglePlaces: _isFromGooglePlaces,
    );

    widget.onAddressChanged?.call(addressData);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool enabled,
    required String fieldKey,
    IconData? prefixIcon,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = widget.fieldErrors?.containsKey(fieldKey) ?? false;

    return TextFormField(
      controller: controller,
      enabled: enabled && !widget.isLocked,
      onChanged: (value) {
        if (hasError) {
          widget.onFieldErrorCleared?.call(fieldKey);
        }
        onChanged?.call(value);
      },
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: enabled ? Theme.of(context).primaryColor : Colors.grey,
              )
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.grey.shade300,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Theme.of(context).primaryColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildWarningText(String fieldKey) {
    if (widget.fieldErrors?.containsKey(fieldKey) != true) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.fieldErrors![fieldKey]!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Street Address Field with Google Places and GPS
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: streetController,
                label: 'Street Address',
                hint: widget.isLocked
                    ? 'Business address (locked)'
                    : widget.hintText ?? 'Type to search addresses in India or US...',
                enabled: !widget.isLocked,
                fieldKey: 'address',
                prefixIcon: Icons.location_on,
                suffixIcon: _isLoadingPredictions
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.grey),
              ),
            ),
            if (widget.enableLocationPicker && !widget.isLocked) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isLoadingLocation ? null : _detectCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                tooltip: 'Detect current location',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
        _buildWarningText('address'),

        // Google Places suggestions (disabled when locked)
        if (_googlePredictions.isNotEmpty && !widget.isLocked)
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _googlePredictions.length,
              itemBuilder: (context, index) {
                final prediction = _googlePredictions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.blue,
                  ),
                  title: Text(
                    prediction.description,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  onTap: () => _onPlaceSelected(prediction),
                );
              },
            ),
          ),

        // Other address fields (shown only if showAllFields is true)
        if (widget.showAllFields) ...[
          const SizedBox(height: 16),

          // City and State Row
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: cityController,
                      label: 'City',
                      hint: 'Enter city',
                      enabled: !_isFromGooglePlaces && !_isFromGPS,
                      fieldKey: 'city',
                      prefixIcon: Icons.location_city,
                    ),
                    _buildWarningText('city'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: stateController,
                      label: 'State',
                      hint: 'Enter state',
                      enabled: !_isFromGooglePlaces && !_isFromGPS,
                      fieldKey: 'state',
                      prefixIcon: Icons.map,
                    ),
                    _buildWarningText('state'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Country and Postal Code Row
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: countryController,
                      label: 'Country',
                      hint: 'Enter country',
                      enabled: !_isFromGooglePlaces && !_isFromGPS,
                      fieldKey: 'country',
                      prefixIcon: Icons.public,
                    ),
                    _buildWarningText('country'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: postalCodeController,
                      label: 'Postal Code',
                      hint: 'Enter postal code',
                      enabled: !_isFromGooglePlaces && !_isFromGPS,
                      fieldKey: 'postalCode',
                      prefixIcon: Icons.markunread_mailbox,
                    ),
                    _buildWarningText('postalCode'),
                  ],
                ),
              ),
            ],
          ),
        ],

        // Lock/Unlock indicator for Google Places, GPS, or Business Address
        if ((_isFromGooglePlaces || _isFromGPS || widget.isLocked) && widget.showAllFields)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isLocked
                  ? Colors.orange.shade50
                  : _isFromGPS
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: widget.isLocked
                    ? Colors.orange.shade200
                    : _isFromGPS
                        ? Colors.green.shade200
                        : Colors.blue.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isLocked
                      ? Icons.lock
                      : _isFromGPS
                          ? Icons.gps_fixed
                          : Icons.lock,
                  size: 16,
                  color: widget.isLocked
                      ? Colors.orange.shade700
                      : _isFromGPS
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isLocked
                        ? 'Address locked to business location. Update from business settings to change.'
                        : _isFromGPS
                            ? 'Address detected from GPS. Clear street address to edit manually.'
                            : 'Address details locked from Google Places. Clear street address to edit manually.',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isLocked
                          ? Colors.orange.shade700
                          : _isFromGPS
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}