import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/static_colors.dart';

class AccountStatusDialog extends StatelessWidget {
  const AccountStatusDialog({required this.onTap, super.key});

  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 165.h, bottom: 165.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Col(
            children: [
              Row(
                children: [
                  UrbText(
                    'Account Status',
                    size: 20,
                    height: 32.5,
                    weight: FontWeight.w700,
                    color: appColors.black,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: appColors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              25.verticalSpace,
              StatusItemWidget(
                title: 'ACTIVE',
                subTitle: 'Your account is active. Clients can reach you.',
                color: appColors.success.shade700,
              ),
              20.verticalSpace,
              StatusItemWidget(
                title: 'ON-HOLD',
                subTitle:
                    'Your account is currently on hold, clients can not engage you now. Kindly check your wallet and make payment to clear outstanding charges from cancellation.',
                color: appColors.error.shade200,
              ),
              20.verticalSpace,
              const StatusItemWidget(
                title: 'OFF-HOUR',
                subTitle:
                    'Your business is currently off hour, clients can not reach you at the moment. You can update business hours to stay active. Go to update service and update business hour.',
                color: AppColors.blue,
              ),
              20.verticalSpace,
              StatusItemWidget(
                title: 'DISABLED',
                subTitle:
                    'Your account is disabled, clients can not reach you.',
                color: appColors.neutral.shade400,
              ),
              30.verticalSpace,
              WideButton(
                heigth: 40,
                label: 'Contact Admin',
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

class StatusItemWidget extends StatelessWidget {
  const StatusItemWidget({
    required this.title,
    required this.subTitle,
    required this.color,
    super.key,
  });
  final String title;
  final String subTitle;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Col(
      children: [
        UrbText(
          title,
          height: 24.5,
          weight: FontWeight.w500,
          color: color,
          textAlign: TextAlign.start,
        ),
        UrbText(
          subTitle,
          size: 12,
          height: 14.5,
          weight: FontWeight.w400,
          color: appColors.textColor.shade300,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
