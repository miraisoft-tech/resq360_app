class InvoiceFormData {
  InvoiceFormData({
    required this.invoiceNo,
    required this.chatId,
    required this.userId,
    required this.providerServiceId,
    required this.serviceCategory,
    required this.location,
    required this.price,
    required this.description,
    required this.date,
  });

  final String invoiceNo;
  final int? chatId;
  final int? userId;
  final int providerServiceId;
  final String serviceCategory;
  final String location;
  final int price;
  final String description;
  final DateTime date;
}
