class ProviderAuthData {
  ProviderAuthData({
    this.accessToken,
    this.provider,
    this.isEmailVerified,
  });

  factory ProviderAuthData.fromJson(Map<String, dynamic> json) {
    return ProviderAuthData(
      accessToken: json['access_token'] as String?,
      provider:
          json['provider'] != null
              ? ProviderUserModel.fromJson(
                  json['provider'] as Map<String, dynamic>,
                )
              : null,
      isEmailVerified: json['isEmailVerified'] as bool?,
    );
  }

  final String? accessToken;
  final ProviderUserModel? provider;
  final bool? isEmailVerified;
}

class AuthResponse {
  AuthResponse({
    required this.success,
    required this.message,
    this.data,
    this.provider,

  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data:
          json['data'] != null
              ? ProviderAuthData.fromJson(
                  json['data'] as Map<String, dynamic>,
                )
              : null,
      provider: json['provider'] != null
              ? ProviderUserModel.fromJson(json['provider'] as Map<String, dynamic>)
              : null,
    );
  }

  final bool success;
  final String message;
  final ProviderAuthData? data;
  final ProviderUserModel? provider;


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
