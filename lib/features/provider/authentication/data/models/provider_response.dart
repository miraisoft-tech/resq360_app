import 'dart:convert';

import 'package:resq360/features/provider/authentication/data/models/address.model.dart';

class ProviderProfileResponse {
  ProviderProfileResponse({
    required this.user,
    required this.message,
    required this.success,
  });

  factory ProviderProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ProviderProfileResponse(
      user: ProviderModel.fromJson(data),
      message: json['message'] as String? ?? '',
      success: json['success'] as bool? ?? false,
    );
  }

  final ProviderModel user;
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

class ProviderModel {
  ProviderModel({
    this.id,
    this.email,
    this.fullName,
    this.companyName,
    this.phoneNumber,
    this.profileImage,
    this.description,
    this.isEmailVerified = false,
    this.isApproved = false,
    this.isKYCVerified = false,
    this.kycStatus,
    this.activityStatus,
    this.workingDays,
    this.openingHours,
    this.closingHours,
    this.currentLongitude,
    this.currentLatitude,
    this.createdAt,
    this.updatedAt,
    this.wallet,
    this.address,
    this.providerServices,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as int?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      companyName: json['companyName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      description: json['description'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? false,
      isKYCVerified: json['isKYCVerified'] as bool? ?? false,
      kycStatus: json['kycStatus'] as String?,
      activityStatus: json['activityStatus'] as String?,
      workingDays:
          (json['workingDays'] as List?)?.map((e) => e.toString()).toList(),
      openingHours: json['openingHours'] as String?,
      closingHours: json['closingHours'] as String?,
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      wallet:
          json['wallet'] is Map<String, dynamic>
              ? Wallet.fromJson(json['wallet'] as Map<String, dynamic>)
              : null,
      address:
          json['address'] is Map<String, dynamic>
              ? Address.fromJson(json['address'] as Map<String, dynamic>)
              : null,
      providerServices:
          (json['ProviderService'] as List?)
              ?.map((e) => ProviderService.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  final int? id;
  final String? email;
  final String? fullName;
  final String? companyName;
  final String? phoneNumber;
  final String? profileImage;
  final String? description;
  final bool isEmailVerified;
  final bool isApproved;
  final bool isKYCVerified;
  final String? kycStatus;
  final String? activityStatus;
  final List<String>? workingDays;
  final String? openingHours;
  final String? closingHours;
  final double? currentLongitude;
  final double? currentLatitude;
  final String? createdAt;
  final String? updatedAt;
  final Wallet? wallet;
  final Address? address;
  final List<ProviderService>? providerServices;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'companyName': companyName,
    'phoneNumber': phoneNumber,
    'profileImage': profileImage,
    'description': description,
    'isEmailVerified': isEmailVerified,
    'isApproved': isApproved,
    'isKYCVerified': isKYCVerified,
    'kycStatus': kycStatus,
    'activityStatus': activityStatus,
    'workingDays': workingDays,
    'openingHours': openingHours,
    'closingHours': closingHours,
    'currentLongitude': currentLongitude,
    'currentLatitude': currentLatitude,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'wallet': wallet?.toJson(),
    'address': address?.toJson(),
    'ProviderService': providerServices?.map((e) => e.toJson()).toList(),
  };
}

class Wallet {
  Wallet({
    this.balance,
    this.availableBalance,
    this.totalEarnings,
    this.totalWithdrawn,
    this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    balance: json['balance']?.toString(),
    availableBalance: json['availableBalance']?.toString(),
    totalEarnings: json['totalEarnings']?.toString(),
    totalWithdrawn: json['totalWithdrawn']?.toString(),
    currency: json['currency'] as String?,
  );

  final String? balance;
  final String? availableBalance;
  final String? totalEarnings;
  final String? totalWithdrawn;
  final String? currency;

  Map<String, dynamic> toJson() => {
    'balance': balance,
    'availableBalance': availableBalance,
    'totalEarnings': totalEarnings,
    'totalWithdrawn': totalWithdrawn,
    'currency': currency,
  };
}



class ProviderService {
  ProviderService({
    this.id,
    this.name,
    this.isActive = false,
    this.service,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) =>
      ProviderService(
        id: json['id'] as int?,
        name: json['name'] as String?,
        isActive: json['isActive'] as bool? ?? false,
        service:
            json['service'] is Map<String, dynamic>
                ? Service.fromJson(json['service'] as Map<String, dynamic>)
                : null,
      );

  final int? id;
  final String? name;
  final bool isActive;
  final Service? service;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isActive': isActive,
    'service': service?.toJson(),
  };
}

class Service {
  Service({
    this.id,
    this.name,
    this.description,
    this.image,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'] as int?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    image: json['image'] as String?,
  );

  final int? id;
  final String? name;
  final String? description;
  final String? image;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image': image,
  };
}
