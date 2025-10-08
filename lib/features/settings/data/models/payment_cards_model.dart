class PaymentCardModel {
  PaymentCardModel({
    required this.brand,
    required this.last4,
    required this.expiry,
    this.isDefault = false,
  });
  final String brand;
  final String last4;
  final String expiry;
  final bool isDefault;
}
