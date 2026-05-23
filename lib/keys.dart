import 'dart:convert';

import 'package:flutter/services.dart';

class AppKeys {
  static const String _googleApiKeyFromEnvironment = String.fromEnvironment(
    'GOOGLE_API_KEY',
  );
  static String? _cachedGoogleApiKey;

  static Future<String> get googleApiKey async {
    if (_googleApiKeyFromEnvironment.isNotEmpty) {
      return _googleApiKeyFromEnvironment;
    }

    final cachedGoogleApiKey = _cachedGoogleApiKey;
    if (cachedGoogleApiKey != null) {
      return cachedGoogleApiKey;
    }

    try {
      final source = await rootBundle.loadString('keys.json');
      final data = jsonDecode(source) as Map<String, dynamic>;
      final googleApiKey = data['GOOGLE_API_KEY']?.toString().trim() ?? '';
      _cachedGoogleApiKey = googleApiKey;

      return googleApiKey;
    } on Object {
      _cachedGoogleApiKey = '';
      return '';
    }
  }

  static const String privacypolicyurl =
      'https://www.resq360.ng/privacy-policy';

  static const String termsAndConditionsUrl =
      'https://www.resq360.ng/terms-and-conditions';

  static const String websiteUrl = 'https://www.resq360.ng';
}
