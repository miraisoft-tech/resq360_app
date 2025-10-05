import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';

final signupProvider = Provider<SignupModel>((ref) {
  return SignupModel();
});

class SignupModel extends EmptyResponse {
  SignupModel({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.otpCode,
    this.reference,
    this.id,
  });

  SignupModel.fromJson(Map<String, dynamic> json) {
    otpCode = json['otpCode'] as String?;
    email = json['email'] as String?;
    reference = json['reference'] as String?;
    id = json['id'] as String?;
    firstName = json['firstName'] as String?;
    lastName = json['lastName'] as String?;
    phoneNumber = json['phoneNumber'] as String?;
  }

  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? otpCode;
  String? reference;
  String? id;
}
