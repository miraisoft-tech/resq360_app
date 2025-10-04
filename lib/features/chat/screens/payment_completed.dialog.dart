import 'package:resq360/__lib.dart';

class PaymentCompleted extends StatelessWidget {
  const PaymentCompleted({super.key});

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
                'Payment Confirmed',
                size: 22,
                height: 32.5,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
              4.verticalSpace,
              UrbText(
                'QuickTow has been notified and your driver is being assigned.',
                height: 24.5,
                color: appColors.textColor.shade300,
                textAlign: TextAlign.center,
              ),
              30.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Close',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'View details',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await GeneralDialogs.showCustomDialog(
                          context,
                          body: const PaymentCompleted(),
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
