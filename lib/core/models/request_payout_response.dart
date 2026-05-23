class PayoutResponse {

  PayoutResponse({
     this.id,
     this.amount,
     this.currency,
     this.status,
     this.reference,
  });

  factory PayoutResponse.fromJson(Map<String, dynamic> json) {
    return PayoutResponse(
      id: json['id'] as int,
      amount: int.parse(json['amount'] as String),
      currency: json['currency'] as String,
      status: json['status'] as String,
      reference: json['reference'] as String,
    );
  }
  final int? id;
  final int? amount;
  final String? currency;
  final String? status;
  final String? reference;
}
