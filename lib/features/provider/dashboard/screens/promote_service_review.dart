import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/static_colors.dart';
import 'package:resq360/features/widgets/dialogs/payment_fiished.modal.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';

class PromoteServiceReviewScreen extends StatefulWidget {
  const PromoteServiceReviewScreen({super.key});

  @override
  State<PromoteServiceReviewScreen> createState() =>
      _PromoteServiceReviewScreenState();
}

class _PromoteServiceReviewScreenState
    extends State<PromoteServiceReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => pop(context),
          icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
        ),
        centerTitle: true,
        title: UrbText(
          'Promote Your Page',
          size: 22,
          height: 32.5,
          weight: FontWeight.w700,
          color: appColors.textColor.shade800,
        ),
        actions: const [SizedBox(width: 40)],
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 16, vertical: 10),
          child: Col(
            children: [
              GenText(
                'Review Your Promotion',
                size: 16,
                height: 24.5,
                weight: FontWeight.w700,
                color: appColors.textColor.shade800,
              ),
              20.verticalSpace,
              Container(
                padding: pad(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: appColors.whiteColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: appColors.textColor.shade100,
                  ),
                ),
                child: Col(
                  children: [
                    GenText(
                      'Get 20% off every towing service today.',
                      height: 24.5,
                      weight: FontWeight.w400,
                      color: appColors.textColor.shade400,
                    ),
                    12.verticalSpace,
                    Row(
                      children: [
                        GenText(
                          'Discount:',
                          height: 24.5,
                          weight: FontWeight.w400,
                          color: appColors.textColor.shade400,
                        ),
                        const Spacer(),
                        GenText(
                          '-30% off',
                          height: 24.5,
                          weight: FontWeight.w500,
                          color: appColors.black,
                        ),
                      ],
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        GenText(
                          'Duration:',
                          height: 24.5,
                          weight: FontWeight.w400,
                          color: appColors.textColor.shade400,
                        ),
                        const Spacer(),
                        GenText(
                          '24 hours',
                          height: 24.5,
                          weight: FontWeight.w500,
                          color: appColors.black,
                        ),
                      ],
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        GenText(
                          'Promotion Fee:',
                          height: 24.5,
                          weight: FontWeight.w400,
                          color: appColors.textColor.shade400,
                        ),
                        const Spacer(),
                        GenText(
                          '₦12,000',
                          height: 24.5,
                          weight: FontWeight.w500,
                          color: appColors.black,
                        ),
                      ],
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        GenText(
                          'Total:',
                          height: 24.5,
                          weight: FontWeight.w400,
                          color: appColors.textColor.shade400,
                        ),
                        const Spacer(),
                        GenText(
                          '₦12,000',
                          height: 24.5,
                          weight: FontWeight.w500,
                          color: appColors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
                      label: 'Pay Now',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        await GeneralDialogs.showCustomDialog(
                          context,
                          body: PaymentOptionDialog(
                            onPaymentSelected: (
                              PaymentMethod paymentMethod,
                            ) async {
                              await GeneralDialogs.showCustomDialog(
                                context,
                                body: const FinishPaymentDialog(
                                  amount: '₦15,000',
                                ),
                              );
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

class FinishPaymentDialog extends StatefulWidget {
  const FinishPaymentDialog({required this.amount, super.key});

  final String amount;

  @override
  State<FinishPaymentDialog> createState() => _FinishPaymentDialogState();
}

class _FinishPaymentDialogState extends State<FinishPaymentDialog> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 220.h, bottom: 200.h),
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
                        'Complete Payment',
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
                      'Promotion Fee',
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
                          'Promotion Fee:',
                          weight: FontWeight.w500,
                          color: appColors.neutral.shade500,
                        ),
                        50.horizontalSpace,
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
                      label: 'Pay ${widget.amount}',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await GeneralDialogs.showCustomDialog(
                          context,
                          body: PaymentFinished(
                            onTap: () async {
                              if (context.mounted) await pop(context);
                              if (context.mounted) await pop(context);
                              if (context.mounted) await pop(context);
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
