import 'dart:convert';

import 'package:resq360/core/models/api_response.dart';

AuthResponse userFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String userToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse extends EmptyResponse {
  AuthResponse(
    this.accessToken, {
    required this.message,
    required this.user,
    required this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    json['access_token'] as String?, 
    message: json['message'] as String? ?? '',
    user: ProviderUserModel.fromJson(
      (json['provider'] ?? json['user']) as Map<String, dynamic>,
    ),
    success: json['success'] as bool? ?? false,
  );
  String message;
  ProviderUserModel user;
  bool success;
  final String? accessToken;

  Map<String, dynamic> toJson() => {
    'message': message,
    'user': user.toJson(),
    'success': success,
  };
}
// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

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

class Address {
  Address({
    required this.state,
    required this.city,
    required this.zipCode,
    required this.address,
    required this.longitude,
    required this.latitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    state: json['state'] as String,
    city: json['city'] as String,
    zipCode: json['zipCode'] as String,
    address: json['address'] as String,
    longitude:
        (json['longitude'] != null)
            ? (json['longitude'] as num).toDouble()
            : 0.0,
    latitude:
        (json['latitude'] != null) ? (json['latitude'] as num).toDouble() : 0.0,
  );
  String state;
  String city;
  String zipCode;
  String address;
  double longitude;
  double latitude;

  Map<String, dynamic> toJson() => {
    'state': state,
    'city': city,
    'zipCode': zipCode,
    'address': address,
    'longitude': longitude,
    'latitude': latitude,
  };
}

// class UserModel extends EmptyResponse {
//   UserModel({
//     this.id,
//     this.photoUrl,
//     this.firstName,
//     this.lastName,
//     this.email,
//     this.address,
//     this.phone,
//     this.state,
//     this.accountState,
//     this.code,
//     this.isTruckAssigned,
//     this.companyId,
//     this.companyName,
//     this.companyIconUrl,
//     this.userId,
//     this.referralCode,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
//     id: json['id'] as String?,
//     photoUrl: json['profilePic'] as String?,
//     firstName: json['firstName'] as String?,
//     lastName: json['lastName'] as String?,
//     email: json['email'] as String?,
//     address: json['address'] as String?,
//     phone: json['phoneNumber'] as String?,
//     state: json['state'] as String?,
//     accountState: json['accountState'] as bool?,
//     code: json['code'] as String?,
//     isTruckAssigned: json['isTruckAssigned'] as bool?,
//     companyId: json['companyId'] as String?,
//     companyName: json['companyName'] as String?,
//     companyIconUrl: json['companyIconUrl'] as String?,
//     userId: json['userId'] as String?,
//     referralCode: json['referralCode'] as String?,
//   );

//   final String? id;
//   final String? photoUrl;
//   final String? firstName;
//   final String? lastName;
//   final String? email;
//   final String? address;
//   final String? phone;
//   final String? state;
//   final bool? accountState;
//   final String? code;
//   final bool? isTruckAssigned;
//   final String? companyId;
//   final String? companyName;
//   final String? companyIconUrl;
//   final String? userId;
//   final String? referralCode;

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'profilePic': photoUrl,
//     'firstName': firstName,
//     'lastName': lastName,
//     'email': email,
//     'address': address,
//     'phoneNumber': phone,
//     'state': state,
//     'accountState': accountState,
//     'code': code,
//     'isTruckAssigned': isTruckAssigned,
//     'companyId': companyId,
//     'companyName': companyName,
//     'companyIconUrl': companyIconUrl,
//     'userId': userId,
//     'referralCode': referralCode,
//   };

//   UserModel copyWith({
//     String? id,
//     String? photoUrl,
//     String? firstName,
//     String? lastName,
//     String? email,
//     String? address,
//     String? phone,
//     String? state,
//     bool? accountState,
//     String? code,
//     bool? isTruckAssigned,
//     String? companyId,
//     String? companyName,
//     String? companyIconUrl,
//     String? userId,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       photoUrl: photoUrl ?? this.photoUrl,
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       email: email ?? this.email,
//       address: address ?? this.address,
//       phone: phone ?? this.phone,
//       state: state ?? this.state,
//       accountState: accountState ?? this.accountState,
//       code: code ?? this.code,
//       isTruckAssigned: isTruckAssigned ?? this.isTruckAssigned,
//       companyId: companyId ?? this.companyId,
//       companyName: companyName ?? this.companyName,
//       companyIconUrl: companyIconUrl ?? this.companyIconUrl,
//       userId: userId ?? this.userId,
//     );
//   }
// }
