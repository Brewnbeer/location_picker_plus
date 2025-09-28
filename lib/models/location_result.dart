import 'location_model.dart';

enum AddressSource {
  googlePlaces,
  manualEntry,
  gpsLocation,
}

class LocationResult {
  final double latitude;
  final double longitude;
  final String address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final AddressSource addressSource;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.addressSource = AddressSource.manualEntry,
  });

  factory LocationResult.fromCoordinates({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    return LocationResult(
      latitude: latitude,
      longitude: longitude,
      address: address ?? 'Location at $latitude, $longitude',
      addressSource: AddressSource.gpsLocation,
    );
  }

  /// Create LocationResult from existing LocationModel
  factory LocationResult.fromLocationModel(LocationModel locationModel) {
    return LocationResult(
      latitude: locationModel.latitude,
      longitude: locationModel.longitude,
      address: locationModel.fullAddress,
      city: locationModel.locality,
      state: locationModel.administrativeArea,
      country: locationModel.country,
      postalCode: locationModel.postalCode,
      addressSource: AddressSource.gpsLocation,
    );
  }

  /// Create LocationResult from Google Places API response
  factory LocationResult.fromGooglePlace(Map<String, dynamic> place, double lat, double lng) {
    String address = '';
    String? city;
    String? state;
    String? country;
    String? postalCode;

    // Extract formatted address
    if (place.containsKey('formatted_address')) {
      address = place['formatted_address'] as String;
    }

    // Parse address components
    if (place.containsKey('address_components')) {
      final components = place['address_components'] as List<dynamic>;

      for (final component in components) {
        final types = List<String>.from(component['types'] as List);
        final longName = component['long_name'] as String;

        if (types.contains('locality')) {
          city = longName;
        } else if (types.contains('administrative_area_level_1')) {
          state = longName;
        } else if (types.contains('country')) {
          country = longName;
        } else if (types.contains('postal_code')) {
          postalCode = longName;
        }
      }
    }

    return LocationResult(
      latitude: lat,
      longitude: lng,
      address: address,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      addressSource: AddressSource.googlePlaces,
    );
  }

  LocationResult copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    AddressSource? addressSource,
  }) {
    return LocationResult(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      addressSource: addressSource ?? this.addressSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'addressSource': addressSource.name,
    };
  }

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      addressSource: AddressSource.values.firstWhere(
        (e) => e.name == json['addressSource'],
        orElse: () => AddressSource.manualEntry,
      ),
    );
  }

  @override
  String toString() => address;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationResult &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ address.hashCode;
}