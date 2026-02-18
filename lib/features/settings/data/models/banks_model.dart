import 'package:resq360/core/models/api_response.dart';

class BankModel extends EmptyResponse {
  BankModel({this.name, this.code});

  factory BankModel.fromJson(Map<String, dynamic> json) {
  return BankModel(
    name: json['name'] as String?,
    code: json['code'] as String?,
  );
}

  String? name;
  String? code;

  @override
  List<Object?> get props => [name, code];
}
