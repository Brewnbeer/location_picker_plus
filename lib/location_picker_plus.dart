import 'package:flutter/material.dart';
import 'location_picker_plus_platform_interface.dart';

// Export existing models and services
export 'models/city_model.dart';
export 'models/country_model.dart';
export 'models/state_model.dart';
export 'models/location_model.dart';
export 'services/location_service.dart';
export 'services/location_detector_service.dart';
export 'themes/location_picker_plus_theme.dart';
export 'widgets/autocomplete_dropdown.dart';
export 'widgets/location_picker_plus_widget.dart';
export 'widgets/location_detector_widget.dart';

// Export new unified components
export 'models/location_result.dart';
export 'services/google_places_service.dart';
export 'widgets/google_places_autocomplete_widget.dart';
export 'widgets/manual_address_entry_widget.dart';
export 'widgets/location_picker_plus_unified_widget.dart';
export 'widgets/enhanced_google_places_widget.dart';
export 'widgets/multi_field_places_widget.dart';
export 'themes/enhanced_location_theme.dart';

// Import for the screen class
import 'widgets/location_picker_plus_unified_widget.dart';
import 'models/location_result.dart';
import 'themes/location_picker_plus_theme.dart';

class LocationPicker {
  Future<String?> getPlatformVersion() {
    return LocationPickerPlatform.instance.getPlatformVersion();
  }
}

/// Main API function for showing the unified location picker
/// Returns a LocationResult when user selects a location
///
/// Example usage:
/// ```dart
/// final result = await Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => LocationPickerScreen(
///       googlePlacesApiKey: 'your-api-key',
///     ),
///   ),
/// );
///
/// if (result != null) {
///   print('Selected: ${result.address}');
///   print('Lat/Lng: ${result.latitude}, ${result.longitude}');
/// }
/// ```
class LocationPickerScreen extends StatefulWidget {
  final String? googlePlacesApiKey;
  final LocationPickerMode mode;
  final LocationPickerTheme? theme;
  final String? country;
  final List<String> placesTypes;
  final bool showCoordinates;
  final bool useDropdownsForCountryState;
  final LocationResult? initialLocation;
  final String title;

  const LocationPickerScreen({
    super.key,
    this.googlePlacesApiKey,
    this.mode = LocationPickerMode.all,
    this.theme,
    this.country,
    this.placesTypes = const [],
    this.showCoordinates = true,
    this.useDropdownsForCountryState = true,
    this.initialLocation,
    this.title = 'Select Location',
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LocationResult? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedLocation);
              },
              child: const Text('DONE'),
            ),
        ],
      ),
      body: LocationPickerPlusUnifiedWidget(
        mode: widget.mode,
        googlePlacesApiKey: widget.googlePlacesApiKey,
        theme: widget.theme,
        country: widget.country,
        placesTypes: widget.placesTypes,
        showCoordinates: widget.showCoordinates,
        useDropdownsForCountryState: widget.useDropdownsForCountryState,
        initialLocation: widget.initialLocation,
        onLocationSelected: (locationResult) {
          setState(() {
            _selectedLocation = locationResult;
          });
        },
      ),
      floatingActionButton: _selectedLocation != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pop(_selectedLocation);
              },
              label: const Text('Select Location'),
              icon: const Icon(Icons.check),
            )
          : null,
    );
  }
}
