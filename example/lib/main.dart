import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';
import 'individual_fields_example.dart';
import 'dropdown_fields_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Picker Plus Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const DemoListScreen(),
    );
  }
}

class DemoListScreen extends StatelessWidget {
  const DemoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker Plus Demos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.location_on, color: Colors.blue),
              ),
              title: const Text('Complete Address Entry'),
              subtitle: const Text('Google Places + GPS + Manual Entry'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomStreetAddressFieldDemo(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.storage, color: Colors.green),
              ),
              title: const Text('Dropdown with Local Database'),
              subtitle: const Text('Country, State, City from offline database'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DropdownFieldsExample(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: const Icon(Icons.widgets, color: Colors.purple),
              ),
              title: const Text('Individual Text Field Widgets'),
              subtitle: const Text('Simple text fields for custom layouts'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IndividualFieldsExample(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomStreetAddressFieldDemo extends StatefulWidget {
  const CustomStreetAddressFieldDemo({super.key});

  @override
  State<CustomStreetAddressFieldDemo> createState() =>
      _CustomStreetAddressFieldDemoState();
}

class _CustomStreetAddressFieldDemoState
    extends State<CustomStreetAddressFieldDemo> {
  AddressFormData? _currentAddress;
  final Map<String, String> _fieldErrors = {};

  // Replace with your actual Google Places API key
  final String _googleApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Street Address Field Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Address Entry Widget',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start typing to search addresses in India or US using Google Places API',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // The Custom Street Address Field with GPS
            CustomStreetAddressField(
              googleApiKey: _googleApiKey,
              showAllFields: true,
              enableLocationPicker: true, // Enable GPS location detection
              fieldErrors: _fieldErrors,
              onFieldErrorCleared: (fieldKey) {
                setState(() {
                  _fieldErrors.remove(fieldKey);
                });
              },
              onAddressChanged: (addressData) {
                setState(() {
                  _currentAddress = addressData;
                });
              },
              onPlaceSelected: (place) {
                // Place selected from Google Places API
                debugPrint('Selected place: ${place?.address}');
              },
              onLocationSelected: (position) {
                // GPS location detected
                debugPrint('GPS Location: ${position?.latitude}, ${position?.longitude}');
              },
            ),

            const SizedBox(height: 32),

            // Display Selected Address Information
            if (_currentAddress != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Current Address Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Street', _currentAddress!.street ?? 'N/A'),
              _buildInfoRow('City', _currentAddress!.city ?? 'N/A'),
              _buildInfoRow('State', _currentAddress!.state ?? 'N/A'),
              _buildInfoRow('Country', _currentAddress!.country ?? 'N/A'),
              _buildInfoRow(
                  'Postal Code', _currentAddress!.postalCode ?? 'N/A'),
              _buildInfoRow(
                'Coordinates',
                _currentAddress!.latitude != null &&
                        _currentAddress!.longitude != null
                    ? '${_currentAddress!.latitude}, ${_currentAddress!.longitude}'
                    : 'N/A',
              ),
              _buildInfoRow(
                'From Google Places',
                _currentAddress!.isFromGooglePlaces ? 'Yes' : 'No',
              ),
            ],

            const SizedBox(height: 24),

            // Test Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _fieldErrors['address'] =
                          'Please enter a valid address';
                    });
                  },
                  icon: const Icon(Icons.error_outline),
                  label: const Text('Test Address Error'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade900,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _fieldErrors.clear();
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Errors'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
