import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';

class FundWalletCompleted extends StatelessWidget {
  const FundWalletCompleted({required this.amount, super.key});
  final num? amount;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final finalAmount = (amount?.toDouble() ?? 0) / 100;

    return Padding(
      padding: EdgeInsets.only(top: 250.h, bottom: 220.h),
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
              AppAssets.ASSETS_IMAGES_CONFETTI_PNG.imageAsset(),
              20.verticalSpace,
              UrbText(
                'Funds Added Successfully',
                size: 22,
                height: 32.5,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
              4.verticalSpace,
              UrbText(
                'You have successfully added ₦${AppTextUtil.formatAmount(finalAmount.toString())} to your wallet.',
                height: 24.5,
                color: appColors.textColor.shade300,
                textAlign: TextAlign.center,
              ),
              30.verticalSpace,
              WideButton(
                heigth: 40,
                label: 'Continue',
                backgroundColor: appColors.primary.shade500,
                textColor: appColors.whiteColor,
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
