import 'dart:convert';

class ProviderOpenPing {
  const ProviderOpenPing({required this.raw, this.id, this.customerName});

  factory ProviderOpenPing.fromJson(Map<String, dynamic> json) {
    return ProviderOpenPing(
      raw: json,
      id: _readString(json, const [
        'id',
        'pingId',
        'ping_id',
        'requestId',
        'request_id',
        'serviceRequestId',
        'service_request_id',
      ]),
      customerName: _readCustomerName(json),
    );
  }

  final String? id;
  final String? customerName;
  final Map<String, dynamic> raw;

  String get fingerprint {
    final knownId = id;
    if (knownId != null && knownId.isNotEmpty) return knownId;

    try {
      return jsonEncode(raw);
    } on Object {
      return raw.toString();
    }
  }

  String get notificationMessage {
    final name = customerName?.trim();
    if (name == null || name.isEmpty) return 'You have a new service request';
    return 'You have a new service request from $name';
  }

  static String? _readCustomerName(Map<String, dynamic> json) {
    final directName = _readString(json, const [
      'customerName',
      'customer_name',
      'userName',
      'user_name',
      'clientName',
      'client_name',
      'name',
    ]);

    if (directName != null && directName.isNotEmpty) return directName;

    for (final key in const ['customer', 'user', 'client']) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        final nestedName = _readNameFromProfile(value);
        if (nestedName != null && nestedName.isNotEmpty) return nestedName;
      }
    }

    return null;
  }

  static String? _readNameFromProfile(Map<String, dynamic> json) {
    final profileName = _readString(json, const [
      'fullName',
      'full_name',
      'displayName',
      'display_name',
      'name',
    ]);

    if (profileName != null && profileName.isNotEmpty) return profileName;

    final firstName = _readString(json, const ['firstName', 'first_name']);
    final lastName = _readString(json, const ['lastName', 'last_name']);
    final parts =
        [firstName, lastName]
            .where((part) => part != null && part.trim().isNotEmpty)
            .map((part) => part!.trim())
            .toList();

    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }

    return null;
  }
}
