import 'dart:convert';

class NotificationResponse {

  const NotificationResponse({
    this.notifications = const [],
    this.pagination,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notifications: (json['notifications'] as List?)
              ?.map((e) => Notification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pagination: json['pagination'] is Map<String, dynamic>
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
  final List<Notification> notifications;
  final Pagination? pagination;
}


class Notification {

  const Notification({
    this.id,
    this.category,
    this.details,
    this.status,
    this.tags = const [],
    this.createdBy,
    this.priority,
    this.userId,
    this.providerId,
    this.adminId,
    this.serviceRequestId,
    this.metadata,
    this.entityType,
    this.entityId,
    this.createdAt,
    this.updatedAt,
    this.readAt,
    this.user,
    this.provider,
    this.admin,
    this.serviceRequest,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int?,
      category: json['category']?.toString(),
      details: json['details']?.toString(),
      status: json['status']?.toString(),

      tags: (json['tags'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],

      createdBy: json['createdBy']?.toString(),
      priority: json['priority']?.toString(),

      userId: json['userId'] as int?,
      providerId: json['providerId'] as int?,
      adminId: json['adminId'] as int?,

      serviceRequestId: json['serviceRequestId']?.toString(),

      metadata: json['metadata'] is Map<String, dynamic>
          ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,

      entityType: json['entityType']?.toString(),
      entityId: json['entityId'] as int?,

      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      readAt: _parseDate(json['readAt']),

      user: json['user'] is Map<String, dynamic>
          ? Provider.fromJson(json['user'] as Map<String, dynamic>)
          : null,

      provider: json['provider'] is Map<String, dynamic>
          ? Provider.fromJson(json['provider'] as Map<String, dynamic>)
          : null,

      admin: json['admin'] is Map<String, dynamic>
          ? Admin.fromJson(json['admin'] as Map<String, dynamic>)
          : null,

      serviceRequest: json['serviceRequest'] is Map<String, dynamic>
          ? ServiceRequest.fromJson(json['serviceRequest'] as Map<String, dynamic>)
          : null,
    );
  }
  final int? id;
  final String? category;
  final String? details;
  final String? status;
  final List<String> tags;
  final String? createdBy;
  final String? priority;

  final int? userId;
  final int? providerId;
  final int? adminId;

  final String? serviceRequestId;
  final Metadata? metadata;

  final String? entityType;
  final int? entityId;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? readAt;

  final Provider? user;
  final Provider? provider;
  final Admin? admin;

  final ServiceRequest? serviceRequest;

  static DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class Admin {
  Admin({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
  });

  factory Admin.fromRawJson(String str) =>
      Admin.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
    id: json['id'] as int,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
  );
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
  };
}

class Provider {

  const Provider({
    this.id,
    this.fullName,
    this.email,
    this.profileImage,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] as int?,
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }
  final int? id;
  final String? fullName;
  final String? email;
  final String? profileImage;
}


class Metadata {

  const Metadata({
    this.status,
    this.serviceDescription,
    this.severity,
    this.complaintType,
    this.requiresAction,
    this.amount,
    this.netAmount,
    this.payoutDate,
    this.serviceFee,
    this.paymentMethod,
    this.transactionId,
    this.serviceType,
    this.providerName,
    this.estimatedArrival,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      status: json['status']?.toString(),
      serviceDescription: json['serviceDescription']?.toString(),
      severity: json['severity']?.toString(),
      complaintType: json['complaintType']?.toString(),
      requiresAction: json['requiresAction'] as bool?,
      amount: json['amount'] as int?,
      netAmount: json['netAmount'] as int?,
      payoutDate: _parseDate(json['payoutDate']),
      serviceFee: json['serviceFee'] as int?,
      paymentMethod: json['paymentMethod']?.toString(),
      transactionId: json['transactionId']?.toString(),
      serviceType: json['serviceType']?.toString(),
      providerName: json['providerName']?.toString(),
      estimatedArrival: json['estimatedArrival']?.toString(),
    );
  }
  final String? status;
  final String? serviceDescription;
  final String? severity;
  final String? complaintType;
  final bool? requiresAction;
  final int? amount;
  final int? netAmount;
  final DateTime? payoutDate;
  final int? serviceFee;
  final String? paymentMethod;
  final String? transactionId;
  final String? serviceType;
  final String? providerName;
  final String? estimatedArrival;

  static DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}


class ServiceRequest {
  ServiceRequest({
    this.id,
    this.description,
    this.status,
  });

  factory ServiceRequest.fromRawJson(String str) =>
      ServiceRequest.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ServiceRequest.fromJson(Map<String, dynamic> json) => ServiceRequest(
    id: json['id'] as int,
    description: json['description'] as String,
    status: json['status'] as String,
  );
  final int? id;
  final String? description;
  final String? status;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'status': status,
  };
}

class Pagination {
  Pagination({
    this.total,
    this.page,
    this.limit,
    this.totalPages,
  });

  factory Pagination.fromRawJson(String str) =>
      Pagination.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'] as int,
    page: json['page'] as int,
    limit: json['limit'] as int,
    totalPages: json['totalPages'] as int,
  );
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };
}
