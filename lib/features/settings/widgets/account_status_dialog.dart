import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/static_colors.dart';

class AccountStatusDialog extends StatelessWidget {
  const AccountStatusDialog({
    required this.onTap,
    required this.currentStatus,
    super.key,
  });

  final void Function() onTap;
  final String currentStatus;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final normalizedStatus = currentStatus.toUpperCase();

    log(normalizedStatus);

    return Padding(
      padding: EdgeInsets.only(top: 125.h, bottom: 70.h),
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
                isActive:
                    normalizedStatus == 'ONLINE' ||
                    normalizedStatus == 'ACTIVE',
              ),
              20.verticalSpace,
              StatusItemWidget(
                title: 'OFFLINE',
                subTitle: 'Your account is offline. Clients cannot reach you.',
                color: appColors.error.shade700,
                isActive: normalizedStatus == 'OFFLINE',
              ),
              20.verticalSpace,
              StatusItemWidget(
                title: 'ON-HOLD',
                subTitle:
                    'Your account is currently on hold, clients can not engage you now. Kindly check your wallet and make payment to clear outstanding charges from cancellation.',
                color: appColors.error.shade200,
                isActive:
                    normalizedStatus == 'ON-HOLD' ||
                    normalizedStatus == 'ON_HOLD',
              ),
              20.verticalSpace,
              StatusItemWidget(
                title: 'OFF-HOUR',
                subTitle:
                    'Your business is currently off hour, clients can not reach you at the moment. You can update business hours to stay active. Go to update service and update business hour.',
                color: AppColors.blue,
                isActive:
                    normalizedStatus == 'OFF-HOUR' ||
                    normalizedStatus == 'OFF_HOUR',
              ),
              20.verticalSpace,
              StatusItemWidget(
                title: 'DISABLED',
                subTitle:
                    'Your account is disabled, clients can not reach you.',
                color: appColors.neutral.shade400,
                isActive: normalizedStatus == 'DISABLED',
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
    required this.isActive,
    super.key,
  });
  final String title;
  final String subTitle;
  final Color color;
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      padding: pad(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border:
            isActive
                ? Border.all(color: color, width: 2)
                : Border.all(color: Colors.transparent),
        color: isActive ? color.withValues(alpha: 0.05) : Colors.transparent,
      ),
      child: Col(
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
      ),
    );
  }
}
