enum PaymentStatus {
  pending('PENDING'),
  completed('COMPLETED');

  const PaymentStatus(
    this.value,
  );
  final String value;
}
