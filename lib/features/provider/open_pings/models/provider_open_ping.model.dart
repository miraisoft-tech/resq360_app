import 'dart:convert';

class ProviderOpenPingsResponse {
  const ProviderOpenPingsResponse({
    required this.data,
    this.message,
    this.success = false,
  });

  factory ProviderOpenPingsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return ProviderOpenPingsResponse(
      message: json['message']?.toString(),
      success: json['success'] == true,
      data:
          rawData is List
              ? rawData
                  .whereType<Map<String, dynamic>>()
                  .map(ProviderOpenPing.fromJson)
                  .toList()
              : <ProviderOpenPing>[],
    );
  }

  final String? message;
  final bool success;
  final List<ProviderOpenPing> data;

  bool get hasOpenPings => data.isNotEmpty;
}

class ProviderOpenPing {
  const ProviderOpenPing({
    required this.raw,
    this.id,
    this.batchId,
    this.customerName,
    this.customerId,
    this.providerServiceId,
    this.serviceRequestId,
    this.chatId,
    this.createdAt,
  });

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
      batchId: _readString(json, const ['batchId', 'batch_id']),
      customerName: _readCustomerName(json),
      customerId:
          _readInt(json, const [
            'customerId',
            'customer_id',
            'userId',
            'user_id',
            'clientId',
            'client_id',
          ]) ??
          _readNestedInt(json, const [
            ['customer', 'id'],
            ['customer', 'userId'],
            ['user', 'id'],
            ['client', 'id'],
          ]),
      providerServiceId:
          _readInt(json, const ['providerServiceId', 'provider_service_id']) ??
          _readNestedInt(json, const [
            ['providerService', 'id'],
            ['ProviderService', 'id'],
            ['serviceRequest', 'providerServiceId'],
            ['request', 'providerServiceId'],
          ]),
      serviceRequestId:
          _readInt(json, const [
            'serviceRequestId',
            'service_request_id',
            'requestId',
            'request_id',
          ]) ??
          _readNestedInt(json, const [
            ['serviceRequest', 'id'],
            ['request', 'id'],
          ]),
      chatId:
          _readInt(json, const ['chatId', 'chat_id']) ??
          _readNestedInt(json, const [
            ['chat', 'id'],
            ['serviceRequest', 'chatId'],
            ['request', 'chatId'],
          ]),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  final String? id;
  final String? batchId;
  final String? customerName;
  final int? customerId;
  final int? providerServiceId;
  final int? serviceRequestId;
  final int? chatId;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  bool get canContactCustomer {
    return chatId != null || serviceRequestId != null || customerId != null;
  }

  String get fingerprint {
    final knownId = id;
    if (knownId != null && knownId.isNotEmpty) return knownId;

    try {
      return jsonEncode(raw);
    } on Object {
      return raw.toString();
    }
  }

  String get seenKey {
    final knownBatchId = batchId?.trim();
    if (knownBatchId != null && knownBatchId.isNotEmpty) {
      return knownBatchId;
    }

    return fingerprint;
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

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = _parseInt(json[key]);
      if (value != null) return value;
    }

    return null;
  }

  static int? _readNestedInt(
    Map<String, dynamic> json,
    List<List<String>> paths,
  ) {
    for (final path in paths) {
      Object? value = json;
      for (final key in path) {
        if (value is Map) {
          value = value[key];
        } else {
          value = null;
          break;
        }
      }

      final parsedValue = _parseInt(value);
      if (parsedValue != null) return parsedValue;
    }

    return null;
  }

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;

    return int.tryParse(text);
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is DateTime) return value;

    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;

    return DateTime.tryParse(text);
  }
}
