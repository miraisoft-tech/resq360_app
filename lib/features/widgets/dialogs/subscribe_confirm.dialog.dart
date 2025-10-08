import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/static_colors.dart';
import 'package:resq360/features/widgets/dialogs/payment_fiished.modal.dart';

class SubscribeConfirmDialog extends StatefulWidget {
  const SubscribeConfirmDialog({required this.amount, super.key});

  final String amount;

  @override
  State<SubscribeConfirmDialog> createState() => _SubscribeConfirmDialogState();
}

class _SubscribeConfirmDialogState extends State<SubscribeConfirmDialog> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 210.h, bottom: 200.h),
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
                  Row(
                    children: [
                      AppAssets.ASSETS_ICONS_PAYMENT_EXISTING_CARD_SVG.svg,
                      10.horizontalSpace,
                      GenText(
                        'Confirm Subscription',
                        weight: FontWeight.w500,
                        color: appColors.black,
                      ),
                    ],
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
              GenText(
                'Subscribe to receive sms notifications.',
                size: 12,
                weight: FontWeight.w400,
                color: appColors.black,
              ),

              14.verticalSpace,
              Container(
                width: double.infinity,
                padding: pad(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenText(
                      'Subscription Fee',
                      weight: FontWeight.w500,
                      color: appColors.black,
                    ),
                    10.verticalSpace,
                    GenText(
                      widget.amount,
                      weight: FontWeight.w500,
                      color: appColors.black,
                    ),
                  ],
                ),
              ),
              20.verticalSpace,
              Container(
                width: double.infinity,
                padding: pad(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GenText(
                          'Wallet Balance',
                          weight: FontWeight.w500,
                          color: appColors.black,
                        ),
                        50.horizontalSpace,
                        GenText(
                          '₦70,000',
                          weight: FontWeight.w500,
                          color: appColors.black,
                        ),
                      ],
                    ),
                    10.verticalSpace,
                    Row(
                      children: [
                        GenText(
                          'Subscription Fee: ',
                          weight: FontWeight.w500,
                          color: appColors.neutral.shade500,
                        ),
                        30.horizontalSpace,
                        GenText(
                          '₦12,000',
                          weight: FontWeight.w500,
                          color: appColors.neutral.shade500,
                        ),
                      ],
                    ),
                    10.verticalSpace,
                    Row(
                      children: [
                        GenText(
                          'Remaining Balance:',
                          weight: FontWeight.w500,
                          color: appColors.neutral.shade500,
                        ),
                        20.horizontalSpace,
                        GenText(
                          '₦58,000',
                          weight: FontWeight.w500,
                          color: appColors.neutral.shade500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              40.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Cancel',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'Subscribe',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        Navigator.of(context).pop();

                        await GeneralDialogs.showCustomDialog(
                          context,
                          body: PaymentFinished(
                            onTap: () async {
                              // Navigator.pop(context);
                              // Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
