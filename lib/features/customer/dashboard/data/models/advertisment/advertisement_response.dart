

import 'package:resq360/features/customer/dashboard/data/models/payment/payment.model.dart';

class CreateAvertisementResponse {

  CreateAvertisementResponse({
    required this.message,
    required this.paymentResponse,
  });

  factory CreateAvertisementResponse.fromJson(Map<String, dynamic> json) {
    return CreateAvertisementResponse(
      message: json['message'] as String?,
      paymentResponse: json['data'] != null ? PaymentResponse.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
  final String? message;
  final PaymentResponse? paymentResponse;
}
