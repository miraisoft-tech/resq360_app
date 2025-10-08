import 'package:resq360/__lib.dart';

class PaymentFinished extends StatelessWidget {
  const PaymentFinished({required this.onTap, super.key});

  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 250.h, bottom: 250.h),
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
                'Payment Confirmed',
                size: 22,
                height: 32.5,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
              4.verticalSpace,
              UrbText(
                'Promotion starts in 2 hours',
                height: 24.5,
                color: appColors.textColor.shade300,
                textAlign: TextAlign.center,
              ),
              30.verticalSpace,
              WideButton(
                label: 'Back Home',
                backgroundColor: appColors.primary.shade500,
                textColor: appColors.whiteColor,
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
