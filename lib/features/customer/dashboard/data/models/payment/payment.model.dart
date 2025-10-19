
import 'dart:convert';

InitializePaymentRequest paymentFromJson(String str) => InitializePaymentRequest.fromJson(json.decode(str) as Map<String, dynamic>);

String paymentToJson(InitializePaymentRequest data) => json.encode(data.toJson());

class InitializePaymentRequest {

    InitializePaymentRequest({
        this.amount,
        this.email,
        this.currency,
        this.callbackUrl,
    });

    factory InitializePaymentRequest.fromJson(Map<String, dynamic> json) => InitializePaymentRequest(
        amount: json['amount'] as int?,
        email: json['email'] as String?,
        currency: json['currency'] as String?,
        callbackUrl: json['callback_url'] as String?,
    );
    final int? amount;
    final String? email;
    final String? currency;
    final String? callbackUrl;

    Map<String, dynamic> toJson() => {
        'amount': amount,
        'email': email,
        'currency': currency,
        'callback_url': callbackUrl,
    };
}

class PaymentResponse {

  PaymentResponse({
    required this.authorizationUrl,
    required this.accessCode,
    required this.reference,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      authorizationUrl: json['authorization_url'] as String,
      accessCode: json['access_code'] as String,
      reference: json['reference'] as String,
    );
  }
  final String authorizationUrl;
  final String accessCode;
  final String reference;
}

class PaymentVerification {
  PaymentVerification({
    required this.id,
    required this.status,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.gatewayResponse,
    required this.paidAt,
    required this.customer,
    required this.authorization,
  });

  factory PaymentVerification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json; // handle if you pass the outer object
    return PaymentVerification(
      id: data['id'] as int?,
      status: data['status'] as String?,
      reference: data['reference'] as String?,
      amount: data['amount'] as int?,
      currency: data['currency'] as String?,
      gatewayResponse: data['gateway_response'] as String?,
      paidAt: data['paid_at'] as String?,
      customer: data['customer'] != null
          ? PaymentCustomer.fromJson(data['customer'] as Map<String, dynamic>)
          : null,
      authorization: data['authorization'] != null
          ? PaymentAuthorization.fromJson(data['authorization'] as Map<String, dynamic>)
          : null,
    );
  }

  final int? id;
  final String? status;
  final String? reference;
  final int? amount;
  final String? currency;
  final String? gatewayResponse;
  final String? paidAt;
  final PaymentCustomer? customer;
  final PaymentAuthorization? authorization;
}

class PaymentCustomer {
  PaymentCustomer({
    required this.id,
    required this.email,
    required this.customerCode,
  });

  factory PaymentCustomer.fromJson(Map<String, dynamic> json) {
    return PaymentCustomer(
      id: json['id'] as int?,
      email: json['email'] as String?,
      customerCode: json['customer_code'] as String?,
    );
  }

  final int? id;
  final String? email;
  final String? customerCode;
}

class PaymentAuthorization {
  PaymentAuthorization({
    required this.authorizationCode,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.bank,
    required this.brand,
  });

  factory PaymentAuthorization.fromJson(Map<String, dynamic> json) {
    return PaymentAuthorization(
      authorizationCode: json['authorization_code'] as String?,
      last4: json['last4'] as String?,
      expMonth: json['exp_month'] as String?,
      expYear: json['exp_year'] as String?,
      bank: json['bank'] as String?,
      brand: json['brand'] as String?,
    );
  }

  final String? authorizationCode;
  final String? last4;
  final String? expMonth;
  final String? expYear;
  final String? bank;
  final String? brand;
}


