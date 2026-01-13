import 'package:resq360/features/customer/dashboard/data/models/payment/payment.model.dart';

class ServicePaymentResponse {
  ServicePaymentResponse({
    required this.message,
    required this.paymentResponse,
  });

  factory ServicePaymentResponse.fromJson(Map<String, dynamic> json) {
    return ServicePaymentResponse(
      message: json['message'] as String?,
      paymentResponse: json['data'] != null 
          ? PaymentResponse.fromJson(json['data'] as Map<String, dynamic>) 
          : null,
    );
  }

  final String? message;
  final PaymentResponse? paymentResponse;
}
