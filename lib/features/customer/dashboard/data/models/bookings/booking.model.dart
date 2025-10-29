import 'dart:convert';

class ServiceBookingsResponse {
  ServiceBookingsResponse({
    this.message,
    this.success,
    this.data,
  });

  factory ServiceBookingsResponse.fromRawJson(String str) =>
      ServiceBookingsResponse.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );


  factory ServiceBookingsResponse.fromJson(Map<String, dynamic> json) {
     final nestedData = json['data'];
    final deeperData = nestedData is Map<String, dynamic> ? nestedData['data'] : null;
    final services = deeperData is Map<String, dynamic> ? deeperData['services'] : null;
      return ServiceBookingsResponse(
        message: json['message'] == null ? null : json['message'] as String,
        success: json['success'] == null ? null : json['success'] as bool,
        data:
            services != null
          ? List<Bookings>.from(
              (services as List).map(
                (x) => Bookings.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
      );
  }
  final String? message;
  final bool? success;
  final List<Bookings>? data;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
    'data': data == null ? [] : data!.map((x) => x.toJson()).toList(),
  };
}

class Bookings {
  Bookings({
    this.id,
    this.requestId,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.amount,
    this.currency,
    this.serviceLocation,
    this.latitude,
    this.longitude,
    this.user,
    this.provider,
    this.serviceCategory,
    this.dispute,
    this.refund,
    this.payment,
    this.responseTime,
    this.cancelledBy,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
  });

  factory Bookings.fromRawJson(String str) =>
      Bookings.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Bookings.fromJson(Map<String, dynamic> json) => Bookings(
    id: json['id'] as int?,
    requestId: json['requestId'] as String?,
    title: json['title'] as String?,
    description: json['description'] as String?,
    status: json['status'] as String?,
    priority: json['priority'] as String?,
    amount: json['amount'] as int?,
    currency: json['currency'] as String?,
    serviceLocation: json['serviceLocation'] as String?,
    latitude: json['latitude'] as double?,
    longitude: json['longitude'] as double?,
    user:
        json['user'] == null
            ? null
            : User.fromJson(json['user'] as Map<String, dynamic>),
    provider:
        json['provider'] == null
            ? null
            : Provider.fromJson(json['provider'] as Map<String, dynamic>),
    serviceCategory:
        json['serviceCategory'] == null
            ? null
            : ServiceCategory.fromJson(
              json['serviceCategory'] as Map<String, dynamic>,
            ),
    dispute:
        json['dispute'] == null
            ? null
            : Dispute.fromJson(json['dispute'] as Map<String, dynamic>),
    refund:
        json['refund'] == null
            ? null
            : Refund.fromJson(json['refund'] as Map<String, dynamic>),
    payment:
        json['payment'] == null
            ? null
            : Payment.fromJson(json['payment'] as Map<String, dynamic>),
    responseTime:
        json['responseTime'] == null
            ? null
            : ResponseTime.fromJson(
              json['responseTime'] as Map<String, dynamic>,
            ),
    cancelledBy: json['cancelledBy'] as String?,
    cancellationReason: json['cancellationReason'] as String?,
    createdAt:
        json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
    updatedAt:
        json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
  );
  final int? id;
  final String? requestId;
  final String? title;
  final String? description;
  final String? status;
  final String? priority;
  final int? amount;
  final String? currency;
  final String? serviceLocation;
  final double? latitude;
  final double? longitude;
  final User? user;
  final Provider? provider;
  final ServiceCategory? serviceCategory;
  final Dispute? dispute;
  final Refund? refund;
  final Payment? payment;
  final ResponseTime? responseTime;
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'requestId': requestId,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'amount': amount,
    'currency': currency,
    'serviceLocation': serviceLocation,
    'latitude': latitude,
    'longitude': longitude,
    'user': user?.toJson(),
    'provider': provider?.toJson(),
    'serviceCategory': serviceCategory?.toJson(),
    'dispute': dispute?.toJson(),
    'refund': refund?.toJson(),
    'payment': payment?.toJson(),
    'responseTime': responseTime?.toJson(),
    'cancelledBy': cancelledBy,
    'cancellationReason': cancellationReason,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

class Dispute {
  Dispute({
    this.isDisputed,
    this.disputeReason,
    this.disputeDetails,
    this.disputedAt,
    this.disputeResolution,
  });

  factory Dispute.fromRawJson(String str) =>
      Dispute.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Dispute.fromJson(Map<String, dynamic> json) => Dispute(
    isDisputed: json['isDisputed'] as bool?,
    disputeReason: json['disputeReason'] as String?,
    disputeDetails: json['disputeDetails'] as String?,
    disputedAt:
        json['disputedAt'] == null
            ? null
            : DateTime.parse(json['disputedAt'] as String),
    disputeResolution: json['disputeResolution'] as String?,
  );
  final bool? isDisputed;
  final String? disputeReason;
  final String? disputeDetails;
  final DateTime? disputedAt;
  final String? disputeResolution;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'isDisputed': isDisputed,
    'disputeReason': disputeReason,
    'disputeDetails': disputeDetails,
    'disputedAt': disputedAt?.toIso8601String(),
    'disputeResolution': disputeResolution,
  };
}

class Payment {
  Payment({
    this.paymentReference,
    this.gatewayReference,
    this.paymentStatus,
    this.paymentFailureReason,
  });

  factory Payment.fromRawJson(String str) =>
      Payment.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    paymentReference: json['paymentReference'] as String?,
    gatewayReference: json['gatewayReference'] as String?,
    paymentStatus: json['paymentStatus'] as String?,
    paymentFailureReason: json['paymentFailureReason'] as String?,
  );
  final String? paymentReference;
  final String? gatewayReference;
  final String? paymentStatus;
  final String? paymentFailureReason;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'paymentReference': paymentReference,
    'gatewayReference': gatewayReference,
    'paymentStatus': paymentStatus,
    'paymentFailureReason': paymentFailureReason,
  };
}

class Provider {
  Provider({
    this.id,
    this.email,
    this.fullName,
    this.companyName,
    this.phoneNumber,
    this.isEmailVerified,
  });

  factory Provider.fromRawJson(String str) =>
      Provider.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Provider.fromJson(Map<String, dynamic> json) => Provider(
    id: json['id'] as int?,
    email: json['email'] as String?,
    fullName: json['fullName'] as String?,
    companyName: json['companyName'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    isEmailVerified: json['isEmailVerified'] as bool?,
  );
  final int? id;
  final String? email;
  final String? fullName;
  final String? companyName;
  final String? phoneNumber;
  final bool? isEmailVerified;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'companyName': companyName,
    'phoneNumber': phoneNumber,
    'isEmailVerified': isEmailVerified,
  };
}

class Refund {
  Refund({
    this.refundRequested,
    this.refundAmount,
    this.refundReason,
    this.refundProcessedAt,
    this.refundProcessedBy,
  });

  factory Refund.fromRawJson(String str) =>
      Refund.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Refund.fromJson(Map<String, dynamic> json) => Refund(
    refundRequested: json['refundRequested'] as bool?,
    refundAmount: json['refundAmount'] as double?,
    refundReason: json['refundReason'] as String?,
    refundProcessedAt:
        json['refundProcessedAt'] == null
            ? null
            : DateTime.parse(json['refundProcessedAt'] as String),
    refundProcessedBy: json['refundProcessedBy'] as int?,
  );
  final bool? refundRequested;
  final double? refundAmount;
  final String? refundReason;
  final DateTime? refundProcessedAt;
  final int? refundProcessedBy;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'refundRequested': refundRequested,
    'refundAmount': refundAmount,
    'refundReason': refundReason,
    'refundProcessedAt': refundProcessedAt?.toIso8601String(),
    'refundProcessedBy': refundProcessedBy,
  };
}

class ResponseTime {
  ResponseTime({
    this.responseTime,
    this.providerAcceptedAt,
    this.providerStartedAt,
    this.completedAt,
  });

  factory ResponseTime.fromRawJson(String str) =>
      ResponseTime.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ResponseTime.fromJson(Map<String, dynamic> json) => ResponseTime(
    responseTime: json['responseTime'] as int?,
    providerAcceptedAt:
        json['providerAcceptedAt'] == null
            ? null
            : DateTime.parse(json['providerAcceptedAt'] as String),
    providerStartedAt:
        json['providerStartedAt'] == null
            ? null
            : DateTime.parse(json['providerStartedAt'] as String),
    completedAt:
        json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
  );
  final int? responseTime;
  final DateTime? providerAcceptedAt;
  final DateTime? providerStartedAt;
  final DateTime? completedAt;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'responseTime': responseTime,
    'providerAcceptedAt': providerAcceptedAt?.toIso8601String(),
    'providerStartedAt': providerStartedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };
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

class User {
  User({
    this.id,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.isKycVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int?,
    email: json['email'] as String?,
    fullName: json['fullName'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    isKycVerified: json['isKYCVerified'] as bool?,
  );

  factory User.fromRawJson(String str) =>
      User.fromJson(json.decode(str) as Map<String, dynamic>);
  final int? id;
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final bool? isKycVerified;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'isKYCVerified': isKycVerified,
  };
}
