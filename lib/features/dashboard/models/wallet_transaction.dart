class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
  });
  final String title;
  final String date;
  final int amount;
  final bool isCredit;
}
