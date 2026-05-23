import 'dart:convert';

import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';

class Advertisement {

    Advertisement({
        this.id,
        this.title,
        this.description,
        this.imageUrl,
        this.targetUrl,
        this.serviceType,
        this.adType,
        this.status,
        this.startDate,
        this.endDate,
        this.budget,
        this.clickCount,
        this.impressionCount,
        this.isActive,
        this.providerId,
        this.adminId,
        this.createdAt,
        this.updatedAt,
        this.provider,
        this.admin,
    });

    factory Advertisement.fromRawJson(String str) => Advertisement.fromJson(json.decode(str) as Map<String, dynamic>);

    factory Advertisement.fromJson(Map<String, dynamic> json) => Advertisement(
        id: json['id'] as int?,
        title: json['title'] as String?,
        description: json['description']as String?,
        imageUrl: json['imageUrl']as String?,
        targetUrl: json['targetUrl']as String?,
        serviceType: json['serviceType']as String?,
        adType: json['adType']as String?,
        status: json['status']as String?,
        startDate: json['startDate'] == null ? null : DateTime.parse(json['startDate']as String),
        endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate']as String),
        budget: json['budget'] as int?,
        clickCount: json['clickCount'] as int?,
        impressionCount: json['impressionCount']as int?,
        isActive: json['isActive'] as bool?,
        providerId: json['providerId']as int?,
        adminId: json['adminId']as int?,
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt']as String),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt']as String),
        provider: json['provider'] == null ? null : ProviderModel.fromJson(json['provider']as Map<String, dynamic>),
        admin: json['admin'] == null ? null : Admin.fromJson(json['admin'] as Map<String, dynamic>),
    );
    final int? id;
    final String? title;
    final String? description;
    final String? imageUrl;
    final String? targetUrl;
    final String? serviceType;
    final String? adType;
    final String? status;
    final DateTime? startDate;
    final DateTime? endDate;
    final int? budget;
    final int? clickCount;
    final int? impressionCount;
    final bool? isActive;
    final int? providerId;
    final int? adminId;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final ProviderModel? provider;
    final Admin? admin;

    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'targetUrl': targetUrl,
        'serviceType': serviceType,
        'adType': adType,
        'status': status,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'budget': budget,
        'clickCount': clickCount,
        'impressionCount': impressionCount,
        'isActive': isActive,
        'providerId': providerId,
        'adminId': adminId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'provider': provider?.toJson(),
        'admin': admin?.toJson(),
    };
}

class Admin {
    Admin();

    factory Admin.fromJson(_) => Admin(
    );

    // factory Admin.fromRawJson(String str) => Admin.fromJson(json.decode(str) as Map<String, dynamic>);

    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
    };
}
