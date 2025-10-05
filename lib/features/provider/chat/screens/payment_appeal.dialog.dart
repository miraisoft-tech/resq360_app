import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/chat/screens/support_chat_screen.dart';

class PaymentAppealDialog extends StatelessWidget {
  const PaymentAppealDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 250.h, bottom: 320.h),
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'Proceed',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        Navigator.pop(context);

                        await pushScreen(context, const SupportChatScreen());
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
