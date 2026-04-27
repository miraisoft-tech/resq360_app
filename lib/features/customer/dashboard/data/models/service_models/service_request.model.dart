import 'package:flutter/foundation.dart';

@immutable
class Service {
  const Service({
    required this.id,
    required this.name,
    required this.image,
    required this.imageId,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      imageId: json['imageId']?.toString(),
      description: json['description']?.toString() ?? '',
      createdBy: json['createdBy']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  final int id;
  final String name;
  final String image;
  final String? imageId;
  final String description;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'imageId': imageId,
    'description': description,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'status': status,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Service && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ServiceProvider {
  ServiceProvider({
    required this.id,
    required this.companyName,
    required this.activityStatus,
    required this.openingHours,
    required this.closingHours,
    required this.workingDays,
    required this.description,
    required this.images,
    required this.profileImage,
    required this.providerServices,
    required this.serviceRequests,
    required this.distance,
    required this.averageRating,
    required this.totalReviews,
    required this.serviceName,
    required this.providerServiceId,
    this.fullName,
    this.phoneNumber,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as int,
      fullName: json['fullName']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      activityStatus: json['activityStatus']?.toString(),
      openingHours: json['openingHours']?.toString(),
      closingHours: json['closingHours']?.toString(),
      workingDays:
          (json['workingDays'] as List? ?? [])
              .map((e) => e.toString())
              .toList(),
      description: json['description']?.toString(),
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
      profileImage: json['profileImage']?.toString(),
      providerServices:
          (json['ProviderService'] as List? ?? [])
              .map((e) => ProviderService.fromJson(e as Map<String, dynamic>))
              .toList(),
      serviceRequests:
          (json['ServiceRequest'] as List? ?? [])
              .map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>))
              .toList(),
      distance:
          json['distance'] == null
              ? null
              : (json['distance'] as num).toDouble(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: json['totalReviews'] as int?,
      serviceName: json['serviceName']?.toString(),
      providerServiceId: json['providerServiceId'] as int?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  final int id;
  final String companyName;
  final String? activityStatus;
  final String? openingHours;
  final String? closingHours;
  final List<String> workingDays;
  final String? description;
  final List<String> images;
  final String? profileImage;
  final List<ProviderService> providerServices;
  final List<ServiceRequest> serviceRequests;
  final double? distance;
  final double? averageRating;
  final int? totalReviews;
  final String? serviceName;
  final int? providerServiceId;
  final String? phoneNumber;
  final String? fullName;
}

class ProviderService {
  ProviderService({
    required this.id,
    required this.name,
    required this.isActive,
    required this.serviceId,
    required this.providerId,
    required this.createdAt,
    required this.updatedAt,
    required this.service,
    required this.minorServices,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    return ProviderService(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      serviceId: json['serviceId'] as int,
      providerId: json['providerId'] as int,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      minorServices:
          (json['minorServices'] as List? ?? [])
              .map((e) => e.toString())
              .toList(),
      service: Service.fromJson(json['service'] as Map<String, dynamic>),
    );
  }

  final int id;
  final String name;
  final bool isActive;
  final int serviceId;
  final int providerId;
  final String createdAt;
  final String updatedAt;
  final List<String> minorServices;
  final Service service;
}

class ServiceRequest {
  ServiceRequest({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.serviceCategoryId,
    required this.providerServiceId,
    required this.status,
    required this.description,
    required this.assignedProviderId,
    required this.providerStartedAt,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.customerSatisfactionScore,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as int,
      requestId: json['requestId']?.toString() ?? '',
      userId: json['userId'] as int,
      serviceCategoryId: json['serviceCategoryId'] as int,
      providerServiceId: json['providerServiceId'] as int,
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString(),
      assignedProviderId: json['assignedProviderId'] as int?,
      providerStartedAt: json['providerStartedAt']?.toString(),
      completedAt: json['completedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      customerSatisfactionScore: json['CustomerSatisfactionScore'],
    );
  }

  final int id;
  final String requestId;
  final int userId;
  final int serviceCategoryId;
  final int providerServiceId;
  final String status;
  final String? description;
  final int? assignedProviderId;
  final String? providerStartedAt;
  final String? completedAt;
  final String createdAt;
  final String updatedAt;
  final dynamic customerSatisfactionScore;
}
