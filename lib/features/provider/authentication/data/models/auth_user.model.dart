import 'dart:convert';

import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/models/auth_base_response.dart.dart';

AuthResponse userFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String userToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse extends EmptyResponse implements BaseAuthResponse {
  AuthResponse({
    required this.accessToken,
    required this.provider,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return AuthResponse(
      accessToken: (data['access_token'] as String?) ?? '',
      provider: ProviderUserModel.fromJson(
        (data['provider'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
    );
  }

  @override
  final String accessToken;
  final ProviderUserModel provider;

  @override
  Map<String, dynamic> toJson() => {
    'data': {
      'access_token': accessToken,
      'provider': provider.toJson(),
    },
  };

  @override
  String toString() => jsonEncode(toJson());
}

class ProviderUserModel {
  ProviderUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.companyName,
    required this.phoneNumber,
    required this.isEmailVerified,
    required this.isApproved,
    required this.createdAt,
  });

  factory ProviderUserModel.fromJson(Map<String, dynamic> json) =>
      ProviderUserModel(
        id: json['id'] as int?,
        email: json['email'] as String?,
        fullName: json['fullName'] as String?,
        companyName: json['companyName'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        isApproved: json['isApproved'] as bool? ?? false,
        createdAt: json['createdAt'] as String?,
      );

  final int? id;
  final String? email;
  final String? fullName;
  final String? companyName;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isApproved;
  final String? createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'companyName': companyName,
    'phoneNumber': phoneNumber,
    'isEmailVerified': isEmailVerified,
    'isApproved': isApproved,
    'createdAt': createdAt,
  };
}
