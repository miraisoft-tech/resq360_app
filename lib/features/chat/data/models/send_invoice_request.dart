import 'dart:convert';

class SendInvoice {
  SendInvoice({
    this.userId,
    this.providerServiceId,
    this.chatId,
    this.amount,
    this.currency,
    this.description,
    this.invoiceId,
    this.fileName,
    this.fileUrl,
    this.fileSize,
    this.mimeType,
    this.date,
  });

  factory SendInvoice.fromRawJson(String str) =>
      SendInvoice.fromJson(json.decode(str) as Map<String, dynamic>);

  factory SendInvoice.fromJson(Map<String, dynamic> json) => SendInvoice(
    chatId: json['chatId'] as int?,
    amount: json['amount'] as int?,
    currency: json['currency'] as String?,
    description: json['description'] as String?,
    invoiceId: json['invoiceId'] as String?,
    fileName: json['fileName'] as String?,
    fileUrl: json['fileUrl'] as String?,
    fileSize: json['fileSize'] as int?,
    mimeType: json['mimeType'] as String?,
    date: json['date'] as DateTime?,
  );
  final int? chatId;
  final int? amount;
  final String? currency;
  final String? description;
  final String? invoiceId;
  final String? fileName;
  final String? fileUrl;
  final int? fileSize;
  final String? mimeType;
  final DateTime? date;
  final int? userId;
  final int? providerServiceId;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'providerServiceId': providerServiceId,
    'chatId': chatId,
    'amount': amount,
    'currency': currency,
    'description': description,
    'invoiceId': invoiceId,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'fileSize': fileSize,
    'mimeType': mimeType,
    'date': date?.toIso8601String(),
  };
}
