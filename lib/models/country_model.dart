class CountryModel {
  final String id;
  final String sortName;
  final String name;
  final String phoneCode;
  final String? flagEmoji;
  final String? capital;
  final String? currency;

  CountryModel({
    required this.id,
    required this.sortName,
    required this.name,
    required this.phoneCode,
    this.flagEmoji,
    this.capital,
    this.currency,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as String,
      sortName: json['sortname'] as String,
      name: json['name'] as String,
      phoneCode: json['phonecode'] as String,
      flagEmoji: json['flag_emoji'] as String?,
      capital: json['capital'] as String?,
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sortname': sortName,
      'name': name,
      'phonecode': phoneCode,
      'flag_emoji': flagEmoji,
      'capital': capital,
      'currency': currency,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
