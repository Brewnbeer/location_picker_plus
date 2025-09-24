import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_picker_plus/models/location_model.dart';
import 'package:location_picker_plus/services/location_detector_service.dart';
import 'package:location_picker_plus/themes/location_picker_plus_theme.dart';

enum LocationDetectorMode { currentLocation, addressSearch, both }

class LocationDetectorWidget extends StatefulWidget {
  final LocationDetectorMode mode;
  final Function(LocationModel?)? onLocationChanged;
  final Function(String)? onAddressChanged;
  final Function(double, double)? onCoordinatesChanged;
  final LocationPickerTheme? theme;
  final String? currentLocationHint;
  final String? addressSearchHint;
  final String currentLocationLabel;
  final String addressSearchLabel;
  final bool showCoordinates;
  final bool showFullAddress;
  final bool autoDetectOnInit;
  final LocationAccuracy accuracy;
  final Duration? timeLimit;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? localeIdentifier;

  const LocationDetectorWidget({
    super.key,
    this.mode = LocationDetectorMode.both,
    this.onLocationChanged,
    this.onAddressChanged,
    this.onCoordinatesChanged,
    this.theme,
    this.currentLocationHint,
    this.addressSearchHint,
    this.currentLocationLabel = 'Current Location',
    this.addressSearchLabel = 'Search Address',
    this.showCoordinates = true,
    this.showFullAddress = true,
    this.autoDetectOnInit = false,
    this.accuracy = LocationAccuracy.high,
    this.timeLimit,
    this.loadingWidget,
    this.errorWidget,
    this.localeIdentifier,
  });

  @override
  State<LocationDetectorWidget> createState() => _LocationDetectorWidgetState();
}

class _LocationDetectorWidgetState extends State<LocationDetectorWidget> {
  final LocationDetectorService _locationService =
      LocationDetectorService.instance;
  final TextEditingController _addressController = TextEditingController();

  LocationModel? _currentLocation;
  LocationStatus _status = LocationStatus.unknown;
  String? _errorMessage;
  bool _isLoading = false;

  late LocationPickerTheme _theme;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? LocationPickerTheme.defaultTheme();

    if (widget.autoDetectOnInit) {
      _detectCurrentLocation();
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _status = LocationStatus.loading;
      _errorMessage = null;
    });

    try {
      LocationModel? location = await _locationService
          .getCurrentLocationWithAddress(
            accuracy: widget.accuracy,
            timeLimit: widget.timeLimit,
            localeIdentifier: widget.localeIdentifier,
          );

      if (!mounted) return;

      setState(() {
        _currentLocation = location;
        _status = LocationStatus.success;
        _isLoading = false;
      });

      widget.onLocationChanged?.call(location);
      if (location != null) {
        widget.onCoordinatesChanged?.call(
          location.latitude,
          location.longitude,
        );
        widget.onAddressChanged?.call(location.fullAddress);
      }
    } catch (e) {
      if (!mounted) return;

      LocationStatus status = LocationStatus.error;
      if (e.toString().contains('permission denied')) {
        status = LocationStatus.permissionDenied;
      } else if (e.toString().contains('permanently denied')) {
        status = LocationStatus.permissionPermanentlyDenied;
      } else if (e.toString().contains('disabled')) {
        status = LocationStatus.serviceDisabled;
      }

      setState(() {
        _status = status;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      LocationModel? location = await _locationService
          .getCoordinatesFromAddress(address);

      if (!mounted) return;

      setState(() {
        _currentLocation = location;
        _isLoading = false;
      });

      widget.onLocationChanged?.call(location);
      if (location != null) {
        widget.onCoordinatesChanged?.call(
          location.latitude,
          location.longitude,
        );
        widget.onAddressChanged?.call(location.fullAddress);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildCurrentLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.currentLocationLabel,
          style: _theme.labelStyle ?? Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _detectCurrentLocation,
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : Icon(Icons.location_on),
          label: Text(_isLoading ? 'Detecting...' : 'Detect Current Location'),
        ),
      ],
    );
  }

  Widget _buildAddressSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.addressSearchLabel,
          style: _theme.labelStyle ?? Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText:
                      widget.addressSearchHint ?? 'Enter address to search...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _addressController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _addressController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
                onSubmitted: (value) => _searchAddress(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading || _addressController.text.trim().isEmpty
                  ? null
                  : _searchAddress,
              child: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Text('Search'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationDisplay() {
    if (_currentLocation == null) return const SizedBox.shrink();

    return Card(
      elevation: _theme.elevation ?? 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Detected Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.showFullAddress) ...[
              _buildInfoRow('Full Address', _currentLocation!.fullAddress),
              const SizedBox(height: 8),
            ],
            if (_currentLocation!.locality?.isNotEmpty == true)
              _buildInfoRow('City', _currentLocation!.locality!),
            if (_currentLocation!.administrativeArea?.isNotEmpty == true)
              _buildInfoRow('State', _currentLocation!.administrativeArea!),
            if (_currentLocation!.country?.isNotEmpty == true)
              _buildInfoRow('Country', _currentLocation!.country!),
            if (_currentLocation!.postalCode?.isNotEmpty == true)
              _buildInfoRow('Postal Code', _currentLocation!.postalCode!),
            if (widget.showCoordinates) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Latitude',
                _currentLocation!.latitude.toStringAsFixed(6),
              ),
              _buildInfoRow(
                'Longitude',
                _currentLocation!.longitude.toStringAsFixed(6),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 8),
            if (_status == LocationStatus.permissionDenied ||
                _status == LocationStatus.permissionPermanentlyDenied) ...[
              ElevatedButton.icon(
                onPressed: _locationService.openAppSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
            ],
            if (_status == LocationStatus.serviceDisabled) ...[
              ElevatedButton.icon(
                onPressed: _locationService.openLocationSettings,
                icon: const Icon(Icons.location_on),
                label: const Text('Enable Location Services'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.mode == LocationDetectorMode.currentLocation ||
            widget.mode == LocationDetectorMode.both) ...[
          _buildCurrentLocationSection(),
          const SizedBox(height: 16),
        ],
        if (widget.mode == LocationDetectorMode.addressSearch ||
            widget.mode == LocationDetectorMode.both) ...[
          _buildAddressSearchSection(),
          const SizedBox(height: 16),
        ],
        _buildErrorWidget(),
        if (_errorMessage == null) _buildLocationDisplay(),
      ],
    );
  }
}
