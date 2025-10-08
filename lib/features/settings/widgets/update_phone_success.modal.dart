import 'package:resq360/__lib.dart';

class UpdatePhoneSuccessModal extends StatelessWidget {
  const UpdatePhoneSuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 240.h, bottom: 240.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppAssets.ASSETS_IMAGES_PASSWORD_RESET_SUCCESS_PNG.imageAsset(),
              4.verticalSpace,
              UrbText(
                'SMS Number Updated Successfully',
                size: 20,
                height: 32.5,
                weight: FontWeight.w700,
                color: appColors.black,
                textAlign: TextAlign.center,
              ),
              4.verticalSpace,
              GenText(
                'You will now receive job notification on this number',
                height: 24.5,
                color: appColors.textColor.shade300,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              30.verticalSpace,
              WideButton(
                heigth: 45,
                label: 'Done',
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
