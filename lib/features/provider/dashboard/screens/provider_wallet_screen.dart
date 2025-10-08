import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/customer/dashboard/models/wallet_transaction.dart';
import 'package:resq360/features/customer/dashboard/screens/transaction_detail.modal.dart';
import 'package:resq360/features/customer/dashboard/widgets/wallet_transaction_tile.dart';
import 'package:resq360/features/provider/dashboard/screens/provider_withdraw_screen.dart';
import 'package:resq360/features/widgets/dialogs/fund_method.dialog.dart';
import 'package:resq360/features/widgets/dialogs/fund_wallet_confirm.dialog.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';

class ProviderWalletScreen extends StatelessWidget {
  const ProviderWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final transactions = [
      const WalletTransaction(
        title: 'QuickTow Emergency',
        date: 'Aug 15th, 5:16pm',
        amount: 7500,
        isCredit: true,
      ),
      const WalletTransaction(
        title: 'QuickTow Emergency',
        date: 'Aug 15th, 2:00pm',
        amount: -15000,
        isCredit: false,
      ),
      const WalletTransaction(
        title: 'QuickTow Emergency',
        date: 'Aug 15th, 2:00pm',
        amount: 7500,
        isCredit: true,
      ),
      const WalletTransaction(
        title: 'QuickTow Emergency',
        date: 'Aug 15th, 2:00pm',
        amount: -15000,
        isCredit: false,
      ),
    ];

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: UrbText(
          'My Wallet',
          color: appColors.black,
          size: 22,
          height: 28.5,
          weight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: pad(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProviderWalletBalanceCard(
              balance: 45000,
              onAddFunds: () async {
                await GeneralDialogs.showCustomDialog(
                  context,
                  body: FundMethodDialog(
                    onPaymentSelected: (PaymentMethod p1) async {
                      await GeneralDialogs.showCustomDialog(
                        context,
                        body: const FundWalletConfirmDialog(
                          amount: '₦20,000',
                        ),
                      );
                    },
                  ),
                );
              },
              onWithdraw: () async {
                await pushScreen(context, const ProviderWithdrawScreen());
              },
            ),
            30.verticalSpace,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GenText(
                  'Transaction History',
                  size: 18,
                  weight: FontWeight.w700,
                  color: appColors.black,
                ),
                GenText(
                  'View All',
                  size: 12,
                  weight: FontWeight.w400,
                  color: appColors.primary.shade500,
                ),
              ],
            ),
            16.verticalSpace,
            if (transactions.isEmpty)
              const EmptyScreenWidget(
                imagePath: AppAssets.ASSETS_IMAGES_EMPTY_WALLET_PNG,
                message: 'No Transactions Yet',
                subMessage:
                    'Your wallet history will appear here after yourfirst payment or credit',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return WalletTransactionTile(
                    tx: tx,
                    onTap: () async {
                      await GeneralDialogs.showCustomBottomSheet(
                        context,
                        body: TransactionDetailModal(
                          onRetry: () {},
                          onSupport: () {},
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => 16.verticalSpace,
                itemCount: transactions.length,
              ),
          ],
        ),
      ),
    );
  }
}

class ProviderWalletBalanceCard extends StatelessWidget {
  const ProviderWalletBalanceCard({
    required this.balance,
    required this.onAddFunds,
    required this.onWithdraw,
    super.key,
  });

  final int balance;
  final VoidCallback onAddFunds;
  final VoidCallback onWithdraw;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      padding: pad(vertical: 24, horizontal: 18),
      decoration: BoxDecoration(
        color: appColors.primary.shade500,
        borderRadius: BorderRadius.circular(12.r),
        image: DecorationImage(
          image: const AssetImage(AppAssets.ASSETS_IMAGES_APPLE_PNG),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            appColors.primary.shade500,
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Column(
        children: [
          GenText(
            'Available Balance',
            size: 12,
            height: 18.5,
            color: appColors.whiteColor,
            weight: FontWeight.w500,
          ),
          4.verticalSpace,
          UrbText(
            '₦${AppTextUtil.formatAmount(balance.toStringAsFixed(0))}',
            color: appColors.whiteColor,
            size: 30,
            height: 32.5,
            weight: FontWeight.w700,
          ),
          16.verticalSpace,
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32.h,
                  child: ElevatedButton.icon(
                    onPressed: onAddFunds,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.whiteColor,
                      padding: pad(vertical: 10, horizontal: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(Icons.add, color: appColors.primary.shade500),
                    label: GenText(
                      'Add Funds',
                      height: 16.5,
                      color: appColors.primary.shade500,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: SizedBox(
                  height: 32.h,
                  child: ElevatedButton.icon(
                    onPressed: onWithdraw,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.whiteColor,
                      padding: pad(vertical: 10, horizontal: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(Icons.send, color: appColors.primary.shade500),
                    label: GenText(
                      'Withdraw',
                      height: 16.5,
                      color: appColors.primary.shade500,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
