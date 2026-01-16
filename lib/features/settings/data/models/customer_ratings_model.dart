import 'dart:convert';

class CustomerRatings {

  CustomerRatings({
    this.averageRatings,
    this.totalReviews,
    this.reviews,
  });

  factory CustomerRatings.fromRawJson(String str) =>
      CustomerRatings.fromJson(json.decode(str) as Map<String, dynamic>);

  factory CustomerRatings.fromJson(Map<String, dynamic> json) =>
      CustomerRatings(
        averageRatings: json['averageRating'] as int?,
        totalReviews: json['totalReviews'] as int?,
        reviews: json['reviews'] == null
            ? <CustomerReview>[]
            : (json['reviews'] as List)
                .map((x) => CustomerReview.fromJson(x as Map<String, dynamic>))
                .toList(),
      );
  final int? averageRatings;
  final int? totalReviews;
  final List<CustomerReview>? reviews;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'averageRatings': averageRatings,
        'totalReviews': totalReviews,
        'reviews': reviews?.map((x) => x.toJson()).toList() ?? [],
      };
}

class CustomerReview {

  CustomerReview({
    this.overallRating,
    this.ratingDate,
    this.feedback,
    this.createdAt,
    this.serviceRequest,
    this.provider,
  });

  factory CustomerReview.fromRawJson(String str) =>
      CustomerReview.fromJson(json.decode(str) as Map<String, dynamic>);

  factory CustomerReview.fromJson(Map<String, dynamic> json) => CustomerReview(
        overallRating: json['overallRating'] as int?,
        ratingDate: json['ratingDate'] as String?,
        feedback: json['feedback'] as String?,
        createdAt: json['createdAt'] as String?,
        serviceRequest: json['serviceRequest'] == null
            ? null
            : ServiceRequest.fromJson(
                json['serviceRequest'] as Map<String, dynamic>,
              ),
        provider: json['provider'] == null
            ? null
            : Provider.fromJson(
                json['provider'] as Map<String, dynamic>,
              ),
      );
  final int? overallRating;
  final String? ratingDate;
  final String? feedback;
  final String? createdAt;
  final ServiceRequest? serviceRequest;
  final Provider? provider;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'overallRating': overallRating,
        'ratingDate': ratingDate,
        'feedback': feedback,
        'createdAt': createdAt,
        'serviceRequest': serviceRequest?.toJson(),
        'provider': provider?.toJson(),
      };
}

class Provider {

  Provider({
    this.profileImage,
    this.fullName,
  });

  factory Provider.fromRawJson(String str) =>
      Provider.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Provider.fromJson(Map<String, dynamic> json) => Provider(
        profileImage: json['profileImage'] as String?,
        fullName: json['fullName'] as String?,
      );
  final String? profileImage;
  final String? fullName;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'profileImage': profileImage,
        'fullName': fullName,
      };
}
class ServiceCategory {

  ServiceCategory({
    this.name,
    this.image,
  });

  factory ServiceCategory.fromRawJson(String str) =>
      ServiceCategory.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
      ServiceCategory(
        name: json['name'] as String?,
        image: json['image'] as String?,
      );
  final String? name;
  final String? image;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
      };
}

class ServiceRequest {

  ServiceRequest({
    this.serviceCategory,
  });

  factory ServiceRequest.fromRawJson(String str) =>
      ServiceRequest.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ServiceRequest.fromJson(Map<String, dynamic> json) =>
      ServiceRequest(
        serviceCategory: json['serviceCategory'] == null
            ? null
            : ServiceCategory.fromJson(
                json['serviceCategory'] as Map<String, dynamic>,
              ),
      );
  final ServiceCategory? serviceCategory;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'serviceCategory': serviceCategory?.toJson(),
      };
}
