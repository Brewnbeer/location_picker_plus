import 'package:flutter/material.dart';
import '../models/location_result.dart';
import '../services/google_places_service.dart';
import '../services/location_detector_service.dart';
import '../themes/location_picker_plus_theme.dart';
import 'google_places_autocomplete_widget.dart';
import 'manual_address_entry_widget.dart';

enum LocationPickerMode {
  googlePlaces,
  currentLocation,
  manualEntry,
  all,
}

class LocationPickerPlusUnifiedWidget extends StatefulWidget {
  final Function(LocationResult?)? onLocationSelected;
  final LocationPickerMode mode;
  final LocationPickerTheme? theme;
  final String? googlePlacesApiKey;
  final String? initialSearchText;
  final LocationResult? initialLocation;

  // Google Places specific
  final String? country; // ISO 3166-1 alpha-2 country code
  final List<String> placesTypes;
  final String placesHintText;

  // Manual entry specific
  final bool useDropdownsForCountryState;
  final String addressLabel;
  final String cityLabel;
  final String stateLabel;
  final String countryLabel;
  final String postalCodeLabel;
  final List<String>? allowedCountries; // ISO country codes or country names
  final bool lockFieldsForGooglePlaces;

  // Current location specific
  final String currentLocationButtonText;
  final bool showCoordinates;
  final bool autoDetectOnInit;

  // UI customization
  final String searchTabLabel;
  final String gpsTabLabel;
  final String manualTabLabel;

  const LocationPickerPlusUnifiedWidget({
    super.key,
    this.onLocationSelected,
    this.mode = LocationPickerMode.all,
    this.theme,
    this.googlePlacesApiKey,
    this.initialSearchText,
    this.initialLocation,

    // Google Places
    this.country,
    this.placesTypes = const [],
    this.placesHintText = 'Search for a place...',

    // Manual entry
    this.useDropdownsForCountryState = true,
    this.addressLabel = 'Address',
    this.cityLabel = 'City',
    this.stateLabel = 'State/Province',
    this.countryLabel = 'Country',
    this.postalCodeLabel = 'Postal Code',
    this.allowedCountries,
    this.lockFieldsForGooglePlaces = true,

    // Current location
    this.currentLocationButtonText = 'Use My Location',
    this.showCoordinates = true,
    this.autoDetectOnInit = false,

    // UI
    this.searchTabLabel = 'Search',
    this.gpsTabLabel = 'GPS',
    this.manualTabLabel = 'Manual',
  });

  @override
  State<LocationPickerPlusUnifiedWidget> createState() => _LocationPickerPlusUnifiedWidgetState();
}

class _LocationPickerPlusUnifiedWidgetState extends State<LocationPickerPlusUnifiedWidget>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  late LocationPickerTheme _theme;
  final LocationDetectorService _locationService = LocationDetectorService.instance;

  LocationResult? _currentLocationResult;
  bool _isLoadingGPS = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? LocationPickerTheme.defaultTheme();

    // Initialize tabs based on mode
    int tabCount = _getTabCount();
    _tabController = TabController(length: tabCount, vsync: this);

    // Initialize Google Places if API key provided
    if (widget.googlePlacesApiKey != null && widget.googlePlacesApiKey!.isNotEmpty) {
      GooglePlacesService.instance.initialize(widget.googlePlacesApiKey!);
    }

    // Auto-detect location if requested
    if (widget.autoDetectOnInit && _shouldShowGPSTab()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _detectCurrentLocation();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTabCount() {
    switch (widget.mode) {
      case LocationPickerMode.googlePlaces:
      case LocationPickerMode.currentLocation:
      case LocationPickerMode.manualEntry:
        return 1;
      case LocationPickerMode.all:
        return 3;
    }
  }

  bool _shouldShowGooglePlacesTab() {
    return widget.mode == LocationPickerMode.googlePlaces || widget.mode == LocationPickerMode.all;
  }

  bool _shouldShowGPSTab() {
    return widget.mode == LocationPickerMode.currentLocation || widget.mode == LocationPickerMode.all;
  }

  bool _shouldShowManualTab() {
    return widget.mode == LocationPickerMode.manualEntry || widget.mode == LocationPickerMode.all;
  }

  List<Tab> _buildTabs() {
    List<Tab> tabs = [];

    if (_shouldShowGooglePlacesTab()) {
      tabs.add(Tab(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(widget.searchTabLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ));
    }

    if (_shouldShowGPSTab()) {
      tabs.add(Tab(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.my_location, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(widget.gpsTabLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ));
    }

    if (_shouldShowManualTab()) {
      tabs.add(Tab(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_location_alt, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(widget.manualTabLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ));
    }

    return tabs;
  }

  List<Widget> _buildTabViews() {
    List<Widget> views = [];

    if (_shouldShowGooglePlacesTab()) {
      views.add(_buildGooglePlacesView());
    }

    if (_shouldShowGPSTab()) {
      views.add(_buildGPSView());
    }

    if (_shouldShowManualTab()) {
      views.add(_buildManualEntryView());
    }

    return views;
  }

  Widget _buildGooglePlacesView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Places',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find any location using Google Places',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Search Input
            GooglePlacesAutocompleteWidget(
              apiKey: widget.googlePlacesApiKey,
              hintText: widget.placesHintText,
              initialValue: widget.initialSearchText,
              country: widget.country,
              types: widget.placesTypes,
              theme: _theme,
              onLocationSelected: (locationResult) {
                setState(() {
                  _currentLocationResult = locationResult;
                });
                widget.onLocationSelected?.call(locationResult);
              },
            ),

            const SizedBox(height: 24),

            if (_currentLocationResult != null) _buildModernLocationDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get your precise GPS location',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // GPS Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoadingGPS ? null : _detectCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isLoadingGPS ? 0 : 2,
                ),
                icon: _isLoadingGPS
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.my_location, size: 20),
                label: Text(
                  _isLoadingGPS ? 'Detecting Location...' : widget.currentLocationButtonText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_errorMessage != null) _buildModernErrorMessage(),
            if (_currentLocationResult != null && _errorMessage == null) _buildModernLocationDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntryView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.orange.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_location_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manual Entry',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter address details manually',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Manual Entry Form
            ManualAddressEntryWidget(
              theme: _theme,
              initialLocation: _currentLocationResult ?? widget.initialLocation,
              useDropdownsForCountryState: widget.useDropdownsForCountryState,
              addressLabel: widget.addressLabel,
              cityLabel: widget.cityLabel,
              stateLabel: widget.stateLabel,
              countryLabel: widget.countryLabel,
              postalCodeLabel: widget.postalCodeLabel,
              allowedCountries: widget.allowedCountries,
              lockFieldsForGooglePlaces: widget.lockFieldsForGooglePlaces,
              onLocationChanged: (locationResult) {
                setState(() {
                  _currentLocationResult = locationResult;
                });
                widget.onLocationSelected?.call(locationResult);
              },
            ),

            const SizedBox(height: 24),

            if (_currentLocationResult != null) _buildModernLocationDisplay(),
          ],
        ),
      ),
    );
  }

  Future<void> _detectCurrentLocation() async {
    setState(() {
      _isLoadingGPS = true;
      _errorMessage = null;
    });

    try {
      final locationModel = await _locationService.getCurrentLocationWithAddress();

      if (locationModel != null && mounted) {
        final locationResult = LocationResult.fromLocationModel(locationModel);

        setState(() {
          _currentLocationResult = locationResult;
          _isLoadingGPS = false;
        });

        widget.onLocationSelected?.call(locationResult);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingGPS = false;
        });
      }
    }
  }



  Widget _buildModernLocationDisplay() {
    if (_currentLocationResult == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.08),
            Colors.blue.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      'Location details',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Selected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Address
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _currentLocationResult!.address,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          if (_currentLocationResult!.city != null ||
              _currentLocationResult!.state != null ||
              _currentLocationResult!.country != null ||
              _currentLocationResult!.postalCode != null) ...[
            const SizedBox(height: 12),

            // Details Grid
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  if (_currentLocationResult!.city != null)
                    _buildModernInfoRow('City', _currentLocationResult!.city!, Icons.location_city),
                  if (_currentLocationResult!.state != null)
                    _buildModernInfoRow('State', _currentLocationResult!.state!, Icons.map),
                  if (_currentLocationResult!.country != null)
                    _buildModernInfoRow('Country', _currentLocationResult!.country!, Icons.public),
                  if (_currentLocationResult!.postalCode != null)
                    _buildModernInfoRow('Postal Code', _currentLocationResult!.postalCode!, Icons.mail),
                ],
              ),
            ),
          ],

          if (widget.showCoordinates) ...[
            const SizedBox(height: 12),

            // Coordinates
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCoordinateChip(
                      'Latitude',
                      _currentLocationResult!.latitude.toStringAsFixed(6),
                      Icons.explore,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCoordinateChip(
                      'Longitude',
                      _currentLocationResult!.longitude.toStringAsFixed(6),
                      Icons.explore,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Single mode without tabs
    if (widget.mode != LocationPickerMode.all) {
      Widget content;

      if (widget.mode == LocationPickerMode.googlePlaces) {
        content = _buildGooglePlacesView();
      } else if (widget.mode == LocationPickerMode.currentLocation) {
        content = _buildGPSView();
      } else {
        content = _buildManualEntryView();
      }

      return content;
    }

    // Multi-mode with tabs
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: _buildTabs(),
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _buildTabViews(),
          ),
        ),
      ],
    );
  }
}