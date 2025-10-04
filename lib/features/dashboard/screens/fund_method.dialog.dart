import 'package:resq360/__lib.dart';
import 'package:resq360/features/chat/screens/payment_option.dialog.dart';

class FundMethodDialog extends StatefulWidget {
  const FundMethodDialog({
    required this.onPaymentSelected,
    super.key,
  });

  final void Function(PaymentMethod) onPaymentSelected;

  @override
  State<FundMethodDialog> createState() => _FundMethodDialogState();
}

class _FundMethodDialogState extends State<FundMethodDialog> {
  PaymentMethod? selectedPayment;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(
        top: 225.h,
        bottom: selectedPayment != null ? 275.h : 340.h,
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
              PaymentOption(
                icon: AppAssets.ASSETS_ICONS_PAYMENT_EXISTING_CARD_SVG.svg,
                title: 'Pay with Existing Card',
                subtitle: '**** **** **** 1234',
                isSelected: selectedPayment == PaymentMethod.existingCard,
                onTap: () => _selectPayment(PaymentMethod.existingCard),
              ),
              12.verticalSpace,
              PaymentOption(
                icon: AppAssets.ASSETS_ICONS_PAYMENT_CARD_SVG.svg,
                title: 'Pay with New Card',
                isSelected: selectedPayment == PaymentMethod.newCard,
                onTap: () => _selectPayment(PaymentMethod.newCard),
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
