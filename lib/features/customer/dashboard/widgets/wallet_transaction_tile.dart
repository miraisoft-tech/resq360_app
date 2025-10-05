import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/models/wallet_transaction.dart';

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({
    required this.tx,
    required this.onTap,
    super.key,
  });

  final WalletTransaction tx;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final color =
        tx.isCredit ? appColors.success.shade700 : appColors.error.shade500;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: pad(horizontal: 12, vertical: 18),
        decoration: BoxDecoration(
          color: appColors.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: appColors.textColor.shade100),
        ),
        child: Row(
          children: [
            if (tx.isCredit)
              AppAssets.ASSETS_ICONS_WALLET_CREDIT_SVG.svg
            else
              AppAssets.ASSETS_ICONS_WALLET_DEBIT_SVG.svg,
            30.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenText(
                    tx.title,
                    weight: FontWeight.w500,
                    color: appColors.black,
                  ),
                  4.verticalSpace,
                  GenText(
                    tx.date,
                    size: 12,
                    height: 18.5,
                    weight: FontWeight.w400,
                    color: appColors.textColor.shade400,
                  ),
                ],
              ),
            ),
            GenText(
              '${tx.isCredit ? '+' : '-'}₦${tx.amount.abs()}',
              size: 15,
              weight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
