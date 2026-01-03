class Metadata {
  Metadata({
    this.type,
    this.amount,
    this.currency,
    this.invoiceId,
    this.description,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        type: json['type'] as String?,
        amount: json['amount'] is int
            ? json['amount'] as int
            : int.tryParse(json['amount']?.toString() ?? ''),
        currency: json['currency'] as String?,
        invoiceId: json['invoiceId'] as String?,
        description: json['description'] as String?,
      );

  final String? type;        // e.g. INVOICE
  final int? amount;         // 233
  final String? currency;    // NGN
  final String? invoiceId;   // INV-441
  final String? description;

  Map<String, dynamic> toJson() => {
        'type': type,
        'amount': amount,
        'currency': currency,
        'invoiceId': invoiceId,
        'description': description,
      };
}
