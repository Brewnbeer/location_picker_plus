# Location Picker Plus v3.1.0 Release Notes

## 🎉 Major New Features

Version 3.1.0 brings powerful new capabilities to Location Picker Plus, including GPS location detection without Google API requirements, local database dropdown fields, and individual field widgets for maximum flexibility.

---

## 📍 GPS Location Detection (No Google API Required!)

### What's New
- One-click GPS location detection with automatic reverse geocoding
- Works completely offline from Google Places API using device GPS + `geocoding` package
- Automatic permission handling for Android & iOS
- Real-time address field population from GPS coordinates
- Visual indicators (green badge) when address is from GPS
- Smart field locking when GPS data is used

### How to Use

Enable GPS detection in `CustomStreetAddressField`:

```dart
CustomStreetAddressField(
  googleApiKey: 'YOUR_API_KEY',
  enableLocationPicker: true,  // Enable GPS detection
  onLocationSelected: (position) {
    print('GPS: ${position?.latitude}, ${position?.longitude}');
  },
  onAddressChanged: (addressData) {
    print('Address: ${addressData.street}');
  },
)
```

### Platform Setup Required

**Android** - Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** - Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to provide address suggestions.</string>
```

---

## 🗂️ Local Database Dropdown Fields

### What's New
- **CountryDropdownField** - Select from 250+ countries with flags
- **StateDropdownField** - Select states/provinces by country
- **CityDropdownField** - Select cities by state
- Searchable dropdowns with instant filtering
- Cascading selection (Country → State → City)
- Includes coordinates for cities
- Shows capital cities with star indicator
- Works completely offline with bundled database
- Optimized with search indices and caching

### How to Use

```dart
import 'package:location_picker_plus/location_picker_plus.dart';

class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  CityModel? _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Country Dropdown
        CountryDropdownField(
          initialValue: _selectedCountry,
          onChanged: (country) {
            setState(() {
              _selectedCountry = country;
              _selectedState = null;
              _selectedCity = null;
            });
          },
        ),

        // State Dropdown (filtered by country)
        StateDropdownField(
          initialValue: _selectedState,
          countryId: _selectedCountry?.id,
          onChanged: (state) {
            setState(() {
              _selectedState = state;
              _selectedCity = null;
            });
          },
        ),

        // City Dropdown (filtered by state)
        CityDropdownField(
          initialValue: _selectedCity,
          stateId: _selectedState?.id,
          onChanged: (city) {
            setState(() {
              _selectedCity = city;
            });
          },
        ),
      ],
    );
  }
}
```

### Features
- **Searchable**: Type to filter options instantly
- **Cascading**: Selecting country filters states, selecting state filters cities
- **Rich Data**: Access country flags, phone codes, capitals, coordinates, and more
- **Offline**: No internet connection required
- **Performant**: Optimized for large datasets with thousands of locations

---

## 📝 Individual Text Field Widgets

### What's New
- **StreetAddressField** - Street address with 2-line support
- **CityField** - City text input
- **StateField** - State/Province text input
- **CountryField** - Country text input
- **PostalCodeField** - Postal/ZIP code with numeric keyboard
- **AddressTextField** - Generic base widget for custom fields

### How to Use

Perfect for custom layouts where you want individual control:

```dart
import 'package:location_picker_plus/location_picker_plus.dart';

class CustomAddressForm extends StatelessWidget {
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final postalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreetAddressField(
          controller: streetController,
          onChanged: (value) => print('Street: $value'),
        ),
        SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: CityField(
                controller: cityController,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StateField(
                controller: stateController,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: CountryField(
                controller: countryController,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: PostalCodeField(
                controller: postalController,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Features
- **Consistent Styling**: Material Design with consistent theming
- **Error Display**: Built-in error text support
- **Controller Integration**: Full TextEditingController support
- **Keyboard Types**: Appropriate keyboard for each field type
- **Icons**: Meaningful prefix icons for each field

---

## 🎨 Enhanced UI & Visual Feedback

### Field Locking Indicators
Enhanced field locking with color-coded visual feedback:

- **🔵 Blue Badge** - Address from Google Places API
- **🟢 Green Badge** - Address from GPS detection
- **🟠 Orange Badge** - Locked business/custom address

### Improved Disabled States
- Better visual feedback for locked fields
- Clear indication of field source (Google Places vs GPS vs Manual)
- Improved accessibility for all field states

---

## 📦 API Changes & New Exports

### New Model Exports
```dart
import 'package:location_picker_plus/location_picker_plus.dart';

// Now available:
CountryModel country;
StateModel state;
CityModel city;
```

### New Service Export
```dart
import 'package:location_picker_plus/location_picker_plus.dart';

// Access the local database service directly
final countries = await LocationService.instance.loadCountries();
final states = await LocationService.instance.getStatesByCountryId(countryId);
final cities = await LocationService.instance.getCitiesByStateId(stateId);
```

### New Widget Exports
All new widgets are automatically available when you import the package:
- `CountryDropdownField`, `StateDropdownField`, `CityDropdownField`
- `StreetAddressField`, `CityField`, `StateField`, `CountryField`, `PostalCodeField`
- `AddressTextField` (base widget)

### New Parameters for CustomStreetAddressField
```dart
CustomStreetAddressField(
  // Existing parameters...

  // NEW: Enable GPS location detection
  enableLocationPicker: true,  // default: false

  // NEW: GPS location callback
  onLocationSelected: (Position? position) {
    // Called when GPS location is detected
  },
)
```

---

## 📱 Enhanced Example App

The example app now includes **3 comprehensive demos**:

### 1. Complete Address Entry Demo
- Google Places API autocomplete
- GPS location detection
- Manual address entry
- Real-time field validation
- Shows all address sources working together

### 2. Dropdown Fields Demo
- Country, State, City cascading dropdowns
- Searchable selection dialogs
- Display of rich location data (flags, coordinates, capitals)
- Offline database demonstration

### 3. Individual Text Fields Demo
- Custom layout with individual field widgets
- Shows how to build custom forms
- Demonstrates controller usage and validation

---

## 🐛 Bug Fixes

- Fixed coordinate preservation in locked address mode
- Improved field state management when switching between input modes
- Fixed deprecated `withOpacity` calls (now using `withValues`)
- Fixed icon references in example app
- Better error handling for location permissions

---

## 🔧 Technical Improvements

### GPS Operations
- Better state management for GPS operations
- Improved error handling for location permissions
- Graceful degradation when permissions are denied

### Dropdown Performance
- Optimized dropdown search with lazy loading
- Enhanced memory efficiency for large location lists
- Search indices for faster filtering

### Code Quality
- Removed deprecated API usage
- Improved null safety throughout
- Better widget lifecycle management

---

## 📚 Migration Guide

### From 3.0.0 to 3.1.0

This is a **non-breaking** release. All existing code will continue to work without changes.

### To Use New Features

**GPS Detection:**
```dart
// Old way (still works)
CustomStreetAddressField(
  googleApiKey: 'YOUR_API_KEY',
)

// New way with GPS
CustomStreetAddressField(
  googleApiKey: 'YOUR_API_KEY',
  enableLocationPicker: true,  // Add this
  onLocationSelected: (position) {  // Add this callback
    // Handle GPS data
  },
)
```

**Dropdown Fields:**
```dart
// New feature - add to your forms
CountryDropdownField(
  onChanged: (country) {
    print('Selected: ${country?.name}');
  },
)
```

**Individual Fields:**
```dart
// New feature - use for custom layouts
StreetAddressField(
  controller: myController,
  onChanged: (value) => print(value),
)
```

---

## 📋 Platform Requirements

### Minimum Versions (Unchanged)
- Flutter: `>=3.3.0`
- Dart: `^3.9.2`

### Platforms Supported
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

### For GPS Features (Optional)
If you enable `enableLocationPicker: true`, you need to:

1. **Android**: Add location permissions to `AndroidManifest.xml`
2. **iOS**: Add location usage description to `Info.plist`
3. **Web**: Browser will request permission automatically
4. **Desktop**: Platform-specific permission handling

---

## 🙏 Acknowledgments

Thank you to all contributors and users who provided feedback and feature requests!

---

## 📖 Documentation

- **Full README**: [GitHub Repository](https://github.com/Brewnbeer/location_picker_plus#readme)
- **Issue Tracker**: [Report Issues](https://github.com/Brewnbeer/location_picker_plus/issues)
- **Changelog**: [CHANGELOG.md](https://github.com/Brewnbeer/location_picker_plus/blob/main/CHANGELOG.md)

---

## 🚀 What's Next?

We're constantly improving Location Picker Plus. Stay tuned for future updates!

**Coming Soon:**
- Map integration for visual location selection
- Additional geocoding providers
- Enhanced offline capabilities
- More customization options

---

**Version**: 3.1.0
**Release Date**: 2025-01-XX
**Package**: location_picker_plus
**Homepage**: https://github.com/Brewnbeer/location_picker_plus
