import 'package:flutter/material.dart';
import 'package:location_picker_plus/models/country_model.dart';
import 'package:location_picker_plus/models/state_model.dart';
import 'package:location_picker_plus/models/location_result.dart';
import 'package:location_picker_plus/services/location_service.dart';
import 'package:location_picker_plus/themes/location_picker_plus_theme.dart';

class ManualAddressEntryWidget extends StatefulWidget {
  final Function(LocationResult?)? onLocationChanged;
  final LocationPickerTheme? theme;
  final String addressLabel;
  final String cityLabel;
  final String stateLabel;
  final String countryLabel;
  final String postalCodeLabel;
  final String? addressHint;
  final String? cityHint;
  final String? stateHint;
  final String? countryHint;
  final String? postalCodeHint;
  final LocationResult? initialLocation;
  final bool useDropdownsForCountryState;
  final List<String>? allowedCountries; // ISO country codes or country names
  final bool lockFieldsForGooglePlaces;

  const ManualAddressEntryWidget({
    super.key,
    this.onLocationChanged,
    this.theme,
    this.addressLabel = 'Address',
    this.cityLabel = 'City',
    this.stateLabel = 'State/Province',
    this.countryLabel = 'Country',
    this.postalCodeLabel = 'Postal Code',
    this.addressHint,
    this.cityHint,
    this.stateHint,
    this.countryHint,
    this.postalCodeHint,
    this.initialLocation,
    this.useDropdownsForCountryState = true,
    this.allowedCountries,
    this.lockFieldsForGooglePlaces = true,
  });

  @override
  State<ManualAddressEntryWidget> createState() => _ManualAddressEntryWidgetState();
}

class _ManualAddressEntryWidgetState extends State<ManualAddressEntryWidget> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  final LocationService _locationService = LocationService.instance;

  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  List<CountryModel> _countries = [];
  List<StateModel> _states = [];
  bool _isLoading = false;

  late LocationPickerTheme _theme;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? LocationPickerTheme.defaultTheme();

    // Initialize with provided location
    if (widget.initialLocation != null) {
      _populateFromLocation(widget.initialLocation!);
    }

    // Load countries and states if using dropdowns
    if (widget.useDropdownsForCountryState) {
      _loadCountriesAndStates();
    }

    // Add listeners to text controllers
    _addressController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _stateController.addListener(_onFieldChanged);
    _countryController.addListener(_onFieldChanged);
    _postalCodeController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _populateFromLocation(LocationResult location) {
    _addressController.text = location.address;
    _cityController.text = location.city ?? '';
    _stateController.text = location.state ?? '';
    _countryController.text = location.country ?? '';
    _postalCodeController.text = location.postalCode ?? '';
  }

  Future<void> _loadCountriesAndStates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allCountries = await _locationService.loadCountries();
      final states = await _locationService.loadStates();

      // Filter countries if restrictions are provided
      List<CountryModel> countries = allCountries;
      if (widget.allowedCountries != null && widget.allowedCountries!.isNotEmpty) {
        countries = allCountries.where((country) {
          return widget.allowedCountries!.any((allowed) =>
            country.name.toLowerCase() == allowed.toLowerCase() ||
            country.sortName.toLowerCase() == allowed.toLowerCase()
          );
        }).toList();
      }

      if (mounted) {
        setState(() {
          _countries = countries;
          _states = states;
          _isLoading = false;
        });

        // Try to find matching country/state from initial data
        if (widget.initialLocation != null) {
          _findMatchingCountryAndState();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _findMatchingCountryAndState() {
    if (widget.initialLocation?.country != null) {
      try {
        _selectedCountry = _countries.firstWhere(
          (country) =>
              country.name.toLowerCase() == widget.initialLocation!.country!.toLowerCase(),
        );
      } catch (e) {
        _selectedCountry = null;
      }
    }

    if (widget.initialLocation?.state != null && _selectedCountry != null) {
      try {
        _selectedState = _states.firstWhere(
          (state) =>
              state.name.toLowerCase() == widget.initialLocation!.state!.toLowerCase() &&
              state.countryId == _selectedCountry!.id,
        );
      } catch (e) {
        _selectedState = null;
      }
    }
  }

  void _onFieldChanged() {
    _notifyLocationChange();
  }

  void _onCountryChanged(CountryModel? country) {
    setState(() {
      _selectedCountry = country;
      _selectedState = null; // Reset state when country changes
    });

    if (country != null) {
      _countryController.text = country.name;
    } else {
      _countryController.clear();
    }

    _stateController.clear();
    _notifyLocationChange();
  }

  void _onStateChanged(StateModel? state) {
    setState(() {
      _selectedState = state;
    });

    if (state != null) {
      _stateController.text = state.name;
    } else {
      _stateController.clear();
    }

    _notifyLocationChange();
  }

  void _notifyLocationChange() {
    if (_isValidAddress()) {
      final fullAddress = _buildFullAddress();
      final locationResult = LocationResult(
        latitude: 0.0, // Will be updated when geocoded
        longitude: 0.0, // Will be updated when geocoded
        address: fullAddress,
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
        addressSource: AddressSource.manualEntry,
      );

      widget.onLocationChanged?.call(locationResult);
    } else {
      widget.onLocationChanged?.call(null);
    }
  }

  bool _isValidAddress() {
    return _addressController.text.trim().isNotEmpty &&
           _cityController.text.trim().isNotEmpty &&
           _countryController.text.trim().isNotEmpty;
  }

  String _buildFullAddress() {
    List<String> parts = [];

    if (_addressController.text.trim().isNotEmpty) {
      parts.add(_addressController.text.trim());
    }
    if (_cityController.text.trim().isNotEmpty) {
      parts.add(_cityController.text.trim());
    }
    if (_stateController.text.trim().isNotEmpty) {
      parts.add(_stateController.text.trim());
    }
    if (_postalCodeController.text.trim().isNotEmpty) {
      parts.add(_postalCodeController.text.trim());
    }
    if (_countryController.text.trim().isNotEmpty) {
      parts.add(_countryController.text.trim());
    }

    return parts.join(', ');
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool? enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _theme.labelStyle ?? Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          decoration: (_theme.inputDecoration ?? InputDecoration()).copyWith(
            hintText: hint,
            border: const OutlineInputBorder(),
            filled: enabled == false,
            fillColor: enabled == false ? Colors.grey[100] : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    final isLocked = _isFieldLocked();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.countryLabel,
          style: _theme.labelStyle ?? Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CountryModel>(
          initialValue: _selectedCountry,
          decoration: (_theme.inputDecoration ?? InputDecoration()).copyWith(
            hintText: widget.countryHint,
            border: const OutlineInputBorder(),
            filled: isLocked,
            fillColor: isLocked ? Colors.grey[100] : null,
          ),
          items: _countries.map((country) {
            return DropdownMenuItem<CountryModel>(
              value: country,
              child: Row(
                children: [
                  if (_theme.showFlags == true)
                    Text(
                      country.flagEmoji ?? '🏳️',
                      style: const TextStyle(fontSize: 20),
                    ),
                  if (_theme.showFlags == true) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      country.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: isLocked ? null : _onCountryChanged,
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    final availableStates = _selectedCountry != null
        ? _states.where((state) => state.countryId == _selectedCountry!.id).toList()
        : <StateModel>[];
    final isLocked = _isFieldLocked();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.stateLabel,
          style: _theme.labelStyle ?? Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<StateModel>(
          initialValue: _selectedState,
          decoration: (_theme.inputDecoration ?? InputDecoration()).copyWith(
            hintText: widget.stateHint,
            border: const OutlineInputBorder(),
            filled: isLocked,
            fillColor: isLocked ? Colors.grey[100] : null,
          ),
          items: availableStates.map((state) {
            return DropdownMenuItem<StateModel>(
              value: state,
              child: Text(
                state.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: isLocked ? null : (_selectedCountry != null ? _onStateChanged : null),
          isExpanded: true,
        ),
      ],
    );
  }

  bool _isFieldLocked() {
    return widget.lockFieldsForGooglePlaces &&
           widget.initialLocation != null &&
           widget.initialLocation!.addressSource == AddressSource.googlePlaces;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final isLocked = _isFieldLocked();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _addressController,
          label: widget.addressLabel,
          hint: widget.addressHint ?? 'Enter street address',
          maxLines: 2,
          enabled: !isLocked,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _cityController,
          label: widget.cityLabel,
          hint: widget.cityHint ?? 'Enter city',
          enabled: !isLocked,
        ),
        const SizedBox(height: 16),

        if (widget.useDropdownsForCountryState) ...[
          _buildCountryDropdown(),
          const SizedBox(height: 16),

          _buildStateDropdown(),
          const SizedBox(height: 16),
        ] else ...[
          _buildTextField(
            controller: _countryController,
            label: widget.countryLabel,
            hint: widget.countryHint ?? 'Enter country',
            enabled: !isLocked,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _stateController,
            label: widget.stateLabel,
            hint: widget.stateHint ?? 'Enter state or province',
            enabled: !isLocked,
          ),
          const SizedBox(height: 16),
        ],

        _buildTextField(
          controller: _postalCodeController,
          label: widget.postalCodeLabel,
          hint: widget.postalCodeHint ?? 'Enter postal code',
          keyboardType: TextInputType.text,
          enabled: !isLocked,
        ),

        if (isLocked)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Address selected from Google Places. Fields are locked for accuracy.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}