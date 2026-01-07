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

  final String? type;      
  final int? amount;         
  final String? currency;   
  final String? invoiceId;   
  final String? description;

  Map<String, dynamic> toJson() => {
        'type': type,
        'amount': amount,
        'currency': currency,
        'invoiceId': invoiceId,
        'description': description,
      };
}
