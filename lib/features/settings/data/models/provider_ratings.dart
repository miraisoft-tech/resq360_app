import 'dart:convert';

class ProviderRatings {

  ProviderRatings({
    this.averageRatings,
    this.totalReviews,
    this.reviews,
  });

  factory ProviderRatings.fromRawJson(String str) =>
      ProviderRatings.fromJson(json.decode(str) as Map<String, dynamic>);

  factory ProviderRatings.fromJson(Map<String, dynamic> json) =>
      ProviderRatings(
        averageRatings: json['averageRatings'] as int?,
        totalReviews: json['totalReviews'] as int?,
        reviews: json['reviews'] == null
            ? <Review>[]
            : (json['reviews'] as List)
                .map((x) => Review.fromJson(x as Map<String, dynamic>))
                .toList(),
      );
  final int? averageRatings;
  final int? totalReviews;
  final List<Review>? reviews;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'averageRatings': averageRatings,
        'totalReviews': totalReviews,
        'reviews': reviews?.map((x) => x.toJson()).toList() ?? [],
      };
}

class Review {

  Review({
    this.overallRating,
    this.ratingDate,
    this.feedback,
    this.createdAt,
    this.serviceRequest,
    this.user,
  });

  factory Review.fromRawJson(String str) =>
      Review.fromJson(json.decode(str) as Map<String, dynamic>);

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        overallRating: json['overallRating'] as int?,
        ratingDate: json['ratingDate'] as String?,
        feedback: json['feedback'] as String?,
        createdAt: json['createdAt'] as String?,
        serviceRequest: json['serviceRequest'] == null
            ? null
            : ServiceRequest.fromJson(
                json['serviceRequest'] as Map<String, dynamic>,
              ),
        user: json['user'] == null
            ? null
            : User.fromJson(json['user'] as Map<String, dynamic>),
      );
  final int? overallRating;
  final String? ratingDate;
  final String? feedback;
  final String? createdAt;
  final ServiceRequest? serviceRequest;
  final User? user;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'overallRating': overallRating,
        'ratingDate': ratingDate,
        'feedback': feedback,
        'createdAt': createdAt,
        'serviceRequest': serviceRequest?.toJson(),
        'user': user?.toJson(),
      };
}
class ServiceRequest {

  ServiceRequest({this.serviceCategory});

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

class User {

  User({
    this.profileImage,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        profileImage: json['profileImage'] as String?,
        fullName: json['fullName'] as String?,
      );

  factory User.fromRawJson(String str) =>
      User.fromJson(json.decode(str) as Map<String, dynamic>);
  final String? profileImage;
  final String? fullName;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'profileImage': profileImage,
        'fullName': fullName,
      };
}
