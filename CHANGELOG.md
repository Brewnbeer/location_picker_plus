## 2.1.0

### 🚀 Smart Field Management & Country Restrictions

#### New Features
- ✅ **Smart Field Locking**: Automatically lock city/state/country fields when address is selected from Google Places dropdown
- ✅ **Country Restrictions**: Restrict countries in dropdown using country names or ISO codes
- ✅ **Address Source Tracking**: Track whether address came from Google Places, manual entry, or GPS
- ✅ **Conditional Editing**: Manual entries remain fully editable while Google Places selections are protected
- ✅ **Visual Indicators**: Clear UI feedback showing when fields are locked for accuracy

#### Enhanced Components
- 🔄 **LocationResult Model**: Now includes `AddressSource` enum tracking address origin
- 🔒 **ManualAddressEntryWidget**: Smart field locking and country restriction support
- 🌍 **LocationPickerPlusUnifiedWidget**: New parameters for country control and field locking
- 📍 **AddressSource Enum**: `googlePlaces`, `manualEntry`, `gpsLocation` tracking

#### New Parameters
```dart
LocationPickerPlusUnifiedWidget(
  allowedCountries: ['India', 'United States'], // or ['IN', 'US']
  lockFieldsForGooglePlaces: true, // default: true
  onLocationSelected: (location) {
    print('Source: ${location?.addressSource}');
    // AddressSource.googlePlaces, manualEntry, or gpsLocation
  },
)
```

#### Smart Behavior
- **Google Places Selection** → Fields automatically lock (city/state/country/postal code)
- **Manual Entry** → All fields remain fully editable
- **GPS Location** → All fields remain editable
- **Country Filtering** → Only allowed countries appear in dropdown
- **Visual Feedback** → Blue info box shows when fields are locked

#### Technical Improvements
- 🔧 Fixed all Flutter deprecation warnings (`withOpacity` → `withValues`)
- 🧹 Removed unused methods and improved code quality
- 📝 Updated deprecated `value` parameter to `initialValue` in form fields
- 🎯 Enhanced type safety and null handling

#### Breaking Changes
- None - fully backward compatible
- All existing code continues to work unchanged

#### Migration Guide
- No migration needed for existing implementations
- New features are opt-in via new parameters
- `AddressSource` tracking is automatically handled

## 2.0.0

### 🚀 Major New Features - Live Location Detection

#### New Components
- ✅ **LocationDetectorWidget**: Live GPS location detection with geocoding
- ✅ **LocationDetectorService**: Comprehensive location services
- ✅ **LocationModel**: Enhanced location data with full address breakdown
- ✅ **Flexible Detection Modes**: GPS detection, address search, or both

#### Live Location Features
- 🌍 **GPS Location Detection**: Get current location with one tap
- 🔍 **Address Geocoding**: Search any address and get coordinates
- 🏠 **Reverse Geocoding**: Convert coordinates to readable addresses
- 📍 **Forward Geocoding**: Convert addresses to coordinates
- 🔐 **Auto Permission Handling**: Handles all location permissions automatically
- ⚡ **High Accuracy GPS**: Configurable accuracy levels
- 🌐 **Multi-locale Support**: Address detection in multiple languages
- 📱 **Cross-platform**: Full Android and iOS support

#### New Dependencies
- `geolocator: ^14.0.2` - GPS location services
- `geocoding: ^4.0.0` - Address geocoding services
- `permission_handler: ^12.0.1` - Location permission management

#### Enhanced API
```dart
// Live location detection
LocationDetectorWidget(
  mode: LocationDetectorMode.both,
  showCoordinates: true,
  onLocationChanged: (location) {
    print('Lat: ${location?.latitude}, Lng: ${location?.longitude}');
    print('Address: ${location?.fullAddress}');
  },
)

// Service usage
LocationModel? location = await LocationDetectorService.instance
    .getCurrentLocationWithAddress();
```

#### Breaking Changes
- Minimum Flutter version remains `>=3.3.0`
- New permissions required for location features
- Added new dependencies (geolocator, geocoding, permission_handler)

#### Migration Guide
- Existing `LocationPickerWidget` usage unchanged
- New `LocationDetectorWidget` is separate - no migration needed
- Add location permissions to your app if using location detection

#### Platform Support
- **Android**: Requires location permissions in AndroidManifest.xml
- **iOS**: Requires NSLocationWhenInUseUsageDescription in Info.plist
- **Web**: Limited location support (browser-dependent)
- **Desktop**: Windows, macOS, Linux supported

## 1.0.1

### Documentation Update
- Updated repository URLs to point to new GitHub repository
- Fixed package name references in README documentation

## 1.0.0

### Initial Release

#### Features
- ✅ **Two Input Modes**: Dropdown with search OR Real-time autocomplete
- ✅ **Instant Suggestions**: See suggestions as you type (no Enter key needed)
- ✅ **Debounced Performance**: Optimized for smooth typing experience (50ms debounce)
- ✅ **Smart Search**: Built-in search with relevance sorting (exact matches first)
- ✅ **Customizable Themes**: Multiple pre-built themes and full customization support
- ✅ **Flag Emojis & Phone Codes**: Display country flags and phone codes
- ✅ **Flexible Layouts**: Horizontal/vertical layouts with responsive design
- ✅ **Asset-based Data**: Load location data from JSON assets
- ✅ **Enhanced Models**: Rich data models with additional properties (lat/lng, state codes, capitals)
- ✅ **Animation Support**: Smooth transitions and animations
- ✅ **Accessibility**: Screen reader support and keyboard navigation

#### Components Included
- `LocationPickerWidget`: Main widget with full customization
- `AutocompleteDropdown`: Real-time suggestions as you type
- `CustomDropdown`: Traditional dropdown with search
- `LocationPickerTheme`: Comprehensive theming system
- `LocationService`: Efficient data loading and caching
- Enhanced models: `CountryModel`, `StateModel`, `CityModel`

#### Customization Options
- **25+ theme properties** for complete UI control
- **3 pre-built themes**: Default, Material, Cupertino
- **Individual component control**: Show/hide country, state, city
- **Custom hints and labels** for each field
- **Flexible positioning** and spacing options
- **Custom asset paths** for your own location data

#### Technical Features
- **Efficient caching** with singleton pattern
- **Optimized filtering** with smart relevance sorting
- **Debounced input** for better performance
- **Overlay positioning** with screen edge detection
- **Memory efficient** list handling
- **Error handling** with user-friendly messages

#### Assets Included
- Complete country list with flags and phone codes
- State/province data for major countries
- City data with geographic information
- JSON format for easy customization

### Example Usage

```dart
// Autocomplete mode
LocationPickerWidget(
  useAutocomplete: true,
  onCountryChanged: (country) => print(country?.name),
)

// Dropdown mode
LocationPickerWidget(
  useAutocomplete: false,
  theme: LocationPickerTheme.materialTheme(),
  onCountryChanged: (country) => print(country?.name),
)
```
