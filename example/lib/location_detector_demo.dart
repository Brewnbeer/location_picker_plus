import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class LocationDetectorDemo extends StatefulWidget {
  const LocationDetectorDemo({super.key});

  @override
  State<LocationDetectorDemo> createState() => _LocationDetectorDemoState();
}

class _LocationDetectorDemoState extends State<LocationDetectorDemo> {
  LocationModel? _detectedLocation;
  String? _detectedAddress;
  double? _detectedLatitude;
  double? _detectedLongitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Detector Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Location Detection',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detect your current location or search for an address',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    LocationDetectorWidget(
                      mode: LocationDetectorMode.both,
                      showCoordinates: true,
                      showFullAddress: true,
                      autoDetectOnInit: false,
                      currentLocationLabel: 'Get Current Location',
                      addressSearchLabel: 'Search by Address',
                      addressSearchHint:
                          'Enter any address, city, or landmark...',
                      onLocationChanged: (location) {
                        setState(() {
                          _detectedLocation = location;
                        });
                      },
                      onAddressChanged: (address) {
                        setState(() {
                          _detectedAddress = address;
                        });
                      },
                      onCoordinatesChanged: (lat, lng) {
                        setState(() {
                          _detectedLatitude = lat;
                          _detectedLongitude = lng;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_detectedLocation != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Data Summary',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildDataRow('Full Address', _detectedAddress ?? 'N/A'),
                      _buildDataRow(
                        'City',
                        _detectedLocation!.locality ?? 'N/A',
                      ),
                      _buildDataRow(
                        'State',
                        _detectedLocation!.administrativeArea ?? 'N/A',
                      ),
                      _buildDataRow(
                        'Country',
                        _detectedLocation!.country ?? 'N/A',
                      ),
                      _buildDataRow(
                        'Postal Code',
                        _detectedLocation!.postalCode ?? 'N/A',
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coordinates',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latitude: ${_detectedLatitude?.toStringAsFixed(6) ?? 'N/A'}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            Text(
                              'Longitude: ${_detectedLongitude?.toStringAsFixed(6) ?? 'N/A'}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    const Text('✓ Live GPS location detection'),
                    const Text('✓ Address search with geocoding'),
                    const Text('✓ Reverse geocoding (coordinates → address)'),
                    const Text('✓ Forward geocoding (address → coordinates)'),
                    const Text('✓ Automatic permission handling'),
                    const Text('✓ Error handling and user guidance'),
                    const Text('✓ Customizable accuracy and timeout'),
                    const Text('✓ Support for multiple locales'),
                    const Text('✓ Real-time coordinate display'),
                    const Text(
                      '✓ Full address breakdown (city, state, country)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.amber.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Usage Note',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a separate widget from the LocationPickerWidget. '
                      'Use LocationDetectorWidget for live location detection and '
                      'LocationPickerWidget for dropdown-based selection from predefined data.',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
