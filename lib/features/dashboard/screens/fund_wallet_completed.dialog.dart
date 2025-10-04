import 'package:resq360/__lib.dart';

class FundWalletCompleted extends StatelessWidget {
  const FundWalletCompleted({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
                'You have successfully added ₦20,000 to your wallet.',
                height: 24.5,
                color: appColors.textColor.shade300,
                textAlign: TextAlign.center,
              ),
              30.verticalSpace,
              WideButton(
                heigth: 40,
                label: 'Go to Wallet',
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
