import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/widgets/update_phone.modal.dart';
import 'package:resq360/features/widgets/custom_switch.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';
import 'package:resq360/features/widgets/dialogs/subscribe_confirm.dialog.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  ValueNotifier<bool> inAppNotification = ValueNotifier(true);
  ValueNotifier<bool> emailNotification = ValueNotifier(true);
  ValueNotifier<bool> smsNotification = ValueNotifier(true);
  ValueNotifier<bool> renewSMSNotification = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: UrbText(
          'Notification',
          size: 22,
          weight: FontWeight.w700,
          color: appColors.black,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        foregroundColor: appColors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 20, vertical: 16),
          child: ListView(
            children: [
              _CardTile(
                header: 'In-App',
                title: 'In-App Notification',
                subtitle:
                    'In-app notification are mandatory for important updates.',
                isEnabled: inAppNotification.value,
                onChanged: ({required value}) {
                  setState(() {
                    inAppNotification.value = value;
                  });
                },
              ),
              20.verticalSpace,
              _CardTile(
                header: 'Email',
                title: 'Email Notification',
                subtitle:
                    'Email notification are mandatory for important updates.',
                isEnabled: emailNotification.value,
                onChanged: ({required value}) {
                  setState(() {
                    inAppNotification.value = value;
                  });
                },
              ),
              20.verticalSpace,
              _CardTile(
                header: 'SMS',
                title: 'SMS Notification',
                subtitle:
                    'Subscription is required to boost your chances of getting quick access to job offers by 85%.',
                isEnabled: smsNotification.value,
                onChanged: ({required value}) {
                  setState(() {
                    smsNotification.value = value;
                  });
                },
              ),
              Col(
                children: [
                  _CardTile(
                    header: '',
                    title: 'Auto-renew Subscription',
                    subtitle:
                        'Enable automatic renewal to avoid missing job offers.',
                    isEnabled: renewSMSNotification.value,
                    onChanged: ({required value}) async {
                      setState(() {
                        renewSMSNotification.value = value;
                      });

                      await GeneralDialogs.showCustomDialog(
                        context,
                        body: PaymentOptionDialog(
                          onPaymentSelected: (method) async {
                            await GeneralDialogs.showCustomDialog(
                              context,
                              body: const SubscribeConfirmDialog(
                                amount: '₦15,0000',
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  20.verticalSpace,
                  GestureDetector(
                    onTap: () async {
                      await GeneralDialogs.showCustomDialog(
                        context,
                        body: const UpdatePhoneModal(),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: pad(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: appColors.textColor.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GenText(
                            'Phone Number',
                            color: appColors.black,
                            weight: FontWeight.w500,
                          ),
                          5.verticalSpace,
                          GenText(
                            '08145660699',
                            size: 12,
                            color: appColors.textColor.shade500,
                            weight: FontWeight.w400,
                          ),
                          GenText(
                            'Update Number',
                            size: 12,
                            color: appColors.primary.shade500,
                            weight: FontWeight.w400,
                          ),
                        ],
                      ),
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

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.header,
    required this.title,
    required this.subtitle,
    this.isEnabled = true,
    this.onChanged,
    super.key,
  });
  final String header;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final void Function({required bool value})? onChanged;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Col(
      children: [
        UrbText(
          header,
          color: appColors.black,
          weight: FontWeight.w700,
          size: 16,
        ),
        16.verticalSpace,
        Container(
          width: double.infinity,
          padding: pad(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: appColors.textColor.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GenText(
                    title,
                    color: appColors.black,
                    weight: FontWeight.w500,
                  ),
                  const Spacer(),
                  CustomSwitchWidget(
                    value: isEnabled,
                    onChanged: onChanged,
                    activeThumbColor: appColors.primary.shade500,
                    disabledThumbColor: appColors.textColor.shade100,
                    tapColor: appColors.whiteColor,
                  ),
                ],
              ),
              5.verticalSpace,
              SizedBox(
                width: 200.w,
                child: GenText(
                  subtitle,
                  size: 12,
                  color: appColors.textColor.shade500,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
