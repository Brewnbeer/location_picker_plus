import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class DropdownFieldsExample extends StatefulWidget {
  const DropdownFieldsExample({super.key});

  @override
  State<DropdownFieldsExample> createState() => _DropdownFieldsExampleState();
}

class _DropdownFieldsExampleState extends State<DropdownFieldsExample> {
  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  CityModel? _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Fields with Local Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo Information Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage, color: Colors.green.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Local Database Dropdowns',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select from built-in Country, State, and City databases. No internet required!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade700,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Country Dropdown
            CountryDropdownField(
              initialValue: _selectedCountry,
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country;
                  _selectedState = null; // Reset state when country changes
                  _selectedCity = null; // Reset city when country changes
                });
              },
            ),

            const SizedBox(height: 16),

            // State Dropdown
            StateDropdownField(
              initialValue: _selectedState,
              countryId: _selectedCountry?.id,
              onChanged: (state) {
                setState(() {
                  _selectedState = state;
                  _selectedCity = null; // Reset city when state changes
                });
              },
            ),

            const SizedBox(height: 16),

            // City Dropdown
            CityDropdownField(
              initialValue: _selectedCity,
              stateId: _selectedState?.id,
              onChanged: (city) {
                setState(() {
                  _selectedCity = city;
                });
              },
            ),

            const SizedBox(height: 32),

            // Display Selected Information
            if (_selectedCountry != null ||
                _selectedState != null ||
                _selectedCity != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Selected Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              if (_selectedCountry != null)
                _buildInfoCard(
                  icon: Icons.public,
                  color: Colors.blue,
                  title: 'Country',
                  details: [
                    'Name: ${_selectedCountry!.name}',
                    'Code: ${_selectedCountry!.sortName}',
                    'Phone Code: ${_selectedCountry!.phoneCode}',
                    if (_selectedCountry!.capital != null)
                      'Capital: ${_selectedCountry!.capital}',
                    if (_selectedCountry!.currency != null)
                      'Currency: ${_selectedCountry!.currency}',
                  ],
                  emoji: _selectedCountry!.flagEmoji,
                ),

              if (_selectedState != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.map,
                  color: Colors.orange,
                  title: 'State',
                  details: [
                    'Name: ${_selectedState!.name}',
                    if (_selectedState!.stateCode != null)
                      'Code: ${_selectedState!.stateCode}',
                    if (_selectedState!.type != null)
                      'Type: ${_selectedState!.type}',
                  ],
                ),
              ],

              if (_selectedCity != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.location_city,
                  color: Colors.green,
                  title: 'City',
                  details: [
                    'Name: ${_selectedCity!.name}',
                    if (_selectedCity!.latitude != null &&
                        _selectedCity!.longitude != null)
                      'Coordinates: ${_selectedCity!.latitude}, ${_selectedCity!.longitude}',
                    if (_selectedCity!.isCapital) 'Status: Capital City ⭐',
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final location = [
                      if (_selectedCity != null) _selectedCity!.name,
                      if (_selectedState != null) _selectedState!.name,
                      if (_selectedCountry != null) _selectedCountry!.name,
                    ].join(', ');

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected: $location'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirm Selection'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Information Card
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.amber.shade900),
                        const SizedBox(width: 8),
                        Text(
                          'Dropdown Features',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Works completely offline (local database)\n'
                      '• Searchable dropdowns for easy selection\n'
                      '• Cascading selection (Country → State → City)\n'
                      '• Shows country flags and capital cities\n'
                      '• Includes coordinates for cities\n'
                      '• Thousands of locations worldwide',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                      ),
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

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<String> details,
    String? emoji,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (emoji != null) ...[
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
            ] else ...[
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...details.map((detail) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          detail,
                          style: const TextStyle(fontSize: 13),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
