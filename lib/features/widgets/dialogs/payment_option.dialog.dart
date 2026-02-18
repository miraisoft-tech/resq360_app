import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/wallet_bloc/wallet_bloc.dart';
import 'package:resq360/core/utils/app_text.util.dart';

enum PaymentMethod {
  wallet,
  existingCard,
  //how it is from BE
  // ignore_for_file: constant_identifier_names
  new_card,
}

class PaymentOptionDialog extends StatefulWidget {
  const PaymentOptionDialog({
    required this.onPaymentSelected,
    super.key,
  });

  final void Function(PaymentMethod) onPaymentSelected;

  @override
  State<PaymentOptionDialog> createState() => _PaymentOptionDialogState();
}

class _PaymentOptionDialogState extends State<PaymentOptionDialog> {
  PaymentMethod? selectedPayment;

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(FetchWalletInfo());
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(
        top: 225.h,
        bottom: selectedPayment != null ? 250.h : 300.h,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 25, vertical: 25),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GenText(
                    'Choose a Payment Method',
                    size: 16,
                    weight: FontWeight.w700,
                    color: appColors.black,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: appColors.textColor.shade400,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  var subtitle = 'Loading...';
                  var disabled = true;
                  if (state is FetchedWalletInfo) {
                    subtitle =
                        'Balance: ₦${AppTextUtil.formatAmount(state.wallet.balance?.toString() ?? '0')}';
                    disabled = false;
                  } else if (state is FetchingWalletInfoError) {
                    subtitle = 'Unable to fetch balance';
                    disabled = true;
                  }
                  return PaymentOption(
                    icon: AppAssets.ASSETS_ICONS_PAYMENT_WALLET_SVG.svg,
                    title: 'Pay from Wallet',
                    subtitle: subtitle,
                    isSelected: selectedPayment == PaymentMethod.wallet,
                    onTap:
                        disabled
                            ? null
                            : () => _selectPayment(PaymentMethod.wallet),
                  );
                },
              ),
              12.verticalSpace,
              // PaymentOption(
              //   icon: AppAssets.ASSETS_ICONS_PAYMENT_EXISTING_CARD_SVG.svg,
              //   title: 'Pay with Existing Card',
              //   subtitle: '**** **** **** 1234',
              //   isSelected: selectedPayment == PaymentMethod.existingCard,
              //   onTap: () => _selectPayment(PaymentMethod.existingCard),
              // ),
              // 12.verticalSpace,
              PaymentOption(
                icon: AppAssets.ASSETS_ICONS_PAYMENT_CARD_SVG.svg,
                title: 'Pay Online',
                bordered: true,
                isSelected: selectedPayment == PaymentMethod.new_card,
                onTap: () => _selectPayment(PaymentMethod.new_card),
              ),
              if (selectedPayment != null) ...[
                20.verticalSpace,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      widget.onPaymentSelected(selectedPayment!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.primary.shade500,
                      padding: pad(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const GenText(
                      'Continue',
                      color: Colors.white,
                      weight: FontWeight.w600,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectPayment(PaymentMethod method) {
    setState(() {
      selectedPayment = method;
    });
  }
}

class PaymentOption extends StatelessWidget {
  const PaymentOption({
    required this.icon,
    required this.title,
    this.subtitle,
    this.bordered = false,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final Widget icon;
  final String title;
  final String? subtitle;
  final bool bordered;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: pad(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? appColors.primary.shade50 : appColors.whiteColor,
          borderRadius: BorderRadius.circular(10.r),
          border:
              isSelected
                  ? Border.all(color: appColors.primary.shade500, width: 2)
                  : bordered
                  ? Border.all(color: appColors.primary)
                  : Border.all(color: appColors.textColor.shade100),
        ),
        child: Row(
          children: [
            icon,
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenText(
                    title,
                    size: 15,
                    weight: FontWeight.w600,
                    color: appColors.black,
                  ),
                  if (subtitle != null) ...[
                    2.verticalSpace,
                    GenText(
                      subtitle!,
                      size: 13,
                      color: appColors.textColor.shade400,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: appColors.primary.shade500,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
