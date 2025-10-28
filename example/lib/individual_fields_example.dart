import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class IndividualFieldsExample extends StatefulWidget {
  const IndividualFieldsExample({super.key});

  @override
  State<IndividualFieldsExample> createState() =>
      _IndividualFieldsExampleState();
}

class _IndividualFieldsExampleState extends State<IndividualFieldsExample> {
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  @override
  void dispose() {
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Individual Address Fields Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo Information Card
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.widgets, color: Colors.purple.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Individual Field Widgets',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade800,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use individual address field widgets when you need custom layouts or only specific fields.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.purple.shade700,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Street Address Field
            StreetAddressField(
              controller: streetController,
              onChanged: (value) {
                debugPrint('Street changed: $value');
              },
            ),

            const SizedBox(height: 16),

            // City and State in a Row
            Row(
              children: [
                Expanded(
                  child: CityField(
                    controller: cityController,
                    onChanged: (value) {
                      debugPrint('City changed: $value');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StateField(
                    controller: stateController,
                    onChanged: (value) {
                      debugPrint('State changed: $value');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Country and Postal Code in a Row
            Row(
              children: [
                Expanded(
                  child: CountryField(
                    controller: countryController,
                    onChanged: (value) {
                      debugPrint('Country changed: $value');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PostalCodeField(
                    controller: postalCodeController,
                    onChanged: (value) {
                      debugPrint('Postal Code changed: $value');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Access all values
                  final address = {
                    'street': streetController.text,
                    'city': cityController.text,
                    'state': stateController.text,
                    'country': countryController.text,
                    'postalCode': postalCodeController.text,
                  };

                  debugPrint('Complete Address: $address');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Address saved: ${streetController.text}'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Address'),
              ),
            ),

            const SizedBox(height: 16),

            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Individual Widgets',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Use StreetAddressField, CityField, StateField, CountryField, PostalCodeField\n'
                      '• Each widget can be used independently\n'
                      '• Supports error display and validation\n'
                      '• Fully customizable with controllers\n'
                      '• Perfect for custom form layouts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
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
}
