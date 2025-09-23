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
