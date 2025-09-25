import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';
import 'location_detector_demo.dart';
import 'unified_location_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Picker Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LocationPickerPlusDemo(),
    );
  }
}

class LocationPickerPlusDemo extends StatefulWidget {
  const LocationPickerPlusDemo({super.key});

  @override
  State<LocationPickerPlusDemo> createState() => _LocationPickerPlusDemoState();
}

class _LocationPickerPlusDemoState extends State<LocationPickerPlusDemo> {
  CountryModel? selectedCountry;
  StateModel? selectedState;
  CityModel? selectedCity;

  int _currentThemeIndex = 0;
  final List<LocationPickerTheme> _themes = [
    LocationPickerTheme.defaultTheme(),
    LocationPickerTheme.materialTheme(),
    LocationPickerTheme.cupertinoTheme(),
    LocationPickerTheme.defaultTheme().copyWith(
      showFlags: false,
      showPhoneCodes: true,
      dropdownBackgroundColor: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      itemHighlightColor: Colors.blue.withValues(alpha: 0.1),
    ),
  ];

  final List<String> _themeNames = [
    'Default',
    'Material',
    'Cupertino',
    'Custom',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location),
            tooltip: 'NEW: Unified Location Picker',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UnifiedLocationDemo(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            tooltip: 'Live Location Demo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationDetectorDemo(),
                ),
              );
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.palette),
            onSelected: (index) {
              setState(() {
                _currentThemeIndex = index;
              });
            },
            itemBuilder: (context) => List.generate(
              _themes.length,
              (index) =>
                  PopupMenuItem(value: index, child: Text(_themeNames[index])),
            ),
          ),
        ],
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
                      'Location Picker with ${_themeNames[_currentThemeIndex]} Theme',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    LocationPickerWidget(
                      theme: _themes[_currentThemeIndex],
                      useAutocomplete: false, // Traditional dropdown mode
                      countryLabel: 'Country (Dropdown)',
                      stateLabel: 'State/Province (Dropdown)',
                      cityLabel: 'City (Dropdown)',
                      onCountryChanged: (country) {
                        setState(() {
                          selectedCountry = country;
                        });
                      },
                      onStateChanged: (state) {
                        setState(() {
                          selectedState = state;
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
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Location',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildSelectionInfo(
                      'Country',
                      selectedCountry?.name,
                      selectedCountry?.phoneCode,
                    ),
                    const SizedBox(height: 8),
                    _buildSelectionInfo(
                      'State',
                      selectedState?.name,
                      selectedState?.stateCode,
                    ),
                    const SizedBox(height: 8),
                    _buildSelectionInfo('City', selectedCity?.name, null),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autocomplete Mode - Type to See Suggestions!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start typing country, state, or city names to see instant suggestions',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    LocationPickerWidget(
                      theme: _themes[_currentThemeIndex].copyWith(
                        showFlags: true,
                        showPhoneCodes: false,
                      ),
                      useAutocomplete: true,
                      countryLabel: 'Country (Autocomplete)',
                      stateLabel: 'State (Autocomplete)',
                      cityLabel: 'City (Autocomplete)',
                      countryHint: 'Type country name...',
                      stateHint: 'Type state name...',
                      cityHint: 'Type city name...',
                      onCountryChanged: (country) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Selected Country: ${country?.name ?? 'None'}',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onStateChanged: (state) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Selected State: ${state?.name ?? 'None'}',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onCityChanged: (city) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Selected City: ${city?.name ?? 'None'}',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horizontal Layout Example',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LocationPickerWidget(
                            theme: _themes[_currentThemeIndex],
                            showState: false,
                            showCity: false,
                            countryLabel: 'Country',
                            isExpanded: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: LocationPickerWidget(
                            theme: _themes[_currentThemeIndex],
                            showCountry: false,
                            showCity: false,
                            stateLabel: 'State',
                            isExpanded: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                    const Text('✓ Two modes: Dropdown & Autocomplete'),
                    const Text('✓ Real-time search suggestions'),
                    const Text('✓ Debounced input for performance'),
                    const Text('✓ Customizable themes and styling'),
                    const Text('✓ Flag emojis and phone codes'),
                    const Text('✓ Flexible layouts (vertical/horizontal)'),
                    const Text('✓ Asset-based data loading'),
                    const Text('✓ Enhanced models with geolocation'),
                    const Text('✓ Animation support'),
                    const Text('✓ Accessible and responsive design'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionInfo(String label, String? value, String? extra) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'Not selected',
            style: TextStyle(color: value != null ? Colors.black : Colors.grey),
          ),
        ),
        if (extra != null)
          Text(extra, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
