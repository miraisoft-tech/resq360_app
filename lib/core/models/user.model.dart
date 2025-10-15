
// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

AuthResponse  userFromJson(String str) => AuthResponse .fromJson(json.decode(str) as Map<String, dynamic>);

String userToJson(AuthResponse  data) => json.encode(data.toJson());

class AuthResponse  {

    AuthResponse ({
        required this.accessToken,
        required this.user,
    });

    factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse (
        accessToken: json['access_token'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
    String accessToken;
    User user;

    Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'user': user.toJson(),
    };
}

class User {

    User({
        required this.id,
        required this.email,
        required this.firstName,
        required this.lastName,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
    );
    String id;
    String email;
    String firstName;
    String lastName;

    Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
    };
}