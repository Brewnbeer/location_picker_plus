import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_picker_plus/models/location_model.dart';

enum LocationStatus {
  unknown,
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  loading,
  success,
  error,
}

class LocationDetectorService {
  static LocationDetectorService? _instance;
  static LocationDetectorService get instance =>
      _instance ??= LocationDetectorService._internal();

  LocationDetectorService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Get current location with coordinates only
  Future<LocationModel?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get position
      LocationSettings locationSettings = LocationSettings(
        accuracy: accuracy,
        timeLimit: timeLimit,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return LocationModel.fromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  /// Get current location with full address details using reverse geocoding
  Future<LocationModel?> getCurrentLocationWithAddress({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
    String? localeIdentifier,
  }) async {
    try {
      // Get coordinates first
      LocationModel? location = await getCurrentLocation(
        accuracy: accuracy,
        timeLimit: timeLimit,
      );

      if (location == null) return null;

      // Get address from coordinates
      return await getAddressFromCoordinates(
        location.latitude,
        location.longitude,
        localeIdentifier: localeIdentifier,
      );
    } catch (e) {
      throw Exception('Failed to get location with address: $e');
    }
  }

  /// Get address details from coordinates using reverse geocoding
  Future<LocationModel?> getAddressFromCoordinates(
    double latitude,
    double longitude, {
    String? localeIdentifier,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return LocationModel(
          latitude: latitude,
          longitude: longitude,
          address: [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country,
          ].where((s) => s?.isNotEmpty == true).join(', '),
          street: place.street,
          locality: place.locality, // City
          subLocality: place.subLocality,
          administrativeArea: place.administrativeArea, // State
          subAdministrativeArea: place.subAdministrativeArea,
          country: place.country,
          postalCode: place.postalCode,
          countryCode: place.isoCountryCode,
        );
      }

      return LocationModel.fromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      throw Exception('Failed to get address from coordinates: $e');
    }
  }

  /// Get coordinates from address (forward geocoding)
  Future<LocationModel?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        return await getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get coordinates from address: $e');
    }
  }

  /// Calculate distance between two locations
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get location stream for real-time updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration? intervalDuration,
  }) {
    LocationSettings locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    if (intervalDuration != null) {
      locationSettings = AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        intervalDuration: intervalDuration,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
