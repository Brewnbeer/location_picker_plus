import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class GpsLocationDemo extends StatefulWidget {
  const GpsLocationDemo({super.key});

  @override
  State<GpsLocationDemo> createState() => _GpsLocationDemoState();
}

class _GpsLocationDemoState extends State<GpsLocationDemo> {
  LocationModel? detectedLocation;
  String? detectedAddress;
  double? latitude;
  double? longitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Location Detection'),
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
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Location Detection',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detect your current GPS location or search for any address. Includes reverse geocoding to get address from coordinates.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Location Detector Widget
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Detector',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LocationDetectorWidget(
                        mode: LocationDetectorMode.both,
                        showCoordinates: true,
                        showFullAddress: true,
                        autoDetectOnInit: false,
                        currentLocationLabel: 'Get My Location',
                        addressSearchLabel: 'Search Address',
                        addressSearchHint: 'Enter any address or landmark...',
                        onLocationChanged: (location) {
                          setState(() {
                            detectedLocation = location;
                          });
                        },
                        onAddressChanged: (address) {
                          setState(() {
                            detectedAddress = address;
                          });
                        },
                        onCoordinatesChanged: (lat, lng) {
                          setState(() {
                            latitude = lat;
                            longitude = lng;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location Results
            if (detectedLocation != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected Location',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (detectedAddress != null)
                        _buildInfoRow('Address', detectedAddress!),
                      if (detectedLocation!.locality != null)
                        _buildInfoRow('City', detectedLocation!.locality!),
                      if (detectedLocation!.administrativeArea != null)
                        _buildInfoRow('State', detectedLocation!.administrativeArea!),
                      if (detectedLocation!.country != null)
                        _buildInfoRow('Country', detectedLocation!.country!),
                      if (detectedLocation!.postalCode != null)
                        _buildInfoRow('Postal Code', detectedLocation!.postalCode!),
                      if (latitude != null && longitude != null) ...[
                        const Divider(),
                        _buildInfoRow('Latitude', latitude!.toStringAsFixed(6)),
                        _buildInfoRow('Longitude', longitude!.toStringAsFixed(6)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Live GPS location detection'),
                    const Text('✅ Address search with geocoding'),
                    const Text('✅ Reverse geocoding (coordinates → address)'),
                    const Text('✅ Forward geocoding (address → coordinates)'),
                    const Text('✅ Automatic permission handling'),
                    const Text('✅ Real-time coordinate display'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
            child: Text(value),
          ),
        ],
      ),
    );
  }
}