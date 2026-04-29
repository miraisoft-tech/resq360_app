class CreateServiceRequestInvoice {
  const CreateServiceRequestInvoice({
    required this.userId,
    required this.providerServiceId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.invoiceId,
  });

  final int userId;
  final int providerServiceId;
  final int amount;
  final String currency;
  final String description;
  final String invoiceId;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'providerServiceId': providerServiceId,
        'amount': amount,
        'currency': currency,
        'description': description,
        'invoiceId': invoiceId,
      };
}
