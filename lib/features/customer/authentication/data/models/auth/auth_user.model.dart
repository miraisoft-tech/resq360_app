import 'dart:convert';

import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/models/auth_base_response.dart.dart';

AuthResponse userFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String userToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse extends EmptyResponse implements BaseAuthResponse {
  AuthResponse(
    this.accessToken, {
    required this.message,
    required this.user,
    required this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    json['access_token'] as String?,
    message: json['message'] as String? ?? '',
    user:
        json['user'] != null
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : UserModel(),
    success: json['success'] as bool? ?? true,
  );
  String message;
  UserModel user;
  bool success;
  @override
  final String? accessToken;

  @override
  Map<String, dynamic> toJson() => {
    'message': message,
    'user': user.toJson(),
    'success': success,
  };
}

class UserModel {
  UserModel({
    this.id,
    this.email,
    this.fullName,
    this.firstName,
    this.lastName,
    this.isEmailVerified,
    this.createdAt,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:
          json['id'] is String
              ? int.tryParse(json['id'] as String)
              : (json['id'] is int ? json['id'] as int : null),
      email: json['email'] as String?,
      fullName:
          json['fullName'] != null
              ? json['fullName'] as String
              : '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      isEmailVerified:
          json['isEmailVerified'] is bool
              ? json['isEmailVerified'] as bool
              : (json['isEmailVerified'] == null
                  ? null
                  : json['isEmailVerified'].toString().toLowerCase() == 'true'),
      phoneNumber: json['phoneNumber'] as String? ?? '',

      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'].toString())
              : null,
    );
  }
  final int? id;
  final String? email;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final bool? isEmailVerified;
  final String? phoneNumber;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'firstName': firstName,
    'lastName': lastName,
    'isEmailVerified': isEmailVerified,
    'createdAt': createdAt?.toIso8601String(),
  };
}
