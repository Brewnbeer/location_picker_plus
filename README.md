# Location Picker Plus

A powerful Flutter plugin for address entry with **Google Places API integration**, featuring smart autocomplete, field locking, and comprehensive address parsing. Perfect for forms requiring complete address information.

## 🚀 v3.1.0 - GPS, Dropdowns & Individual Fields

### ✨ Single Powerful Widget for Complete Address Entry

**CustomStreetAddressField** - An all-in-one address entry widget with:
- 🔍 **Google Places Autocomplete** - Real-time address search (India & US)
- 📍 **GPS Location Detection** - One-click current location detection (works WITHOUT Google Places API)
- 🗺️ **Complete Address Parsing** - Auto-fills street, city, state, country, postal code
- 🔒 **Smart Field Locking** - Prevents editing when address from Google Places or GPS
- 🌏 **Coordinate Storage** - Captures latitude/longitude with address
- 📝 **Manual Entry Support** - Allow users to type addresses manually
- ⚠️ **Field Validation** - Built-in error display for each field
- 🎨 **Themeable** - Fully customizable to match your app design

**Local Database Dropdown Widgets** - Offline country/state/city selection:
- ✅ **CountryDropdownField** - 250+ countries with flags and phone codes
- ✅ **StateDropdownField** - States/provinces filtered by country
- ✅ **CityDropdownField** - Cities filtered by state with coordinates
- 🔍 **Searchable** - Instant filtering as you type
- 🗂️ **Cascading** - Country → State → City selection flow
- 📱 **Offline** - Works without internet (bundled database)

**Individual Field Widgets** - Use address fields separately:
- ✅ **StreetAddressField** - Street address field
- ✅ **CityField** - City field
- ✅ **StateField** - State field
- ✅ **CountryField** - Country field
- ✅ **PostalCodeField** - Postal code field

## Features

### Complete Address Widget
- ✅ **Google Places Integration** - Search addresses with real-time suggestions (optional)
- ✅ **GPS Location Detection** - One-click current location with reverse geocoding (works WITHOUT Google API!)
- ✅ **Multi-Field Support** - Street, City, State, Country, Postal Code
- ✅ **Coordinate Capture** - Automatically stores latitude and longitude
- ✅ **Country Restrictions** - Limit searches to specific countries (India & US by default)
- ✅ **Smart Field Management** - Auto-lock fields from Google Places or GPS data
- ✅ **Manual Override** - Clear to allow manual address entry
- ✅ **Field Validation** - Display errors per field with clear visual feedback
- ✅ **Source Tracking** - Know if address is from Google Places, GPS, or manual entry
- ✅ **Locked Address Support** - Perfect for business addresses that shouldn't change
- ✅ **Clean Material Design** - Beautiful, modern UI out of the box

### Local Database Dropdown Widgets
- ✅ **Offline Operation** - No internet required, uses bundled database
- ✅ **250+ Countries** - Complete country list with flags and phone codes
- ✅ **States/Provinces** - Comprehensive state data by country
- ✅ **Cities** - Thousands of cities worldwide with coordinates
- ✅ **Searchable** - Type to filter options instantly
- ✅ **Cascading Selection** - Country → State → City flow
- ✅ **Rich Data** - Includes capitals, coordinates, currency, and more

### Individual Field Widgets
- ✅ **Modular Design** - Use only the fields you need
- ✅ **Custom Layouts** - Arrange fields however you want
- ✅ **Full Feature Parity** - Same styling and validation as complete widget
- ✅ **Controller Support** - Full TextEditingController integration
- ✅ **Easy Integration** - Drop-in replacements for standard TextFields

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  location_picker_plus: ^3.1.0
```

### 🗝️ Google Places API Setup

1. **Get API Key**: Visit [Google Cloud Console](https://console.cloud.google.com/)
2. **Enable APIs**: Enable "Places API" in your project
3. **Configure Billing**: Ensure billing is enabled for your project
4. **Restrict Key** (recommended): Restrict your API key to specific platforms

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class MyAddressForm extends StatefulWidget {
  @override
  _MyAddressFormState createState() => _MyAddressFormState();
}

class _MyAddressFormState extends State<MyAddressForm> {
  AddressFormData? _currentAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: CustomStreetAddressField(
          googleApiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
          showAllFields: true,
          onAddressChanged: (addressData) {
            setState(() {
              _currentAddress = addressData;
            });

            // Access address data
            print('Street: ${addressData.street}');
            print('City: ${addressData.city}');
            print('State: ${addressData.state}');
            print('Country: ${addressData.country}');
            print('Postal Code: ${addressData.postalCode}');
            print('Coordinates: ${addressData.latitude}, ${addressData.longitude}');
            print('From Google Places: ${addressData.isFromGooglePlaces}');
          },
          onPlaceSelected: (place) {
            // Called when a Google Place is selected
            print('Selected place: ${place?.address}');
          },
        ),
      ),
    );
  }
}
```

### With Field Validation

```dart
class _MyFormState extends State<MyForm> {
  final Map<String, String> _fieldErrors = {};

  @override
  Widget build(BuildContext context) {
    return CustomStreetAddressField(
      googleApiKey: 'YOUR_API_KEY',
      showAllFields: true,
      fieldErrors: _fieldErrors,
      onFieldErrorCleared: (fieldKey) {
        setState(() {
          _fieldErrors.remove(fieldKey);
        });
      },
      onAddressChanged: (addressData) {
        // Validate
        if (addressData.street == null || addressData.street!.isEmpty) {
          setState(() {
            _fieldErrors['address'] = 'Please enter a valid address';
          });
        }
      },
    );
  }
}
```

### Locked Address (for Business Locations)

```dart
CustomStreetAddressField(
  googleApiKey: 'YOUR_API_KEY',
  isLocked: true,  // Prevents editing
  initialStreet: '1600 Amphitheatre Parkway',
  initialCity: 'Mountain View',
  initialState: 'CA',
  initialCountry: 'US',
  initialPostalCode: '94043',
  initialLatitude: 37.4220,
  initialLongitude: -122.0841,
  showAllFields: true,
)
```

### Street Address Only (No Additional Fields)

```dart
CustomStreetAddressField(
  googleApiKey: 'YOUR_API_KEY',
  showAllFields: false,  // Only show street address field
  hintText: 'Enter delivery address...',
  onAddressChanged: (addressData) {
    print('Street only: ${addressData.street}');
  },
)
```

### GPS Location Detection (Works WITHOUT Google Places API!)

```dart
CustomStreetAddressField(
  enableLocationPicker: true,  // Enable GPS button
  showAllFields: true,
  onAddressChanged: (addressData) {
    print('Address: ${addressData.street}');
    print('Coordinates: ${addressData.latitude}, ${addressData.longitude}');
  },
  onLocationSelected: (position) {
    print('GPS detected: ${position?.latitude}, ${position?.longitude}');
  },
)
```

**Note:** GPS location detection uses device GPS + reverse geocoding (via `geocoding` package). It does NOT require a Google Places API key!

### Using Individual Field Widgets

Perfect for custom layouts or when you only need specific fields:

```dart
class MyCustomForm extends StatelessWidget {
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Just the street address field
        StreetAddressField(
          controller: streetController,
          onChanged: (value) {
            print('Street: $value');
          },
        ),

        SizedBox(height: 16),

        // City and State side by side
        Row(
          children: [
            Expanded(
              child: CityField(
                controller: cityController,
                errorText: cityController.text.isEmpty ? 'Required' : null,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StateField(
                onChanged: (value) => print('State: $value'),
              ),
            ),
          ],
        ),

        // Just postal code
        PostalCodeField(
          onChanged: (value) => print('Postal: $value'),
        ),
      ],
    );
  }
}
```

**Available Individual Widgets:**
- `StreetAddressField` - Street address with 2 lines support
- `CityField` - City input
- `StateField` - State/Province input
- `CountryField` - Country input
- `PostalCodeField` - Postal/ZIP code (numeric keyboard)
- `AddressTextField` - Generic base widget for custom address fields

### Using Local Database Dropdown Widgets

Perfect for offline country/state/city selection with cascading filters:

```dart
import 'package:flutter/material.dart';
import 'package:location_picker_plus/location_picker_plus.dart';

class LocationDropdownForm extends StatefulWidget {
  @override
  _LocationDropdownFormState createState() => _LocationDropdownFormState();
}

class _LocationDropdownFormState extends State<LocationDropdownForm> {
  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  CityModel? _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Country Dropdown with flags
        CountryDropdownField(
          initialValue: _selectedCountry,
          onChanged: (country) {
            setState(() {
              _selectedCountry = country;
              _selectedState = null;  // Reset state when country changes
              _selectedCity = null;   // Reset city when country changes
            });

            // Access country data
            print('Country: ${country?.name}');
            print('Code: ${country?.sortName}');
            print('Phone Code: ${country?.phoneCode}');
            print('Flag: ${country?.flagEmoji}');
          },
        ),

        SizedBox(height: 16),

        // State Dropdown (filtered by selected country)
        StateDropdownField(
          initialValue: _selectedState,
          countryId: _selectedCountry?.id,  // Filter by country
          onChanged: (state) {
            setState(() {
              _selectedState = state;
              _selectedCity = null;  // Reset city when state changes
            });

            print('State: ${state?.name}');
            print('State Code: ${state?.stateCode}');
          },
        ),

        SizedBox(height: 16),

        // City Dropdown (filtered by selected state)
        CityDropdownField(
          initialValue: _selectedCity,
          stateId: _selectedState?.id,  // Filter by state
          onChanged: (city) {
            setState(() {
              _selectedCity = city;
            });

            print('City: ${city?.name}');
            print('Coordinates: ${city?.latitude}, ${city?.longitude}');
            print('Is Capital: ${city?.isCapital}');
          },
        ),
      ],
    );
  }
}
```

**Dropdown Features:**
- **Searchable Dialogs** - Type to filter options instantly
- **Country Flags** - Visual flag emojis for all countries
- **Cascading Selection** - Selecting country filters states, selecting state filters cities
- **Rich Data Access** - Phone codes, coordinates, capitals, currency, and more
- **Offline Database** - No internet required, uses bundled JSON data
- **Performance Optimized** - Efficient search with thousands of locations

**Available Dropdown Widgets:**
- `CountryDropdownField` - Select from 250+ countries
- `StateDropdownField` - Select states/provinces (filtered by country)
- `CityDropdownField` - Select cities (filtered by state)

**Accessing Location Service Directly:**

```dart
import 'package:location_picker_plus/location_picker_plus.dart';

// Load all countries
List<CountryModel> countries = await LocationService.instance.loadCountries();

// Get states by country ID
List<StateModel> states = await LocationService.instance.getStatesByCountryId(101); // India

// Get cities by state ID
List<CityModel> cities = await LocationService.instance.getCitiesByStateId(4008); // California

// Access model data
CountryModel country = countries.first;
print('${country.name} ${country.flagEmoji}');  // India 🇮🇳
print('Phone: +${country.phoneCode}');          // Phone: +91
print('Capital: ${country.capital}');           // Capital: New Delhi
print('Currency: ${country.currency}');         // Currency: INR

StateModel state = states.first;
print('${state.name} (${state.stateCode})');   // Maharashtra (MH)

CityModel city = cities.first;
print('${city.name}');                          // Mumbai
print('Coords: ${city.latitude}, ${city.longitude}');
print('Capital: ${city.isCapital}');            // true/false
```

## Widget Parameters

### CustomStreetAddressField

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `googleApiKey` | `String?` | Google Places API key (optional - not needed for GPS) | null |
| `enableLocationPicker` | `bool` | Show GPS location button (works without Google API) | false |
| `initialStreet` | `String?` | Initial street address | null |
| `initialCity` | `String?` | Initial city | null |
| `initialState` | `String?` | Initial state | null |
| `initialCountry` | `String?` | Initial country | null |
| `initialPostalCode` | `String?` | Initial postal code | null |
| `initialLatitude` | `double?` | Initial latitude | null |
| `initialLongitude` | `double?` | Initial longitude | null |
| `showAllFields` | `bool` | Show city, state, country, postal code fields | true |
| `isLocked` | `bool` | Lock all fields (for business addresses) | false |
| `hintText` | `String?` | Hint text for street address field | 'Search for addresses...' |
| `fieldErrors` | `Map<String, String>?` | Map of field keys to error messages | null |
| `onAddressChanged` | `ValueChanged<AddressFormData>?` | Called when any address field changes | null |
| `onPlaceSelected` | `ValueChanged<LocationResult?>?` | Called when Google Place is selected | null |
| `onLocationSelected` | `ValueChanged<Position?>?` | Called when GPS location is detected | null |
| `onFieldErrorCleared` | `ValueChanged<String>?` | Called when user starts editing a field with an error | null |

### AddressFormData

```dart
class AddressFormData {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool isFromGooglePlaces;
}
```

## Field Error Keys

Use these keys in the `fieldErrors` map:
- `'address'` - Street address field
- `'city'` - City field
- `'state'` - State field
- `'country'` - Country field
- `'postalCode'` - Postal code field

## Country Restrictions

By default, the widget restricts searches to India (IN) and United States (US). This is configured in the widget and can be modified by editing the source code if you need different countries.

## Customization

The widget uses Material Design theming and respects your app's `Theme`:

```dart
MaterialApp(
  theme: ThemeData(
    primaryColor: Colors.blue,
    textTheme: TextTheme(...),
  ),
  ...
)
```

## Requirements

- Flutter SDK: `>=3.3.0`
- Dart SDK: `^3.9.2`
- Dependencies:
  - `geolocator: ^14.0.2`
  - `http: ^1.2.0`

## Platform Setup

### Android

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />

<!-- For GPS location detection -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

Add to `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>

<!-- For GPS location detection -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to auto-fill your address</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs your location to auto-fill your address</string>
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Issues

If you encounter any problems, please file an issue on the [GitHub repository](https://github.com/Brewnbeer/location_picker_plus/issues).

## Changelog

### 3.1.0
- ✨ **NEW**: GPS Location Detection - One-click location with reverse geocoding (works WITHOUT Google API!)
- ✨ **NEW**: `CountryDropdownField` - Select from 250+ countries with flags
- ✨ **NEW**: `StateDropdownField` - Select states/provinces by country
- ✨ **NEW**: `CityDropdownField` - Select cities by state
- ✨ **NEW**: Individual text field widgets (`StreetAddressField`, `CityField`, `StateField`, `CountryField`, `PostalCodeField`)
- 🔍 Searchable dropdowns with instant filtering
- 🗂️ Cascading selection (Country → State → City)
- 📱 Works completely offline with bundled database
- 📍 Includes coordinates for cities
- ⭐ Shows capital cities
- 🔐 Automatic GPS permission handling for Android & iOS
- 🟢 Visual indicators for GPS data (green badge)
- 🔒 Smart field locking for GPS data
- 📦 Exported `CountryModel`, `StateModel`, `CityModel`, and `LocationService`
- 🎨 Enhanced UI with color-coded field locking (blue for Google Places, green for GPS)
- 🐛 Fixed deprecated `withOpacity` calls (now using `withValues`)
- 📚 Comprehensive documentation and examples

### 3.0.0
- **BREAKING**: Removed all previous widgets
- ✨ **NEW**: `CustomStreetAddressField` - Complete address entry widget
- 🔍 Integrated Google Places API for address autocomplete (optional)
- 📍 Complete address field support (street, city, state, country, postal code)
- 🌍 Coordinate capture (latitude, longitude)
- 🔒 Smart field locking from Google Places data
- ⚠️ Field validation and error display
- 🏢 Support for locked business addresses
- 🎨 Simplified API and improved developer experience

## Author

Brewnbeer Team

## Support

⭐ Star this repository if you find it helpful!
