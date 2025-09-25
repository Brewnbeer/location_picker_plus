# Location Picker Plus

A comprehensive Flutter plugin for location selection with **POWERFUL WIDGETS**:
1. **Traditional Picker** - Dropdown/autocomplete selection from predefined data
2. **🆕 Live Location Detection** - GPS location detection with geocoding support
3. **🔥 Unified Widget** - All-in-one widget with smart field management and Google Places

## 🚀 Two Widgets, Endless Possibilities

### 📍 LocationPickerWidget (Traditional Selection)
Select from predefined country, state, and city data with beautiful UI customization.

### 🌍 LocationDetectorWidget (NEW - Live Location)
Detect current GPS location or search any address with real-time geocoding.

## Features

### Traditional Location Picker
- ✓ **Two Input Modes** - Dropdown with search OR Real-time autocomplete
- ✓ **Instant Suggestions** - See suggestions as you type (no Enter key needed)
- ✓ **Debounced Performance** - Optimized for smooth typing experience
- ✓ **Customizable Themes** - Multiple pre-built themes and full customization support
- ✓ **Smart Search** - Built-in search with relevance sorting
- ✓ **Flag Emojis & Phone Codes** - Display country flags and phone codes
- ✓ **Flexible Layouts** - Horizontal/vertical layouts with responsive design
- ✓ **Asset-based Data** - Load location data from JSON assets
- ✓ **Enhanced Models** - Rich data models with additional properties
- ✓ **Animation Support** - Smooth transitions and animations
- ✓ **Accessibility** - Screen reader support and keyboard navigation

### 🆕 Live Location Detection
- 🌍 **GPS Location Detection** - Get current location with one tap
- 🔍 **Address Geocoding** - Search any address and get coordinates
- 🏠 **Reverse Geocoding** - Convert coordinates to readable addresses
- 📍 **Forward Geocoding** - Convert addresses to coordinates
- 🔐 **Auto Permission Handling** - Handles all location permissions automatically
- ⚡ **High Accuracy GPS** - Configurable accuracy levels
- 🌐 **Multi-locale Support** - Address detection in multiple languages
- 📱 **Cross-platform** - Full Android and iOS support
- 🎛️ **Flexible Modes** - GPS only, search only, or both
- 🎨 **Full UI Customization** - Match your app's design

### 🔥 NEW v2.1.0 - Smart Field Management
- 🔒 **Smart Field Locking** - Auto-lock fields when address selected from Google Places
- 🌏 **Country Restrictions** - Limit dropdown to specific countries (names or ISO codes)
- 📍 **Address Source Tracking** - Know if address came from Google Places, GPS, or manual entry
- 🎯 **Conditional Editing** - Google Places = locked, Manual/GPS = editable
- 👁️ **Visual Indicators** - Clear UI showing when fields are locked for accuracy

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  location_picker_plus: ^2.1.0
```

### 📱 Platform Setup (for Live Location Features)

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to detect your current location.</string>
```

## Usage

### 🆕 Live Location Detection

#### Quick Start
```dart
import 'package:location_picker_plus/location_picker_plus.dart';

LocationDetectorWidget(
  mode: LocationDetectorMode.both, // GPS + Address search
  showCoordinates: true,
  onLocationChanged: (location) {
    print('Lat: ${location?.latitude}, Lng: ${location?.longitude}');
    print('Address: ${location?.fullAddress}');
    print('City: ${location?.locality}');
    print('State: ${location?.administrativeArea}');
    print('Country: ${location?.country}');
  },
)
```

#### GPS Detection Only
```dart
LocationDetectorWidget(
  mode: LocationDetectorMode.currentLocation,
  onCoordinatesChanged: (lat, lng) {
    print('Coordinates: $lat, $lng');
  },
)
```

#### Address Search Only
```dart
LocationDetectorWidget(
  mode: LocationDetectorMode.addressSearch,
  addressSearchHint: 'Enter address, city, or landmark...',
  onLocationChanged: (location) {
    // Use detected location data
  },
)
```

#### Advanced Usage with Service
```dart
// Direct service usage for custom UI
LocationDetectorService service = LocationDetectorService.instance;

// Get current location
LocationModel? location = await service.getCurrentLocationWithAddress();
print('Current city: ${location?.locality}');

// Search address
LocationModel? searched = await service.getCoordinatesFromAddress('New York');
print('NYC coordinates: ${searched?.latitude}, ${searched?.longitude}');
```

### 🔥 Unified Location Picker with Smart Field Management (NEW v2.1.0)

The ultimate all-in-one widget combining Google Places, GPS detection, and manual entry with intelligent field management.

#### 🎯 Smart Field Behavior
- **Google Places Selection** → Fields automatically lock for accuracy
- **Manual Entry** → All fields remain fully editable
- **GPS Location** → All fields remain editable
- **Country Restrictions** → Limit countries in dropdown

#### Quick Start - All Modes
```dart
LocationPickerPlusUnifiedWidget(
  mode: LocationPickerMode.all, // Show all 3 tabs
  googlePlacesApiKey: 'your-api-key',
  allowedCountries: ['India', 'United States'], // Optional restriction
  lockFieldsForGooglePlaces: true, // Default: true
  onLocationSelected: (location) {
    print('Selected: ${location?.address}');
    print('Source: ${location?.addressSource}'); // googlePlaces, manualEntry, or gpsLocation

    if (location?.addressSource == AddressSource.googlePlaces) {
      print('Address from Google Places - fields are locked');
    } else {
      print('Manual/GPS address - fields are editable');
    }
  },
)
```

#### Google Places Only Mode
```dart
LocationPickerPlusUnifiedWidget(
  mode: LocationPickerMode.googlePlaces,
  googlePlacesApiKey: 'your-api-key',
  country: 'US', // Restrict to US addresses
  placesTypes: ['establishment', 'geocode'],
  onLocationSelected: (location) {
    // Google Places result with locked fields in manual entry
  },
)
```

#### Manual Entry with Country Restrictions
```dart
LocationPickerPlusUnifiedWidget(
  mode: LocationPickerMode.manualEntry,
  allowedCountries: ['IN', 'US', 'CA'], // ISO codes or full names
  lockFieldsForGooglePlaces: false, // Allow editing Google Places results
  onLocationSelected: (location) {
    // Manual entry result - always editable
  },
)
```

#### GPS + Manual Entry (No Google Places)
```dart
LocationPickerPlusUnifiedWidget(
  mode: LocationPickerMode.all,
  googlePlacesApiKey: null, // Disable Google Places tab
  autoDetectOnInit: true, // Auto-detect GPS on load
  allowedCountries: ['India', 'United States'],
  onLocationSelected: (location) {
    // GPS or manual entry result
  },
)
```

#### Address Source Tracking
```dart
onLocationSelected: (LocationResult? location) {
  switch (location?.addressSource) {
    case AddressSource.googlePlaces:
      print('🌐 From Google Places - High accuracy, fields locked');
      break;
    case AddressSource.manualEntry:
      print('✏️ Manual entry - User can edit all fields');
      break;
    case AddressSource.gpsLocation:
      print('📍 From GPS - Detected location, fields editable');
      break;
  }
}
```

### 📍 Traditional Location Picker

#### Basic Usage
```dart
LocationPickerWidget(
  onCountryChanged: (country) {
    print('Selected country: ${country?.name}');
  },
  onStateChanged: (state) {
    print('Selected state: ${state?.name}');
  },
  onCityChanged: (city) {
    print('Selected city: ${city?.name}');
    // Access latitude/longitude from city data
    if (city?.latitude != null) {
      print('City coordinates: ${city?.latitude}, ${city?.longitude}');
    }
  },
)
```

#### Autocomplete Mode (Real-time suggestions as you type)

```dart
LocationPickerWidget(
  useAutocomplete: true, // Enable autocomplete mode
  countryHint: 'Type country name...',
  stateHint: 'Type state name...',
  cityHint: 'Type city name...',
  onCountryChanged: (country) {
    // Handle country selection
  },
)
```

### Dropdown Mode (Traditional dropdown with search)

```dart
LocationPickerWidget(
  useAutocomplete: false, // Traditional dropdown mode
  theme: LocationPickerTheme.materialTheme().copyWith(
    showFlags: true,
    showPhoneCodes: true,
    borderRadius: BorderRadius.circular(12),
  ),
  countryLabel: 'Country',
  stateLabel: 'State/Province',
  cityLabel: 'City',
  onCountryChanged: (country) {
    // Handle country selection
  },
)
```

### Country Only Picker

```dart
LocationPickerWidget(
  useAutocomplete: true, // Or false for dropdown
  showState: false,
  showCity: false,
  countryHint: 'Type country name...',
  onCountryChanged: (country) {
    // Handle country selection
  },
)
```

### Horizontal Layout

```dart
Row(
  children: [
    Expanded(
      child: LocationPickerWidget(
        showState: false,
        showCity: false,
        countryLabel: 'Country',
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: LocationPickerWidget(
        showCountry: false,
        showCity: false,
        stateLabel: 'State',
      ),
    ),
  ],
)
```

## 🔄 Combining Both Widgets

You can use both widgets together for maximum flexibility:

```dart
Column(
  children: [
    // Live location detection
    LocationDetectorWidget(
      mode: LocationDetectorMode.currentLocation,
      onLocationChanged: (location) {
        // Auto-fill traditional picker based on detected location
      },
    ),

    SizedBox(height: 20),

    // Traditional picker for manual selection
    LocationPickerWidget(
      useAutocomplete: true,
      onCountryChanged: (country) {
        // Handle manual selection
      },
    ),
  ],
)
```

## Customization

### Available Themes

```dart
// Default theme
LocationPickerTheme.defaultTheme()

// Material Design theme
LocationPickerTheme.materialTheme()

// Cupertino theme
LocationPickerTheme.cupertinoTheme()

// Custom theme
LocationPickerTheme(
  inputDecoration: InputDecoration(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.all(16),
  ),
  dropdownBackgroundColor: Colors.white,
  itemHighlightColor: Colors.blue.withOpacity(0.1),
  borderRadius: BorderRadius.circular(8),
  elevation: 4,
  showFlags: true,
  showPhoneCodes: false,
  maxHeight: 250,
  animationDuration: Duration(milliseconds: 200),
)
```

## Input Modes

### Autocomplete Mode (`useAutocomplete: true`)
- **Real-time suggestions** appear as you type
- **No Enter key required** - suggestions show instantly
- **Debounced for performance** - optimized for smooth typing
- **Smart relevance sorting** - exact matches first, then starts-with, then contains
- **Auto-clear functionality** - click X to clear selection

### Dropdown Mode (`useAutocomplete: false`)
- **Traditional dropdown** with search functionality inside
- **Click to open** dropdown with search box
- **Keyboard navigation** support
- **More familiar UX** for users expecting dropdowns

## Widget Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `useAutocomplete` | `bool` | Enable autocomplete mode (true) or dropdown mode (false). Default: true |
| `showCountry` | `bool` | Show country picker. Default: true |
| `showState` | `bool` | Show state picker. Default: true |
| `showCity` | `bool` | Show city picker. Default: true |
| `countryHint` | `String?` | Hint text for country field |
| `stateHint` | `String?` | Hint text for state field |
| `cityHint` | `String?` | Hint text for city field |
| `theme` | `LocationPickerTheme?` | Custom theme for styling |
| `onCountryChanged` | `Function(CountryModel?)?` | Callback when country is selected |
| `onStateChanged` | `Function(StateModel?)?` | Callback when state is selected |
| `onCityChanged` | `Function(CityModel?)?` | Callback when city is selected |

## Models

### CountryModel
```dart
CountryModel(
  id: '1',
  sortName: 'US',
  name: 'United States',
  phoneCode: '1',
  flagEmoji: '🇺🇸',
  capital: 'Washington, D.C.',
  currency: 'USD',
)
```

### StateModel
```dart
StateModel(
  id: '1',
  name: 'California',
  countryId: '1',
  stateCode: 'CA',
  type: 'State',
)
```

### CityModel
```dart
CityModel(
  id: '1',
  name: 'Los Angeles',
  stateId: '1',
  latitude: '34.0522',
  longitude: '-118.2437',
  isCapital: false,
)
```

### 🆕 LocationModel (Live Location)
```dart
LocationModel(
  latitude: 34.0522,
  longitude: -118.2437,
  address: '123 Main St, Los Angeles, CA 90210, USA',
  street: '123 Main St',
  locality: 'Los Angeles',        // City
  administrativeArea: 'CA',       // State
  country: 'United States',
  postalCode: '90210',
  countryCode: 'US',
)
```

### 🔥 LocationResult (NEW v2.1.0 - Unified Widget)
```dart
LocationResult(
  latitude: 34.0522,
  longitude: -118.2437,
  address: '123 Main St, Los Angeles, CA 90210, USA',
  city: 'Los Angeles',
  state: 'California',
  country: 'United States',
  postalCode: '90210',
  addressSource: AddressSource.googlePlaces, // googlePlaces, manualEntry, or gpsLocation
)
```

### AddressSource Enum
```dart
enum AddressSource {
  googlePlaces,  // Address selected from Google Places dropdown
  manualEntry,   // User manually entered address
  gpsLocation,   // Address detected from GPS coordinates
}
```

## 🔥 LocationPickerPlusUnifiedWidget Parameters (NEW v2.1.0)

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | `LocationPickerMode` | Widget mode: `googlePlaces`, `currentLocation`, `manualEntry`, or `all`. Default: `all` |
| `googlePlacesApiKey` | `String?` | Google Places API key for address search |
| `allowedCountries` | `List<String>?` | Restrict countries in dropdown (names or ISO codes like `['IN', 'US']`) |
| `lockFieldsForGooglePlaces` | `bool` | Lock manual entry fields when Google Places address is selected. Default: `true` |
| `onLocationSelected` | `Function(LocationResult?)?` | Called when location is selected from any source |
| `country` | `String?` | Restrict Google Places to specific country (ISO code) |
| `placesTypes` | `List<String>` | Google Places types filter. Default: `[]` |
| `placesHintText` | `String` | Google Places search hint. Default: 'Search for a place...' |
| `useDropdownsForCountryState` | `bool` | Use dropdowns for country/state in manual entry. Default: `true` |
| `autoDetectOnInit` | `bool` | Auto-detect GPS location on widget load. Default: `false` |
| `showCoordinates` | `bool` | Show coordinates in location display. Default: `true` |
| `theme` | `LocationPickerTheme?` | Custom theme for styling |

## 📊 LocationDetectorWidget Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | `LocationDetectorMode` | Detection mode: `currentLocation`, `addressSearch`, or `both` |
| `showCoordinates` | `bool` | Show latitude/longitude in results. Default: true |
| `showFullAddress` | `bool` | Show complete address breakdown. Default: true |
| `autoDetectOnInit` | `bool` | Auto-detect location on widget load. Default: false |
| `accuracy` | `LocationAccuracy` | GPS accuracy level. Default: `LocationAccuracy.high` |
| `timeLimit` | `Duration?` | Max time to wait for location. Default: null |
| `currentLocationLabel` | `String` | Label for GPS button. Default: 'Current Location' |
| `addressSearchLabel` | `String` | Label for search field. Default: 'Search Address' |
| `addressSearchHint` | `String?` | Placeholder for search field |
| `theme` | `LocationPickerTheme?` | Custom theme for styling |
| `onLocationChanged` | `Function(LocationModel?)?` | Called when location is detected/searched |
| `onAddressChanged` | `Function(String)?` | Called when address changes |
| `onCoordinatesChanged` | `Function(double, double)?` | Called when coordinates change |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

