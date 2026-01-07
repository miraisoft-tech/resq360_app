import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/provider/authentication/data/models/address.model.dart';

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
    this.kycVerification,
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
      kycVerification:
    json['kYCVerification'] is Map<String, dynamic>
        ? KYCVerification.fromJson(
            json['kYCVerification'] as Map<String, dynamic>,
          )
        : null,
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
  final KYCVerification? kycVerification;
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
    'kYCVerification': kycVerification?.toJson(),
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


class KYCVerification {
  KYCVerification({
    this.id,
    this.subjectType,
    this.subjectId,
    this.documentType,
    this.documentImageUrl,
    this.selfieImageUrl,
    this.selfieImageId,
    this.fullName,
    this.dateOfBirth,
    this.expiryDate,
    this.issueDate,
    this.issuer,
    this.nationality,
    this.state,
    this.address,
    this.city,
    this.companyName,
    this.registrationNumber,
    this.gender,
    this.status,
    this.verificationNotes,
    this.approvedKycs,
    this.verifiedAt,
    this.verifiedBy,
    this.expiresAt,
    this.submittedAt,
    this.updatedAt,
    this.addressJobId,
    this.addressJobNextCheck,
    this.userId,
    this.providerId,
  });

  factory KYCVerification.fromJson(Map<String, dynamic> json) {
    return KYCVerification(
      id: json['id'] as int?,
      subjectType: json['subjectType'] as String?,
      subjectId: json['subjectId'] as int?,
      documentType: json['documentType'] as String?,
      documentImageUrl: json['documentImageUrl'] as String?,
      selfieImageUrl: json['selfieImageUrl'] as String?,
      selfieImageId: json['selfieImageId'],
      fullName: json['fullName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      expiryDate: json['expiryDate'] as String?,
      issueDate: json['issueDate'] as String?,
      issuer: json['issuer'] as String?,
      nationality: json['nationality'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      companyName: json['companyName'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      gender: json['gender'] as String?,
      status: json['status'] as String?,
      verificationNotes: json['verificationNotes'] as String?,
      approvedKycs:
          (json['approvedKycs'] as List?)?.map((e) => e.toString()).toList(),
      verifiedAt: json['verifiedAt'] as String?,
      verifiedBy: json['verifiedBy'],
      expiresAt: json['expiresAt'] as String?,
      submittedAt: json['submittedAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      addressJobId: json['addressJobId'],
      addressJobNextCheck: json['addressJobNextCheck'],
      userId: json['userId'],
      providerId: json['providerId'] as int?,
    );
  }

  final int? id;
  final String? subjectType;
  final int? subjectId;
  final String? documentType;
  final String? documentImageUrl;
  final String? selfieImageUrl;
  final dynamic selfieImageId;
  final String? fullName;
  final String? dateOfBirth;
  final String? expiryDate;
  final String? issueDate;
  final String? issuer;
  final String? nationality;
  final String? state;
  final String? address;
  final String? city;
  final String? companyName;
  final String? registrationNumber;
  final String? gender;
  final String? status;
  final String? verificationNotes;
  final List<String>? approvedKycs;
  final String? verifiedAt;
  final dynamic verifiedBy;
  final String? expiresAt;
  final String? submittedAt;
  final String? updatedAt;
  final dynamic addressJobId;
  final dynamic addressJobNextCheck;
  final dynamic userId;
  final int? providerId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectType': subjectType,
        'subjectId': subjectId,
        'documentType': documentType,
        'documentImageUrl': documentImageUrl,
        'selfieImageUrl': selfieImageUrl,
        'selfieImageId': selfieImageId,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'expiryDate': expiryDate,
        'issueDate': issueDate,
        'issuer': issuer,
        'nationality': nationality,
        'state': state,
        'address': address,
        'city': city,
        'companyName': companyName,
        'registrationNumber': registrationNumber,
        'gender': gender,
        'status': status,
        'verificationNotes': verificationNotes,
        'approvedKycs': approvedKycs,
        'verifiedAt': verifiedAt,
        'verifiedBy': verifiedBy,
        'expiresAt': expiresAt,
        'submittedAt': submittedAt,
        'updatedAt': updatedAt,
        'addressJobId': addressJobId,
        'addressJobNextCheck': addressJobNextCheck,
        'userId': userId,
        'providerId': providerId,
      };
}
