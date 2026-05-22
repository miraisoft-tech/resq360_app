import 'package:resq360/__lib.dart';

class ServiceRequestNotification extends StatefulWidget {
  const ServiceRequestNotification({
    this.message = 'You have a new service request',
    this.onContactCustomer,
    super.key,
  });

  final String message;
  final Future<void> Function()? onContactCustomer;

  @override
  State<ServiceRequestNotification> createState() =>
      _ServiceRequestNotificationState();
}

class _ServiceRequestNotificationState
    extends State<ServiceRequestNotification> {
  bool _isContacting = false;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 320.h, bottom: 280.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 40),
          padding: pad(horizontal: 16, vertical: 12),
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
                  icon: Icon(Icons.close, color: appColors.textColor.shade400),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: pad(vertical: 2, horizontal: 2),
                    decoration: BoxDecoration(color: appColors.primary.shade50),
                    child: AppAssets.ASSETS_ICONS_NOTIFICATION_BELL_SVG
                        .svgColor(color: appColors.primary.shade500),
                  ),
                  10.horizontalSpace,
                  UrbText(
                    'Service Request',
                    size: 16,
                    height: 16.5,
                    weight: FontWeight.w600,
                    color: appColors.black,
                  ),
                ],
              ),
              10.verticalSpace,
              GenText(
                widget.message,
                color: appColors.neutral.shade500,
                size: 12,
                height: 16.5,
                weight: FontWeight.w500,
                textAlign: TextAlign.center,
              ),
              if (widget.onContactCustomer != null) ...[
                18.verticalSpace,
                WideButton(
                  label: 'Contact customer',
                  loading: _isContacting,
                  onPressed: _isContacting ? null : _contactCustomer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _contactCustomer() async {
    final onContactCustomer = widget.onContactCustomer;
    if (onContactCustomer == null) return;

    setState(() {
      _isContacting = true;
    });

    await onContactCustomer();

    if (!mounted) return;

    setState(() {
      _isContacting = false;
    });
  }
}
