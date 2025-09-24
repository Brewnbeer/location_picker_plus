# Location Picker

A highly customizable Flutter plugin for selecting country, state, and city with extensive UI customization options.

## Features

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

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  location_picker: ^0.0.1
```

## Usage

### Basic Usage

```dart
import 'package:location_picker/location_picker.dart';

LocationPickerWidget(
  onCountryChanged: (country) {
    print('Selected country: ${country?.name}');
  },
  onStateChanged: (state) {
    print('Selected state: ${state?.name}');
  },
  onCityChanged: (city) {
    print('Selected city: ${city?.name}');
  },
)
```

### Autocomplete Mode (Real-time suggestions as you type)

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

