import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class UnifiedLocationDemo extends StatefulWidget {
  const UnifiedLocationDemo({super.key});

  @override
  State<UnifiedLocationDemo> createState() => _UnifiedLocationDemoState();
}

class _UnifiedLocationDemoState extends State<UnifiedLocationDemo> {
  LocationResult? _selectedLocation;

  // For demo purposes - replace with your actual Google Places API key
  final String? _googlePlacesApiKey = null; // Set to your API key to enable Google Places

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Location Picker Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Places + GPS + Manual Entry',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete location picker with all features',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    if (_googlePlacesApiKey == null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, size: 16, color: Colors.orange.shade700),
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
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _openLocationPicker(LocationPickerMode.all),
                      icon: const Icon(Icons.location_on),
                      label: const Text('Open Full Location Picker'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // NEW v2.1.0 Features Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.new_releases, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'NEW v2.1.0 Features Demo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow('🔒', 'Smart Field Locking', 'Google Places addresses lock manual entry fields'),
                    _buildFeatureRow('🌏', 'Country Restrictions', 'Only India, US & Canada in dropdown'),
                    _buildFeatureRow('📍', 'Source Tracking', 'Know if address came from Places, GPS, or manual entry'),
                    _buildFeatureRow('👁️', 'Visual Indicators', 'Clear UI showing locked/editable states'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Individual Modes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openLocationPicker(
                              LocationPickerMode.googlePlaces,
                            ),
                            icon: const Icon(Icons.search),
                            label: const Text('Places Only'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openLocationPicker(
                              LocationPickerMode.currentLocation,
                            ),
                            icon: const Icon(Icons.my_location),
                            label: const Text('GPS Only'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _openLocationPicker(LocationPickerMode.manualEntry),
                        icon: const Icon(Icons.edit_location),
                        label: const Text('Manual Entry Only'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Embedded Widget Demo',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: LocationPickerPlusUnifiedWidget(
                        mode: LocationPickerMode.all,
                        googlePlacesApiKey: _googlePlacesApiKey,
                        // NEW v2.1.0 - Smart field management
                        allowedCountries: ['India', 'United States', 'Canada'], // Country restrictions
                        lockFieldsForGooglePlaces: true, // Lock fields for Google Places
                        autoDetectOnInit: false,
                        showCoordinates: true,
                        onLocationSelected: (locationResult) {
                          setState(() {
                            _selectedLocation = locationResult;
                          });

                          if (locationResult != null) {
                            String sourceText = '';
                            switch (locationResult.addressSource) {
                              case AddressSource.googlePlaces:
                                sourceText = ' (from Google Places - fields locked)';
                                break;
                              case AddressSource.manualEntry:
                                sourceText = ' (manual entry - fields editable)';
                                break;
                              case AddressSource.gpsLocation:
                                sourceText = ' (from GPS - fields editable)';
                                break;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Selected: ${locationResult.address}$sourceText',
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedLocation != null) ...[
              const SizedBox(height: 16),
              _buildSelectedLocationCard(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openLocationPicker(LocationPickerMode mode) async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          googlePlacesApiKey: _googlePlacesApiKey,
          mode: mode,
          title: _getTitleForMode(mode),
          showCoordinates: true,
          useDropdownsForCountryState: true,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLocation = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: ${result.address}'),
          action: SnackBarAction(
            label: 'View Details',
            onPressed: () => _showLocationDetails(result),
          ),
        ),
      );
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

  void _showLocationDetails(LocationResult location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Address', location.address),
            if (location.city != null) _buildDetailRow('City', location.city!),
            if (location.state != null)
              _buildDetailRow('State', location.state!),
            if (location.country != null)
              _buildDetailRow('Country', location.country!),
            if (location.postalCode != null)
              _buildDetailRow('Postal Code', location.postalCode!),
            _buildDetailRow('Latitude', location.latitude.toStringAsFixed(6)),
            _buildDetailRow('Longitude', location.longitude.toStringAsFixed(6)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getSourceColor(location.addressSource).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _getSourceColor(location.addressSource),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSourceIcon(location.addressSource),
                    size: 16,
                    color: _getSourceColor(location.addressSource),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getSourceText(location.addressSource),
                    style: TextStyle(
                      color: _getSourceColor(location.addressSource),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSelectedLocationCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.place,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last Selected Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _selectedLocation!.address,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showLocationDetails(_selectedLocation!),
                child: const Text('View Full Details'),
              ),
            ),
          ],
        ),
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

  IconData _getSourceIcon(AddressSource source) {
    switch (source) {
      case AddressSource.googlePlaces:
        return Icons.search;
      case AddressSource.manualEntry:
        return Icons.edit;
      case AddressSource.gpsLocation:
        return Icons.my_location;
    }
  }

  String _getSourceText(AddressSource source) {
    switch (source) {
      case AddressSource.googlePlaces:
        return 'From Google Places (fields locked for accuracy)';
      case AddressSource.manualEntry:
        return 'Manual entry (all fields editable)';
      case AddressSource.gpsLocation:
        return 'From GPS location (fields editable)';
    }
  }

  Widget _buildFeatureRow(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
