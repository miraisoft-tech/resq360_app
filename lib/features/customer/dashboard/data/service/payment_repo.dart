import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/core/utils/build_config.dart';
import 'package:resq360/features/customer/dashboard/data/models/payment/payment.model.dart';

class PaymentRepo extends BaseAPI {
  factory PaymentRepo() {
    return _instance;
  }

  PaymentRepo._internal();
  static final PaymentRepo _instance = PaymentRepo._internal();

  Future<ApiResult<PaymentResponse>> fundWallet({
    required int amount,
    required String userType,
  }) async {
    const url = '/wallet/fund';
    final data = {
      'amount': amount * 10,
      'userType': userType,
    };

    log('fund wallet Data: $data');
    try {
      final response = await dio().post<Map<String, dynamic>>(
        url,
        data: data,
      );

      if (response.statusCode == 201 && response.data != null) {
        final json = response.data!;
        final paymentData = PaymentResponse.fromJson(
          json['data'] as Map<String, dynamic>,
        );
        return ApiResult(data: paymentData);
      } else {
        return ApiResult(error: response.data!['message'].toString());
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<PaymentResponse>> initiatePayment({
    required int amount,
    required String email,
    required String currency,
    required String callbackUrl,
  }) async {
    const url = '/payment/initialize';
    final data = {
      'amount': amount * 100,
      'email': email,
      'currency': currency,
      'callback_url': callbackUrl,
    };

    log('Initiate Payment Request Data: $data');
    try {
      final response = await dio().post<Map<String, dynamic>>(
        url,
        data: data,
      );

      if (response.statusCode == 201 && response.data != null) {
        final json = response.data!;
        final paymentData = PaymentResponse.fromJson(
          json['data'] as Map<String, dynamic>,
        );
        return ApiResult(data: paymentData);
      } else {
        return ApiResult(error: 'Failed to initiate payment');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<PaymentResponse>> initiatePaymentForAServiceRequest({
    required int chatId,
    required int invoiceMessageId,
    required String paymentMethod,
  }) async {
    const url = '/requests/initiate-service-request-payment';
    final data = {
      'chatId': chatId,
      'invoiceMessageId': invoiceMessageId,
      'paymentMethod': paymentMethod,
    };

    log('Initiate Payment for a service Data: $data');
    try {
      final response = await dio().post<Map<String, dynamic>>(
        url,
        data: data,
      );

      if (response.statusCode == 201 && response.data != null) {
        final json = response.data!;
        final paymentData = PaymentResponse.fromJson(
          json['data'] as Map<String, dynamic>,
        );
        return ApiResult(data: paymentData);
      } else {
          final error = response.data!['message'] as String;
log(error);
        return ApiResult(error: error);
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<PaymentVerification>> verifyPayment(String reference) async {
    final url = '/payment/verify/$reference';

    try {
      final response = await dio().get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data!;
        log('Payment verification response JSON: $json');
        final verificationData = PaymentVerification.fromJson(json);
        return ApiResult(data: verificationData);
      } else {
        return ApiResult(error: 'Failed to verify payment');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  //   Future<ApiResult<>> verifyTransaction(
  //   String reference,
  // ) async {
  //   final res = await dio().get('/transaction/$reference');

  //   if (res.statusCode == 200) {
  //     return ApiResult(data: TransactionResponse.fromJson(res.data));
  //   }

  //   return ApiResult(error: 'Payment verification failed');
  // }

  Future<ApiResult<EmptyResponse>> payStackPayment() async {
    try {
      const url = '/payment/paystack/webhook';
      final response = await dio().post<Map<String, dynamic>>(url);
      if (response.statusCode == 200 && response.data != null) {
        return ApiResult(data: EmptyResponse());
      } else {
        return ApiResult(error: 'Failed to process PayStack payment');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }
}
