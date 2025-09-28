import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class AutocompletePickerDemo extends StatefulWidget {
  const AutocompletePickerDemo({super.key});

  @override
  State<AutocompletePickerDemo> createState() => _AutocompletePickerDemoState();
}

class _AutocompletePickerDemoState extends State<AutocompletePickerDemo> {
  String? lastSelectedType;
  String? lastSelectedName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete Picker'),
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
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autocomplete Search',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start typing in any field to see instant search suggestions. Great for fast location selection when you know the name.',
                      style: TextStyle(color: Colors.orange.shade700),
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
                      'Search for Locations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type to see suggestions appear instantly',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LocationPickerWidget(
                      useAutocomplete: true,
                      countryHint: 'Type country name (e.g., United States)...',
                      stateHint: 'Type state name (e.g., California)...',
                      cityHint: 'Type city name (e.g., San Francisco)...',
                      onCountryChanged: (country) {
                        if (country != null) {
                          setState(() {
                            lastSelectedType = 'Country';
                            lastSelectedName = country.name;
                          });
                          _showSelection('Country', country.name);
                        }
                      },
                      onStateChanged: (state) {
                        if (state != null) {
                          setState(() {
                            lastSelectedType = 'State';
                            lastSelectedName = state.name;
                          });
                          _showSelection('State', state.name);
                        }
                      },
                      onCityChanged: (city) {
                        if (city != null) {
                          setState(() {
                            lastSelectedType = 'City';
                            lastSelectedName = city.name;
                          });
                          _showSelection('City', city.name);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Last Selection Display
            if (lastSelectedName != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Selection',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            Text(
                              '$lastSelectedType: $lastSelectedName',
                              style: TextStyle(color: Colors.green.shade700),
                            ),
                          ],
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
                      'Features',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Real-time search suggestions'),
                    const Text('✅ Debounced input for performance'),
                    const Text('✅ Fast location selection'),
                    const Text('✅ Type-ahead functionality'),
                    const Text('✅ Mobile-friendly input'),
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

  void _showSelection(String type, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected $type: $name'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}