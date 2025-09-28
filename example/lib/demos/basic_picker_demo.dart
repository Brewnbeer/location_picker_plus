import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class BasicPickerDemo extends StatefulWidget {
  const BasicPickerDemo({super.key});

  @override
  State<BasicPickerDemo> createState() => _BasicPickerDemoState();
}

class _BasicPickerDemoState extends State<BasicPickerDemo> {
  CountryModel? selectedCountry;
  StateModel? selectedState;
  CityModel? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Location Picker'),
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
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Dropdown Selection',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select country, state, and city from dropdown lists. Selections are hierarchical - choosing a country will reset state and city.',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Location Picker Widget
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LocationPickerWidget(
                      useAutocomplete: false,
                      onCountryChanged: (country) {
                        setState(() {
                          selectedCountry = country;
                          selectedState = null;
                          selectedCity = null;
                        });
                      },
                      onStateChanged: (state) {
                        setState(() {
                          selectedState = state;
                          selectedCity = null;
                        });
                      },
                      onCityChanged: (city) {
                        setState(() {
                          selectedCity = city;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Selected Location Display
            if (selectedCountry != null || selectedState != null || selectedCity != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      const SizedBox(height: 12),
                      if (selectedCountry != null)
                        _buildInfoRow('Country', selectedCountry!.name, selectedCountry!.phoneCode),
                      if (selectedState != null)
                        _buildInfoRow('State', selectedState!.name, selectedState!.stateCode),
                      if (selectedCity != null)
                        _buildInfoRow('City', selectedCity!.name, null),
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
                      'Features',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Hierarchical selection (Country → State → City)'),
                    const Text('✅ Auto-reset dependent dropdowns'),
                    const Text('✅ Flag emojis for countries'),
                    const Text('✅ Phone codes display'),
                    const Text('✅ Customizable themes'),
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

  Widget _buildInfoRow(String label, String value, String? extra) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
          if (extra != null)
            Text(
              '($extra)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}