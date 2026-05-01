import 'package:resq360/__lib.dart';

class PaymentAppealDialog extends StatelessWidget {
  const PaymentAppealDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return AlertDialog(
      backgroundColor: appColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      contentPadding: pad(horizontal: 25, vertical: 25),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UrbText(
            'Open an Appeal',
            size: 22,
            height: 32.5,
            weight: FontWeight.w700,
            color: appColors.black,
          ),
          4.verticalSpace,
          UrbText(
            'You are about to open an appeal. This will start a chat between you, the service provider and the admin.',
            height: 24.5,
            color: appColors.textColor.shade300,
            textAlign: TextAlign.center,
          ),
          30.verticalSpace,
          Row(
            children: [
              Expanded(
                child: WideButton(
                  label: 'Cancel',
                  backgroundColor: appColors.primary.shade50,
                  textColor: appColors.primary.shade500,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: WideButton(
                  label: 'Proceed',
                  backgroundColor: appColors.primary.shade500,
                  textColor: appColors.whiteColor,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
