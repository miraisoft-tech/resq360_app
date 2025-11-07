import 'dart:convert';

import 'package:resq360/features/customer/authentication/data/models/auth/customer_user_model.dart';

class CustomerProfileResponse {
  CustomerProfileResponse({
    required this.user,
    required this.message,
    required this.success,
  });

  factory CustomerProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return CustomerProfileResponse(
      user: CustomerUserModel.fromJson(data),
      message: json['message'] as String? ?? '',
      success: json['success'] as bool? ?? false,
    );
  }

  final CustomerUserModel user;
  final String message;
  final bool success;

  Map<String, dynamic> toJson() => {
        'message': message,
        'success': success,
        'data': user.toJson(),
      };

  @override
  String toString() => jsonEncode(toJson());
}
