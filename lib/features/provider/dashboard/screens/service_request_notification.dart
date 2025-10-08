import 'package:resq360/__lib.dart';

class ServiceRequestNotification extends StatefulWidget {
  const ServiceRequestNotification({super.key});

  @override
  State<ServiceRequestNotification> createState() =>
      _ServiceRequestNotificationState();
}

class _ServiceRequestNotificationState
    extends State<ServiceRequestNotification> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 365.h, bottom: 320.h),

      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 80),
          padding: pad(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: appColors.textColor.shade400,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: pad(vertical: 2, horizontal: 2),
                    decoration: BoxDecoration(color: appColors.primary.shade50),
                    child: AppAssets.ASSETS_ICONS_NOTIFICATION_BELL_SVG
                        .svgColor(
                          color: appColors.primary.shade500,
                        ),
                  ),
                  10.horizontalSpace,
                  UrbText(
                    'Service Request',
                    height: 16.5,
                    weight: FontWeight.w500,
                    color: appColors.black,
                  ),
                ],
              ),
              10.verticalSpace,
              GenText(
                'You have a new service request from Jane Doe',
                color: appColors.neutral.shade500,
                size: 12,
                height: 16.5,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
