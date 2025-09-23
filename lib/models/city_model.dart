class CityModel {
  final String id;
  final String name;
  final String stateId;
  final String? latitude;
  final String? longitude;
  final bool isCapital;

  CityModel({
    required this.id,
    required this.name,
    required this.stateId,
    this.latitude,
    this.longitude,
    this.isCapital = false,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      stateId: json['state_id'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      isCapital: json['is_capital'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state_id': stateId,
      'latitude': latitude,
      'longitude': longitude,
      'is_capital': isCapital,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CityModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
