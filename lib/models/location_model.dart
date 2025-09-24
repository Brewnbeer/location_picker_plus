class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? street;
  final String? locality;
  final String? subLocality;
  final String? administrativeArea; // State
  final String? subAdministrativeArea;
  final String? country;
  final String? postalCode;
  final String? countryCode;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.street,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.country,
    this.postalCode,
    this.countryCode,
  });

  factory LocationModel.fromCoordinates({
    required double latitude,
    required double longitude,
  }) {
    return LocationModel(
      latitude: latitude,
      longitude: longitude,
    );
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? street,
    String? locality,
    String? subLocality,
    String? administrativeArea,
    String? subAdministrativeArea,
    String? country,
    String? postalCode,
    String? countryCode,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      street: street ?? this.street,
      locality: locality ?? this.locality,
      subLocality: subLocality ?? this.subLocality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      subAdministrativeArea: subAdministrativeArea ?? this.subAdministrativeArea,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  String get fullAddress {
    List<String> parts = [];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (subLocality != null && subLocality!.isNotEmpty) parts.add(subLocality!);
    if (locality != null && locality!.isNotEmpty) parts.add(locality!);
    if (administrativeArea != null && administrativeArea!.isNotEmpty) parts.add(administrativeArea!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    return parts.isNotEmpty ? parts.join(', ') : address ?? 'Unknown location';
  }

  String get cityStateCountry {
    List<String> parts = [];
    if (locality != null && locality!.isNotEmpty) parts.add(locality!);
    if (administrativeArea != null && administrativeArea!.isNotEmpty) parts.add(administrativeArea!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'street': street,
      'locality': locality,
      'subLocality': subLocality,
      'administrativeArea': administrativeArea,
      'subAdministrativeArea': subAdministrativeArea,
      'country': country,
      'postalCode': postalCode,
      'countryCode': countryCode,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String?,
      street: json['street'] as String?,
      locality: json['locality'] as String?,
      subLocality: json['subLocality'] as String?,
      administrativeArea: json['administrativeArea'] as String?,
      subAdministrativeArea: json['subAdministrativeArea'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      countryCode: json['countryCode'] as String?,
    );
  }

  @override
  String toString() => fullAddress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}