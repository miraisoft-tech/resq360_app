import 'dart:convert';

class NotificationResponse {
  NotificationResponse({
    this.notifications,
    this.pagination,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        notifications:
            json['notifications'] == null
                ? []
                : List<Notification>.from(
                  (json['notifications'] as List).map(
                    (x) => Notification.fromJson(x as Map<String, dynamic>),
                  ),
                ),
        pagination:
            json['pagination'] == null
                ? null
                : Pagination.fromJson(
                  json['pagination'] as Map<String, dynamic>,
                ),
      );

  factory NotificationResponse.fromRawJson(String str) =>
      NotificationResponse.fromJson(json.decode(str) as Map<String, dynamic>);
  final List<Notification>? notifications;
  final Pagination? pagination;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'notifications':
        notifications == null
            ? []
            : List<dynamic>.from(notifications!.map((x) => x.toJson())),
    'pagination': pagination?.toJson(),
  };
}

class Notification {
  Notification({
    this.id,
    this.title,
    this.message,
    this.category,
    this.priority,
    this.status,
    this.tags,
    this.readAt,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.provider,
    this.admin,
    this.serviceRequest,
  });

  factory Notification.fromRawJson(String str) =>
      Notification.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json['id'] as int,
    title: json['title'] as String,
    message: json['message'] as String,
    category: json['category'] as String,
    priority: json['priority'] as String,
    status: json['status'] as String,
    tags:
        json['tags'] == null
            ? []
            : List<String>.from((json['tags'] as List).map((x) => x)),
    readAt:
        json['readAt'] == null
            ? null
            : DateTime.parse(json['readAt'] as String),
    createdAt:
        json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
    updatedAt:
        json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
    user:
        json['user'] == null
            ? null
            : Provider.fromJson(json['user'] as Map<String, dynamic>),
    provider:
        json['provider'] == null
            ? null
            : Provider.fromJson(json['provider'] as Map<String, dynamic>),
    admin:
        json['admin'] == null
            ? null
            : Admin.fromJson(json['admin'] as Map<String, dynamic>),
    serviceRequest:
        json['serviceRequest'] == null
            ? null
            : ServiceRequest.fromJson(
              json['serviceRequest'] as Map<String, dynamic>,
            ),
  );
  final int? id;
  final String? title;
  final String? message;
  final String? category;
  final String? priority;
  final String? status;
  final List<String>? tags;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Provider? user;
  final Provider? provider;
  final Admin? admin;
  final ServiceRequest? serviceRequest;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'category': category,
    'priority': priority,
    'status': status,
    'tags': tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    'readAt': readAt?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'user': user?.toJson(),
    'provider': provider?.toJson(),
    'admin': admin?.toJson(),
    'serviceRequest': serviceRequest?.toJson(),
  };
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
  Provider({
    this.id,
    this.fullName,
    this.email,
    this.profileImage,
  });

  factory Provider.fromRawJson(String str) =>
      Provider.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Provider.fromJson(Map<String, dynamic> json) => Provider(
    id: json['id'] as int,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    profileImage: json['profileImage'] as String,
  );
  final int? id;
  final String? fullName;
  final String? email;
  final String? profileImage;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'profileImage': profileImage,
  };
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
