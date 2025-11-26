
class Metadata {

  Metadata({
    this.date,
    this.amount,
    this.invoiceNo,
    this.clientName,
    this.description,
    this.serviceCategory,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        date: json['Date'] as String?,
         amount: json['amount'] is int
          ? json['amount'] as int
          : int.tryParse(json['amount']?.toString() ?? ''),
        invoiceNo: json['InvoiceNo'] as String?,
        clientName: json['ClientName'] as String?,
        description: json['description'] as String?,
        serviceCategory: json['serviceCategory'] as String?,
      );
  final String? date;
  final int? amount;
  final String? invoiceNo;
  final String? clientName;
  final String? description;
  final String? serviceCategory;

  Map<String, dynamic> toJson() => {
        'Date': date,
        'amount': amount,
        'InvoiceNo': invoiceNo,
        'ClientName': clientName,
        'description': description,
        'serviceCategory': serviceCategory,
      };
}
