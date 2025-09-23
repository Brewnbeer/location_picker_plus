class StateModel {
  final String id;
  final String name;
  final String countryId;
  final String? stateCode;
  final String? type;

  StateModel({
    required this.id,
    required this.name,
    required this.countryId,
    this.stateCode,
    this.type,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      countryId: json['country_id'] as String,
      stateCode: json['state_code'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'state_code': stateCode,
      'type': type,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StateModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
