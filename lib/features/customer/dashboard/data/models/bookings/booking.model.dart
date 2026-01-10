
import 'dart:convert';

class Bookings {
  Bookings({
    this.id,
    this.requestId,
    this.userId,
    this.serviceCategoryId,
    this.providerServiceId,
    this.assignedProviderId,
    this.status,
    this.description,

    this.providerStartedAt,
    this.completedAt,

    this.cancelledBy,
    this.cancellationReason,

    this.otpHash,
    this.otpExpiresAt,

    this.isDisputed,
    this.disputeReason,
    this.disputeDetails,
    this.disputeFiledAt,
    this.disputeResolverId,
    this.disputeResolvedAt,
    this.disputeResolutionNotes,

    this.responseTime,

    this.createdAt,
    this.updatedAt,

    this.user,
    this.assignedProvider,
    this.serviceCategory,
    this.paymentMethod,
    this.amount,
  });

  factory Bookings.fromJson(Map<String, dynamic> json) => Bookings(
        id: json['id'] as int?,
        requestId: json['requestId'] as String?,
        userId: json['userId'] as int?,
        serviceCategoryId: json['serviceCategoryId'] as int?,
        providerServiceId: json['providerServiceId'] as int?,
        assignedProviderId: json['assignedProviderId'] as int?,
        status: json['status'] as String?,
        description: json['description'] as String?,

        providerStartedAt: json['providerStartedAt'] == null
            ? null
            : DateTime.parse(json['providerStartedAt'] as String),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),

        cancelledBy: json['cancelledBy'] as String?,
        cancellationReason: json['cancellationReason'] as String?,

        otpHash: json['otpHash'] as String?,
        otpExpiresAt: json['otpExpiresAt'] == null
            ? null
            : DateTime.parse(json['otpExpiresAt'] as String),

        isDisputed: json['isDisputed'] as bool?,
        disputeReason: json['disputeReason'] as String?,
        disputeDetails: json['disputeDetails'] as String?,
        disputeFiledAt: json['disputeFiledAt'] == null
            ? null
            : DateTime.parse(json['disputeFiledAt'] as String),
        disputeResolverId: json['disputeResolverId'] as int?,
        disputeResolvedAt: json['disputeResolvedAt'] == null
            ? null
            : DateTime.parse(json['disputeResolvedAt'] as String),
        disputeResolutionNotes:
            json['disputeResolutionNotes'] as String?,

        responseTime: json['responseTime'],

        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),

        user: json['user'] == null
            ? null
            : User.fromJson(json['user'] as Map<String, dynamic>),
        assignedProvider: json['assignedProvider'] == null
            ? null
            : AssignedProvider.fromJson(
                json['assignedProvider'] as Map<String, dynamic>,
              ),
        serviceCategory: json['serviceCategory'] == null
            ? null
            : ServiceCategory.fromJson(
                json['serviceCategory'] as Map<String, dynamic>,
              ),
              paymentMethod: json['paymentMethod'] as String?,
              amount: json['amount'] as String?

      );

  final int? id;
  final String? requestId;

  final int? userId;
  final int? serviceCategoryId;
  final int? providerServiceId;
  final int? assignedProviderId;

  final String? status;
  final String? description;

  final DateTime? providerStartedAt;
  final DateTime? completedAt;

  final String? cancelledBy;
  final String? cancellationReason;

  final String? otpHash;
  final DateTime? otpExpiresAt;

  final bool? isDisputed;
  final String? disputeReason;
  final String? disputeDetails;
  final DateTime? disputeFiledAt;
  final int? disputeResolverId;
  final DateTime? disputeResolvedAt;
  final String? disputeResolutionNotes;

  final dynamic responseTime;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final User? user;
  final AssignedProvider? assignedProvider;
  final ServiceCategory? serviceCategory;
  final String? paymentMethod;
  final String? amount;
}



class AssignedProvider {
  AssignedProvider({
    this.id,
    this.fullName,
    this.profileImage,
    this.phoneNumber,

  });

  factory AssignedProvider.fromJson(Map<String, dynamic> json) => AssignedProvider(
        id: json['id'] as int?,
        fullName: json['fullName'] as String?,
        profileImage: json['profileImage'] as String?,
        phoneNumber: json['phoneNumber'] as String?
      );

  final int? id;
  final String? fullName;
  final String? profileImage;
  final String? phoneNumber;

}

class User {
  User({
    this.id,
    this.fullName,
    this.profileImage,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int?,
        fullName: json['fullName'] as String?,
        profileImage: json['profileImage'] as String?,
        phoneNumber: json['phoneNumber'] as String?
      );

  final int? id;
  final String? fullName;
  final String? profileImage;
  final String? phoneNumber;
}
class ServiceCategory {
  ServiceCategory({
    this.id,
    this.name,
    this.description,
    this.image,
  });

  factory ServiceCategory.fromRawJson(String str) =>
      ServiceCategory.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
      ServiceCategory(
        id: json['id'] as int?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        image: json['image'] as String?,
      );
  final int? id;
  final String? name;
  final String? description;
  final String? image;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image': image,
  };
}
