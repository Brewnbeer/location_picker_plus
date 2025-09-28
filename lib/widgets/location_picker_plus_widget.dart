import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location_picker_plus/models/city_model.dart';
import 'package:location_picker_plus/models/country_model.dart';
import 'package:location_picker_plus/models/state_model.dart';
import 'package:location_picker_plus/services/location_service.dart';
import 'package:location_picker_plus/themes/location_picker_plus_theme.dart';

import 'autocomplete_dropdown.dart';

class LocationPickerWidget extends StatefulWidget {
  final CountryModel? initialCountry;
  final StateModel? initialState;
  final CityModel? initialCity;
  final Function(CountryModel?)? onCountryChanged;
  final Function(StateModel?)? onStateChanged;
  final Function(CityModel?)? onCityChanged;
  final LocationPickerTheme? theme;
  final bool showCountry;
  final bool showState;
  final bool showCity;
  final String? countryHint;
  final String? stateHint;
  final String? cityHint;
  final String? countryLabel;
  final String? stateLabel;
  final String? cityLabel;
  final EdgeInsetsGeometry? spacing;
  final MainAxisAlignment? alignment;
  final CrossAxisAlignment? crossAlignment;
  final bool isExpanded;
  final String? customCountryAssetPath;
  final String? customStateAssetPath;
  final String? customCityAssetPath;
  final bool useAutocomplete;

  const LocationPickerWidget({
    super.key,
    this.initialCountry,
    this.initialState,
    this.initialCity,
    this.onCountryChanged,
    this.onStateChanged,
    this.onCityChanged,
    this.theme,
    this.showCountry = true,
    this.showState = true,
    this.showCity = true,
    this.countryHint = 'Select Country',
    this.stateHint = 'Select State',
    this.cityHint = 'Select City',
    this.countryLabel,
    this.stateLabel,
    this.cityLabel,
    this.spacing,
    this.alignment,
    this.crossAlignment,
    this.isExpanded = true,
    this.customCountryAssetPath,
    this.customStateAssetPath,
    this.customCityAssetPath,
    this.useAutocomplete = true,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final LocationService _locationService = LocationService.instance;

  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  CityModel? _selectedCity;

  List<CountryModel> _countries = [];
  List<StateModel> _states = [];
  List<CityModel> _cities = [];

  bool _isLoadingCountries = false;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;

  late LocationPickerTheme _theme;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? LocationPickerTheme.defaultTheme();
    _selectedCountry = widget.initialCountry;
    _selectedState = widget.initialState;
    _selectedCity = widget.initialCity;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.showCountry) {
      await _loadCountries();
    }
    if (widget.showState && _selectedCountry != null) {
      await _loadStates(_selectedCountry!.id);
    }
    if (widget.showCity && _selectedState != null) {
      await _loadCities(_selectedState!.id);
    }
  }

  Future<void> _loadCountries() async {
    setState(() => _isLoadingCountries = true);
    try {
      final countries = await _locationService.loadCountries(
        assetPath:
            widget.customCountryAssetPath ??
            'packages/location_picker_plus/assets/country.json',
      );
      setState(() {
        _countries = countries;
        _isLoadingCountries = false;
      });
    } catch (e) {
      setState(() => _isLoadingCountries = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading countries: $e')));
      }
    }
  }

  Future<void> _loadStates(String countryId) async {
    setState(() => _isLoadingStates = true);
    try {
      await _locationService.loadStates(
        assetPath:
            widget.customStateAssetPath ??
            'packages/location_picker_plus/assets/state.json',
      );
      final states = await _locationService.getStatesByCountryId(countryId);
      setState(() {
        _states = states;
        _isLoadingStates = false;
      });
    } catch (e) {
      setState(() => _isLoadingStates = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading states: $e')));
      }
    }
  }

  Future<void> _loadCities(String stateId) async {
    setState(() => _isLoadingCities = true);
    try {
      await _locationService.loadCities(
        assetPath:
            widget.customCityAssetPath ??
            'packages/location_picker_plus/assets/city.json',
      );
      final cities = await _locationService.getCitiesByStateId(stateId);
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() => _isLoadingCities = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading cities: $e')));
      }
    }
  }

  void _onCountryChanged(CountryModel? country) {
    setState(() {
      _selectedCountry = country;
      _selectedState = null;
      _selectedCity = null;
      _states.clear();
      _cities.clear();
    });

    widget.onCountryChanged?.call(country);
    widget.onStateChanged?.call(null);
    widget.onCityChanged?.call(null);

    if (country != null && widget.showState) {
      _loadStates(country.id);
    }
  }

  void _onStateChanged(StateModel? state) {
    setState(() {
      _selectedState = state;
      _selectedCity = null;
      _cities.clear();
    });

    widget.onStateChanged?.call(state);
    widget.onCityChanged?.call(null);

    if (state != null && widget.showCity) {
      _loadCities(state.id);
    }
  }

  void _onCityChanged(CityModel? city) {
    setState(() {
      _selectedCity = city;
    });
    widget.onCityChanged?.call(city);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.alignment ?? MainAxisAlignment.start,
      crossAxisAlignment: widget.crossAlignment ?? CrossAxisAlignment.stretch,
      children: [
        if (widget.showCountry) ...[
          _buildCountryDropdown(),
          SizedBox(height: widget.spacing?.horizontal ?? 16),
        ],
        if (widget.showState) ...[
          _buildStateDropdown(),
          SizedBox(height: widget.spacing?.horizontal ?? 16),
        ],
        if (widget.showCity) _buildCityDropdown(),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.countryLabel != null) ...[
          Text(
            widget.countryLabel!,
            style: LocationPickerStyle.getLabelStyle(_theme, context),
          ),
          const SizedBox(height: 8),
        ],
        widget.useAutocomplete
            ? AutocompleteDropdown<CountryModel>(
                value: _selectedCountry,
                items: _countries,
                onChanged: _onCountryChanged,
                hint: widget.countryHint ?? 'Type country name...',
                isLoading: _isLoadingCountries,
                theme: _theme,
                isExpanded: widget.isExpanded,
                itemBuilder: (country) => _buildCountryItem(country),
                displayTextBuilder: (country) => country.name,
                searchFilter: (country, query) =>
                    country.name.toLowerCase().contains(query) ||
                    country.sortName.toLowerCase().contains(query),
              )
            : CustomDropdown<CountryModel>(
                value: _selectedCountry,
                items: _countries,
                onChanged: _onCountryChanged,
                hint: widget.countryHint ?? 'Select Country',
                isLoading: _isLoadingCountries,
                theme: _theme,
                isExpanded: widget.isExpanded,
                itemBuilder: (country) => _buildCountryItem(country),
                searchFilter: (country, query) =>
                    country.name.toLowerCase().contains(query.toLowerCase()) ||
                    country.sortName.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.stateLabel != null) ...[
          Text(
            widget.stateLabel!,
            style: LocationPickerStyle.getLabelStyle(_theme, context),
          ),
          const SizedBox(height: 8),
        ],
        widget.useAutocomplete
            ? AutocompleteDropdown<StateModel>(
                value: _selectedState,
                items: _states,
                onChanged: _onStateChanged,
                hint: widget.stateHint ?? 'Type state name...',
                isLoading: _isLoadingStates,
                theme: _theme,
                isExpanded: widget.isExpanded,
                enabled: _selectedCountry != null,
                itemBuilder: (state) => _buildStateItem(state),
                displayTextBuilder: (state) => state.name,
                searchFilter: (state, query) =>
                    state.name.toLowerCase().contains(query),
              )
            : CustomDropdown<StateModel>(
                value: _selectedState,
                items: _states,
                onChanged: _onStateChanged,
                hint: widget.stateHint ?? 'Select State',
                isLoading: _isLoadingStates,
                theme: _theme,
                isExpanded: widget.isExpanded,
                enabled: _selectedCountry != null,
                itemBuilder: (state) => _buildStateItem(state),
                searchFilter: (state, query) =>
                    state.name.toLowerCase().contains(query.toLowerCase()),
              ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.cityLabel != null) ...[
          Text(
            widget.cityLabel!,
            style: LocationPickerStyle.getLabelStyle(_theme, context),
          ),
          const SizedBox(height: 8),
        ],
        widget.useAutocomplete
            ? AutocompleteDropdown<CityModel>(
                value: _selectedCity,
                items: _cities,
                onChanged: _onCityChanged,
                hint: widget.cityHint ?? 'Type city name...',
                isLoading: _isLoadingCities,
                theme: _theme,
                isExpanded: widget.isExpanded,
                enabled: _selectedState != null,
                itemBuilder: (city) => _buildCityItem(city),
                displayTextBuilder: (city) => city.name,
                searchFilter: (city, query) =>
                    city.name.toLowerCase().contains(query),
              )
            : CustomDropdown<CityModel>(
                value: _selectedCity,
                items: _cities,
                onChanged: _onCityChanged,
                hint: widget.cityHint ?? 'Select City',
                isLoading: _isLoadingCities,
                theme: _theme,
                isExpanded: widget.isExpanded,
                enabled: _selectedState != null,
                itemBuilder: (city) => _buildCityItem(city),
                searchFilter: (city, query) =>
                    city.name.toLowerCase().contains(query.toLowerCase()),
              ),
      ],
    );
  }

  Widget _buildCountryItem(CountryModel country) {
    return Row(
      children: [
        if (_theme.showFlags && country.flagEmoji != null) ...[
          Text(country.flagEmoji!, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            country.name,
            style: LocationPickerStyle.getItemTextStyle(_theme, context),
          ),
        ),
        if (_theme.showPhoneCodes) ...[
          const SizedBox(width: 8),
          Text(
            '+${country.phoneCode}',
            style: LocationPickerStyle.getItemTextStyle(
              _theme,
              context,
            ).copyWith(color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildStateItem(StateModel state) {
    return Row(
      children: [
        Expanded(
          child: Text(
            state.name,
            style: LocationPickerStyle.getItemTextStyle(_theme, context),
          ),
        ),
        if (state.stateCode != null) ...[
          const SizedBox(width: 8),
          Text(
            state.stateCode!,
            style: LocationPickerStyle.getItemTextStyle(
              _theme,
              context,
            ).copyWith(color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildCityItem(CityModel city) {
    return Row(
      children: [
        Expanded(
          child: Text(
            city.name,
            style: LocationPickerStyle.getItemTextStyle(_theme, context),
          ),
        ),
        if (city.isCapital) ...[
          const SizedBox(width: 8),
          Icon(Icons.star, size: 16, color: Colors.amber[600]),
        ],
      ],
    );
  }
}

class CustomDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final Function(T?)? onChanged;
  final String hint;
  final bool isLoading;
  final LocationPickerTheme theme;
  final bool isExpanded;
  final bool enabled;
  final Widget Function(T) itemBuilder;
  final bool Function(T, String)? searchFilter;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    required this.isLoading,
    required this.theme,
    required this.itemBuilder,
    this.isExpanded = true,
    this.enabled = true,
    this.searchFilter,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];
  List<T> _allItems = [];
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();
  Timer? _debounceTimer;
  final FocusNode _searchFocusNode = FocusNode();
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _allItems = List.from(widget.items);
    _filteredItems = _allItems;
    _animationController = AnimationController(
      duration:
          widget.theme.animationDuration ?? const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(CustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _allItems = List.from(widget.items);
      _performSearch(_currentQuery);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();

    // Close dropdown without setState since widget is disposing
    if (_isOpen && _overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    }

    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    _currentQuery = query;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // For instant feedback on empty query
    if (query.isEmpty) {
      _performSearch(query);
      return;
    }

    // Debounce search for performance
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else if (widget.searchFilter != null) {
        final lowerQuery = query.toLowerCase();
        _filteredItems = _allItems.where((item) {
          return widget.searchFilter!(item, lowerQuery);
        }).toList();

        // Sort by relevance - exact matches first, then starts with, then contains
        _filteredItems.sort((a, b) {
          final aStr = _getItemSearchText(a).toLowerCase();
          final bStr = _getItemSearchText(b).toLowerCase();

          final aExact = aStr == lowerQuery ? 0 : 1;
          final bExact = bStr == lowerQuery ? 0 : 1;
          if (aExact != bExact) return aExact.compareTo(bExact);

          final aStarts = aStr.startsWith(lowerQuery) ? 0 : 1;
          final bStarts = bStr.startsWith(lowerQuery) ? 0 : 1;
          if (aStarts != bStarts) return aStarts.compareTo(bStarts);

          return aStr.compareTo(bStr);
        });
      } else {
        _filteredItems = _allItems;
      }
    });
  }

  String _getItemSearchText(T item) {
    // Override this method based on item type for better search
    return item.toString();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!widget.enabled || widget.items.isEmpty) return;

    setState(() => _isOpen = true);
    _animationController.forward();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    // Auto-focus search box for better UX
    if (widget.theme.showSearchBox && widget.items.length > 5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
    setState(() => _isOpen = false);
    _searchController.clear();
    _searchFocusNode.unfocus();
    _currentQuery = '';
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox =
        _dropdownKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: widget.theme.elevation ?? 4,
            borderRadius: widget.theme.borderRadius,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Transform.scale(
                scale: _animation.value,
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: widget.theme.maxHeight ?? 200,
                  ),
                  decoration: LocationPickerStyle.getContainerDecoration(
                    widget.theme,
                    context,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.theme.showSearchBox &&
                          widget.items.length > 5) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            autofocus: true,
                            decoration:
                                widget.theme.searchBoxDecoration ??
                                InputDecoration(
                                  hintText:
                                      widget.theme.searchHint ??
                                      'Type to search...',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color:
                                        widget.theme.iconColor ??
                                        Colors.grey[600],
                                  ),
                                  suffixIcon: _currentQuery.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color:
                                                widget.theme.iconColor ??
                                                Colors.grey[600],
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                        )
                                      : null,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                          ),
                        ),
                        if (_filteredItems.isEmpty &&
                            _currentQuery.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No results found for "$_currentQuery"',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          const Divider(height: 1),
                        ],
                      ],
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return InkWell(
                              onTap: () {
                                widget.onChanged?.call(item);
                                _closeDropdown();
                              },
                              child: Container(
                                padding:
                                    widget.theme.padding ??
                                    const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                decoration: BoxDecoration(
                                  color: widget.value == item
                                      ? widget.theme.itemHighlightColor ??
                                            Theme.of(context).primaryColor
                                                .withValues(alpha: 0.1)
                                      : null,
                                ),
                                child: widget.itemBuilder(item),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _dropdownKey,
        onTap: _toggleDropdown,
        child: Container(
          padding:
              widget.theme.padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isOpen
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withValues(alpha: 0.5),
            ),
            borderRadius: widget.theme.borderRadius ?? BorderRadius.circular(8),
            color: widget.enabled
                ? Theme.of(context).cardColor
                : Colors.grey.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.isLoading
                    ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Loading...',
                            style:
                                widget.theme.hintStyle ??
                                TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                    : widget.value != null
                    ? widget.itemBuilder(widget.value as T)
                    : Text(
                        widget.hint,
                        style:
                            widget.theme.hintStyle ??
                            TextStyle(color: Colors.grey[600]),
                      ),
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: widget.theme.iconColor ?? Colors.grey[600],
                size: widget.theme.iconSize ?? 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
