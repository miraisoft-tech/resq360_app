// ignore_for_file: must_be_immutable, document_ignores

import 'package:equatable/equatable.dart';

class EmptyResponse extends Equatable {
  @override
  List<Object?> get props => [];
}

class ErrorResponse extends EmptyResponse {
  ErrorResponse({this.message});
  ErrorResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'] as String?;
  }

  String? message;
  String get errorMessage => message ?? '';

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (message != null) {
      data['message'] = message;
    }
    return data;
  }
}
