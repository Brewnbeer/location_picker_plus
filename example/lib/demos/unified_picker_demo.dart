import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class UnifiedPickerDemo extends StatefulWidget {
  const UnifiedPickerDemo({super.key});

  @override
  State<UnifiedPickerDemo> createState() => _UnifiedPickerDemoState();
}

class _UnifiedPickerDemoState extends State<UnifiedPickerDemo> {
  LocationResult? selectedLocation;

  // For demo purposes - replace with your actual Google Places API key
  final String? googlePlacesApiKey =
      null; // Set to your API key to enable Google Places

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Location Picker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All-in-One Location Picker',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Combines Google Places search, GPS location detection, and manual address entry in one unified interface.',
                        style: TextStyle(color: Colors.purple.shade700),
                      ),
                      if (googlePlacesApiKey == null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Google Places features require API key',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Try Different Modes',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Full Picker Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _openLocationPicker(LocationPickerMode.all),
                          icon: const Icon(Icons.place),
                          label: const Text('Open Full Location Picker'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Individual Mode Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openLocationPicker(
                                LocationPickerMode.googlePlaces,
                              ),
                              icon: const Icon(Icons.search),
                              label: const Text('Places'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openLocationPicker(
                                LocationPickerMode.currentLocation,
                              ),
                              icon: const Icon(Icons.my_location),
                              label: const Text('GPS'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openLocationPicker(
                                LocationPickerMode.manualEntry,
                              ),
                              icon: const Icon(Icons.edit),
                              label: const Text('Manual'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Embedded Widget Demo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Embedded Widget Example',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Widget embedded directly in your app',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: LocationPickerPlusUnifiedWidget(
                          mode: LocationPickerMode.all,
                          googlePlacesApiKey: googlePlacesApiKey,
                          allowedCountries: [
                            'India',
                            'United States',
                            'Canada',
                          ],
                          lockFieldsForGooglePlaces: true,
                          autoDetectOnInit: false,
                          showCoordinates: true,
                          onLocationSelected: (locationResult) {
                            setState(() {
                              selectedLocation = locationResult;
                            });

                            if (locationResult != null) {
                              _showLocationSelected(locationResult);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Selected Location Display
              if (selectedLocation != null)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Selected Location',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          selectedLocation!.address,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lat: ${selectedLocation!.latitude.toStringAsFixed(4)}, '
                          'Lng: ${selectedLocation!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSourceColor(
                              selectedLocation!.addressSource,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getSourceColor(
                                selectedLocation!.addressSource,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getSourceText(selectedLocation!.addressSource),
                            style: TextStyle(
                              color: _getSourceColor(
                                selectedLocation!.addressSource,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Features
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unified Features',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('✅ Google Places API integration'),
                      const Text('✅ GPS location detection'),
                      const Text('✅ Manual address entry'),
                      const Text('✅ Smart field locking'),
                      const Text('✅ Address source tracking'),
                      const Text('✅ Country restrictions'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLocationPicker(LocationPickerMode mode) async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          googlePlacesApiKey: googlePlacesApiKey,
          mode: mode,
          title: _getTitleForMode(mode),
          showCoordinates: true,
          useDropdownsForCountryState: true,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        selectedLocation = result;
      });
      _showLocationSelected(result);
    }
  }

  String _getTitleForMode(LocationPickerMode mode) {
    switch (mode) {
      case LocationPickerMode.googlePlaces:
        return 'Search Places';
      case LocationPickerMode.currentLocation:
        return 'Use GPS Location';
      case LocationPickerMode.manualEntry:
        return 'Enter Address Manually';
      case LocationPickerMode.all:
        return 'Select Location';
    }
  }

  void _showLocationSelected(LocationResult location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${location.address}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getSourceColor(AddressSource source) {
    switch (source) {
      case AddressSource.googlePlaces:
        return Colors.blue;
      case AddressSource.manualEntry:
        return Colors.orange;
      case AddressSource.gpsLocation:
        return Colors.green;
    }
  }

  String _getSourceText(AddressSource source) {
    switch (source) {
      case AddressSource.googlePlaces:
        return 'From Google Places';
      case AddressSource.manualEntry:
        return 'Manual Entry';
      case AddressSource.gpsLocation:
        return 'GPS Location';
    }
  }
}
