import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';
import 'package:url_launcher/url_launcher.dart';

class AppGenUtil {
  AppGenUtil._();

  static Future<void> offKeyboard() async {
    await SystemChannels.textInput.invokeMethod<dynamic>('TextInput.hide');
  }

  static Future<void> deleteAccountEmail() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map(
            (MapEntry<String, String> e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
    }

    final uri = Uri(
      scheme: 'mailto',
      path: 'info@remis.africa',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Delete Account Request',
        'body': 'Hello, i would like to delete my account because...',
      }),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log('cannot launch');
    }
  }

  static Future<void> sendEmail() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map(
            (MapEntry<String, String> e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
    }

    final uri = Uri(
      scheme: 'mailto',
      path: 'info@remis.africa',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Feedback on...',
        'body': 'Hello, i would like to...',
      }),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log('cannot launch');
    }
  }

  static Future<void> openWhatsappChat() async {
    final uri = Uri(scheme: 'https', path: 'wa.me/+13017412329');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log('cannot launch');
    }
  }

  static Future<void> callPhone() async {
    final uri = Uri(scheme: 'tel', path: '08123266902');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      log('cannot launch');
    }
  }

  static Future<void> launchUrlText(String urlText) async {
    final uri = Uri.parse(urlText);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log('Cannot launch $urlText');
    }
  }

  static Future<void> launchMaps(
    double latitude,
    double longitude,
    String label,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_place_id=$label',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      log('Could not launch $url');
    }
  }

  // Simpler version if you don't need the place_id
  static Future<void> launchMapsSimple(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      log('Could not launch $url');
    }
  }

  static Future<void> launchMapsWithDirections({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        log('Could not launch maps');
      }
    } on Exception catch (e) {
      log('Error launching maps: $e');
    }
  }

  static String? isValidPassword(String? password) {
    final value = password!.trim();

    if (value.trim().isEmpty) {
      return 'Try a more secure password  at least 8 characters.';
    } else if (value.trim().length < 6) {
      return 'Password is too short';
    } else if (!value.trim().contains(RegExp('[0-9]'))) {
      return 'Password must contain a number';
    } else if (!value.trim().contains(RegExp('[a-z]'))) {
      return 'Password must contain a lowercase letter';
    } else if (!value.trim().contains(RegExp('[A-Z]'))) {
      return 'Password must contain a uppercase letter';
    } else if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain a special character';
    }

    return null;
  }

  static String? isValidName(String? value, String type, int length) {
    if (value!.isEmpty) {
      return '$type is required';
    } else if (value.length < length) {
      return '$type is too short';
    } else if (value.length > 50) {
      return '$type max length is 50';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    final value = email!.trim();
    final regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    if (value.isEmpty) {
      return '"Email" cannot be empty';
    } else if (!regex.hasMatch(value)) {
      return 'Enter valid email';
    } else {
      return null;
    }
  }

  static String? isValidSelection(String? value, String type) {
    if (value == null) {
      return 'Select $type';
    } else {
      return null;
    }
  }
}
