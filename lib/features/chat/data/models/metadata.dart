/// Flexible metadata class that can store any type of message metadata
/// Handles invoices, locations, and any future metadata types
class Metadata {
  Metadata({
    this.type,
    this.amount,
    this.currency,
    this.invoiceId,
    this.description,
    this.date,
    this.latitude,
    this.longitude,
    this.address,
    this.customData,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      type: json['type'] as String?,
      
      amount: json['amount'] is int
          ? json['amount'] as int
          : int.tryParse(json['amount']?.toString() ?? ''),
      currency: json['currency'] as String?,
      invoiceId: json['invoiceId'] as String?,
      description: json['description'] as String?,
      date: json['date'] as String?,
      
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      address: json['address'] as String?,
      
      customData: Map<String, dynamic>.from(json),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  final String? type;

  final int? amount;
  final String? currency;
  final String? invoiceId;
  final String? description;
  final String? date;

  final double? latitude;
  final double? longitude;
  final String? address;

  final Map<String, dynamic>? customData;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (type != null) json['type'] = type;
    if (amount != null) json['amount'] = amount;
    if (currency != null) json['currency'] = currency;
    if (invoiceId != null) json['invoiceId'] = invoiceId;
    if (description != null) json['description'] = description;
    if (date != null) json['date'] = date;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (address != null) json['address'] = address;
    
    if (customData != null) {
      customData!.forEach((key, value) {
        if (!json.containsKey(key)) {
          json[key] = value;
        }
      });
    }
    
    return json;
  }

  bool get isInvoice => type?.toUpperCase() == 'INVOICE';
  bool get isLocation => latitude != null && longitude != null;

  T? getCustomValue<T>(String key) {
    if (customData == null) return null;
    final value = customData![key];
    if (value is T) return value;
    return null;
  }

  Metadata copyWith({
    String? type,
    int? amount,
    String? currency,
    String? invoiceId,
    String? description,
    String? date,
    double? latitude,
    double? longitude,
    String? address,
    Map<String, dynamic>? customData,
  }) {
    return Metadata(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      date: date ?? this.date,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      customData: customData ?? this.customData,
    );
  }
}

extension MetadataFactories on Metadata {
  static Metadata invoice({
    required int amount,
    required String currency,
    required String invoiceId,
    String? description,
    String? date,
  }) {
    return Metadata(
      type: 'INVOICE',
      amount: amount,
      currency: currency,
      invoiceId: invoiceId,
      description: description,
      date: date,
    );
  }

  static Metadata location({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    return Metadata(
      type: 'LOCATION',
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  static Metadata custom({
    required String type,
    required Map<String, dynamic> data,
  }) {
    return Metadata(
      type: type,
      customData: data,
    );
  }
}
