
class AuthData {
  AuthData({
    this.accessToken,
    this.user,
    this.isEmailVerified,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['access_token'] as String?,
      user:
          json['user'] != null
              ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      isEmailVerified:
          json['isEmailVerified'] as bool?,
    );
  }

  final String? accessToken;
  final UserModel? user;
  final bool? isEmailVerified;
}


class AuthResponse {
  AuthResponse({
    required this.success,
    required this.message,
    this.data,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data:
          json['data'] != null
              ? AuthData.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      user:
          json['user'] != null
              ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
    );
  }

  final bool success;
  final String message;

  final AuthData? data;

  final UserModel? user;
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
