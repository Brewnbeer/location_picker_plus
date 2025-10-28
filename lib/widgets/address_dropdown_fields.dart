import 'package:flutter/material.dart';
import '../models/city_model.dart';
import '../models/country_model.dart';
import '../models/state_model.dart';
import '../services/location_service.dart';

/// Dropdown field for selecting a country from the built-in database
class CountryDropdownField extends StatefulWidget {
  final CountryModel? initialValue;
  final ValueChanged<CountryModel?>? onChanged;
  final String? errorText;
  final bool enabled;
  final String label;
  final String hint;

  const CountryDropdownField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.label = 'Country',
    this.hint = 'Select country',
  });

  @override
  State<CountryDropdownField> createState() => _CountryDropdownFieldState();
}

class _CountryDropdownFieldState extends State<CountryDropdownField> {
  List<CountryModel> _countries = [];
  List<CountryModel> _filteredCountries = [];
  bool _isLoading = true;
  CountryModel? _selectedCountry;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialValue;
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await LocationService.instance.loadCountries();
      if (mounted) {
        setState(() {
          _countries = countries;
          _filteredCountries = countries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _countries;
      } else {
        _filteredCountries = _countries
            .where((country) =>
                country.name.toLowerCase().contains(query.toLowerCase()) ||
                country.sortName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showSearchDialog() async {
    _searchController.clear();
    _filteredCountries = _countries;

    final result = await showDialog<CountryModel>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Country'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search country...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setDialogState(() => _filterCountries(value));
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      return ListTile(
                        leading: Text(
                          country.flagEmoji ?? '🌍',
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(country.name),
                        subtitle: Text(country.sortName),
                        onTap: () => Navigator.pop(context, country),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCountry = result;
      });
      widget.onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.enabled && !_isLoading ? _showSearchDialog : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: Icon(
                Icons.public,
                color: widget.enabled
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(
                  color: widget.errorText != null
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
              ),
              filled: true,
              fillColor: widget.enabled ? Colors.white : Colors.grey[100],
            ),
            child: _isLoading
                ? const Text('Loading...')
                : Text(
                    _selectedCountry?.name ?? widget.hint,
                    style: TextStyle(
                      color: _selectedCountry != null
                          ? Colors.black87
                          : Colors.grey[500],
                    ),
                  ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Dropdown field for selecting a state from the built-in database
class StateDropdownField extends StatefulWidget {
  final StateModel? initialValue;
  final String? countryId;
  final ValueChanged<StateModel?>? onChanged;
  final String? errorText;
  final bool enabled;
  final String label;
  final String hint;

  const StateDropdownField({
    super.key,
    this.initialValue,
    this.countryId,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.label = 'State',
    this.hint = 'Select state',
  });

  @override
  State<StateDropdownField> createState() => _StateDropdownFieldState();
}

class _StateDropdownFieldState extends State<StateDropdownField> {
  List<StateModel> _states = [];
  List<StateModel> _filteredStates = [];
  bool _isLoading = true;
  StateModel? _selectedState;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedState = widget.initialValue;
    _loadStates();
  }

  @override
  void didUpdateWidget(StateDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryId != widget.countryId) {
      _selectedState = null;
      _loadStates();
    }
  }

  Future<void> _loadStates() async {
    setState(() => _isLoading = true);

    try {
      await LocationService.instance.loadStates();
      List<StateModel> states;

      if (widget.countryId != null) {
        states = await LocationService.instance
            .getStatesByCountryId(widget.countryId!);
      } else {
        states = await LocationService.instance.loadStates();
      }

      if (mounted) {
        setState(() {
          _states = states;
          _filteredStates = states;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterStates(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStates = _states;
      } else {
        _filteredStates = _states
            .where((state) =>
                state.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showSearchDialog() async {
    if (_states.isEmpty) return;

    _searchController.clear();
    _filteredStates = _states;

    final result = await showDialog<StateModel>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select State'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search state...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setDialogState(() => _filterStates(value));
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredStates.length,
                    itemBuilder: (context, index) {
                      final state = _filteredStates[index];
                      return ListTile(
                        title: Text(state.name),
                        subtitle: state.stateCode != null
                            ? Text(state.stateCode!)
                            : null,
                        onTap: () => Navigator.pop(context, state),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedState = result;
      });
      widget.onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSelect = widget.enabled && !_isLoading && _states.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: canSelect ? _showSearchDialog : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: Icon(
                Icons.map,
                color:
                    canSelect ? Theme.of(context).primaryColor : Colors.grey,
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(
                  color: widget.errorText != null
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
              ),
              filled: true,
              fillColor: canSelect ? Colors.white : Colors.grey[100],
            ),
            child: _isLoading
                ? const Text('Loading...')
                : _states.isEmpty
                    ? const Text('Select country first')
                    : Text(
                        _selectedState?.name ?? widget.hint,
                        style: TextStyle(
                          color: _selectedState != null
                              ? Colors.black87
                              : Colors.grey[500],
                        ),
                      ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Dropdown field for selecting a city from the built-in database
class CityDropdownField extends StatefulWidget {
  final CityModel? initialValue;
  final String? stateId;
  final ValueChanged<CityModel?>? onChanged;
  final String? errorText;
  final bool enabled;
  final String label;
  final String hint;

  const CityDropdownField({
    super.key,
    this.initialValue,
    this.stateId,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.label = 'City',
    this.hint = 'Select city',
  });

  @override
  State<CityDropdownField> createState() => _CityDropdownFieldState();
}

class _CityDropdownFieldState extends State<CityDropdownField> {
  List<CityModel> _cities = [];
  List<CityModel> _filteredCities = [];
  bool _isLoading = true;
  CityModel? _selectedCity;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialValue;
    _loadCities();
  }

  @override
  void didUpdateWidget(CityDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateId != widget.stateId) {
      _selectedCity = null;
      _loadCities();
    }
  }

  Future<void> _loadCities() async {
    setState(() => _isLoading = true);

    try {
      await LocationService.instance.loadCities();
      List<CityModel> cities;

      if (widget.stateId != null) {
        cities =
            await LocationService.instance.getCitiesByStateId(widget.stateId!);
      } else {
        cities = await LocationService.instance.loadCities();
      }

      if (mounted) {
        setState(() {
          _cities = cities;
          _filteredCities = cities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _cities;
      } else {
        _filteredCities = _cities
            .where((city) =>
                city.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showSearchDialog() async {
    if (_cities.isEmpty) return;

    _searchController.clear();
    _filteredCities = _cities;

    final result = await showDialog<CityModel>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select City'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search city...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setDialogState(() => _filterCities(value));
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      return ListTile(
                        title: Text(city.name),
                        trailing: city.isCapital
                            ? const Icon(Icons.star,
                                color: Colors.amber, size: 20)
                            : null,
                        onTap: () => Navigator.pop(context, city),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCity = result;
      });
      widget.onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSelect = widget.enabled && !_isLoading && _cities.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: canSelect ? _showSearchDialog : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: Icon(
                Icons.location_city,
                color:
                    canSelect ? Theme.of(context).primaryColor : Colors.grey,
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(
                  color: widget.errorText != null
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
              ),
              filled: true,
              fillColor: canSelect ? Colors.white : Colors.grey[100],
            ),
            child: _isLoading
                ? const Text('Loading...')
                : _cities.isEmpty
                    ? const Text('Select state first')
                    : Text(
                        _selectedCity?.name ?? widget.hint,
                        style: TextStyle(
                          color: _selectedCity != null
                              ? Colors.black87
                              : Colors.grey[500],
                        ),
                      ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
