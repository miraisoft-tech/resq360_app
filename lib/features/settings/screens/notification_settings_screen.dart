import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/settings/data/bloc/notification_settings_bloc/notification_settings_bloc.dart';

import 'package:resq360/features/settings/data/models/notification_settings.model.dart';
import 'package:resq360/features/settings/widgets/update_phone.modal.dart';
import 'package:resq360/features/widgets/custom_switch.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';
import 'package:resq360/features/widgets/dialogs/subscribe_confirm.dialog.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({required this.isProvider, super.key});

  final bool isProvider;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late Future<String?> phoneNumberFuture;
  NotificationSettingsModel? currentSettings;

  @override
  void initState() {
    super.initState();
    phoneNumberFuture = AuthLocalRepo.instance.getUserPhoneNumber(
      isProvider: widget.isProvider,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationSettingsBloc>().add(FetchNotificationSettings());
    });
  }

  final Map<String, bool> _updating = {};

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
      body: BlocConsumer<NotificationSettingsBloc, NotificationSettingsState>(
        listener: (context, state) async {
          if (state is FetchingNotificationSettingsError) {
            await showErrorSnackbar(context, state.error);
          }

          if (state is UpdatingNotificationSettingsError) {
            context.read<NotificationSettingsBloc>().add(
              FetchNotificationSettings(),
            );
            _updating.clear();
            await showErrorSnackbar(context, state.error);
          }

          if (state is UpdatedNotificationSettings) {
            setState(() {
              currentSettings = state.settings;
              _updating.clear();
            });
          }

          if (state is FetchedNotificationSettings) {
            setState(() {
              currentSettings = state.settings;
              _updating.clear();
            });
          }
        },
        builder: (context, state) {
          if (state is FetchNotificationSettingsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: appColors.primary,
              ),
            );
          }

          if (currentSettings == null) {
            return Center(
              child: CircularProgressIndicator(
                color: appColors.primary,
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: pad(horizontal: 20, vertical: 16),
              child: ListView(
                children: [
                  _CardTile(
                    header: 'In-App',
                    title: 'In-App Notification',
                    subtitle:
                        'In-app notification are mandatory for important updates.',
                    isEnabled: currentSettings!.pushNotifications,
                    onChanged: ({required value}) {
                      setState(() {
                        _updating['push'] = true;
                        currentSettings = currentSettings!.copyWith(
                          pushNotifications: value,
                        );
                      });
                      context.read<NotificationSettingsBloc>().add(
                        UpdatePushNotification(value: value),
                      );
                    },
                    isLoading: _updating['push'] ?? false,
                    enabled: true,
                  ),
                  20.verticalSpace,
                  _CardTile(
                    header: 'Email',
                    title: 'Email Notification',
                    subtitle:
                        'Email notification are mandatory for important updates.',
                    isEnabled: currentSettings!.emailNotifications,
                    onChanged: ({required value}) {
                      setState(() {
                        _updating['email'] = true;
                        currentSettings = currentSettings!.copyWith(
                          emailNotifications: value,
                        );
                      });
                      context.read<NotificationSettingsBloc>().add(
                        UpdateEmailNotification(value: value),
                      );
                    },
                    isLoading: _updating['email'] ?? false,
                    enabled: true,
                  ),
                  20.verticalSpace,
                  _CardTile(
                    header: 'SMS',
                    title: 'SMS Notification',
                    subtitle:
                        'Subscription is required to boost your chances of getting quick access to job offers by 85%.',
                    isEnabled: currentSettings!.smsNotifications,
                    onChanged: ({required value}) {
                      setState(() {
                        _updating['sms'] = true;
                        currentSettings = currentSettings!.copyWith(
                          smsNotifications: value,
                        );
                      });
                      context.read<NotificationSettingsBloc>().add(
                        UpdateSmsNotification(value: value),
                      );
                    },
                    isLoading: _updating['sms'] ?? false,
                    enabled: true,
                  ),
                  Col(
                    children: [
                      _CardTile(
                        header: '',
                        title: 'Auto-renew Subscription',
                        subtitle:
                            'Enable automatic renewal to avoid missing job offers.',
                        isEnabled: currentSettings!.weeklyReports,
                        onChanged: ({required value}) async {
                          if (value) {
                            final result =
                                await GeneralDialogs.showCustomDialog<bool>(
                                  context,
                                  body: PaymentOptionDialog(
                                    onPaymentSelected: (method) async {
                                      await GeneralDialogs.showCustomDialog<
                                        void
                                      >(
                                        context,
                                        body: const SubscribeConfirmDialog(
                                          amount: '₦15,000',
                                        ),
                                      );
                                      Navigator.pop(
                                        context,
                                        true,
                                      );
                                    },
                                  ),
                                );

                            if (result ?? false) {
                              setState(() {
                                _updating['subscription'] = true;
                              });

                              context.read<NotificationSettingsBloc>().add(
                                const UpdateWeeklyReports(value: true),
                              );
                            }
                          } else {
                            setState(() {
                              _updating['subscription'] = true;
                            });

                            context.read<NotificationSettingsBloc>().add(
                              const UpdateWeeklyReports(value: false),
                            );
                          }
                        },
                        isLoading: _updating['Subscription'] ?? false,
                        enabled: false,
                      ),
                      20.verticalSpace,
                      FutureBuilder(
                        future: phoneNumberFuture,
                        builder: (context, asyncSnapshot) {
                          final phone = asyncSnapshot.data ?? 'No number';
                          return GestureDetector(
                            onTap: () async {
                              await GeneralDialogs.showCustomDialog<void>(
                                context,
                                body: UpdatePhoneModal(
                                  phoneNumber: phone,
                                  isProvider: widget.isProvider,
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: pad(vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: appColors.textColor.shade100,
                                ),
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
                                    phone,
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
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.header,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.enabled,
    this.isEnabled = true,
    this.onChanged,
  });

  final String header;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final bool isLoading;
  final bool enabled;
  final void Function({required bool value})? onChanged;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Col(
      children: [
        if (header.isNotEmpty) ...[
          UrbText(
            header,
            color: appColors.black,
            weight: FontWeight.w700,
            size: 16,
          ),
          16.verticalSpace,
        ],
        GestureDetector(
          onTap:
              enabled && !isLoading
                  ? () => onChanged?.call(value: !isEnabled)
                  : null,
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
                Row(
                  children: [
                    GenText(
                      title,
                      color: appColors.black,
                      weight: FontWeight.w500,
                    ),
                    // if (!enabled)
                    //   Container(
                    //     margin: const EdgeInsets.only(left: 8),
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 8,
                    //       vertical: 4,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: appColors.primary.shade50,
                    //       borderRadius: BorderRadius.circular(6),
                    //     ),
                    //     child: GenText(
                    //       'Required',
                    //       size: 10,
                    //       color: appColors.primary,
                    //       weight: FontWeight.w500,
                    //     ),
                    //   ),
                    const Spacer(),
                    if (isLoading)
                       SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: appColors.primary,),
                      )
                    else
                      CustomSwitchWidget(
                        value: isEnabled,
                        onChanged: enabled ? onChanged : null,
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
        ),
      ],
    );
  }
}
