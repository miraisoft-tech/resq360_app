class Address {
  Address({
    this.state,
    this.city,
    this.zipCode,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    state: json['state'] as String?,
    city: json['city'] as String?,
    zipCode: json['zipCode'] as String?,
    address: json['address'] as String?,
latitude: json['latitude'] != null
    ? double.tryParse(json['latitude'].toString())
    : null,
longitude: json['longitude'] != null
    ? double.tryParse(json['longitude'].toString())
    : null,
  );

  final String? state;
  final String? city;
  final String? zipCode;
  final String? address;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
    'state': state,
    'city': city,
    'zipCode': zipCode,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };
}
