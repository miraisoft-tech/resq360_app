import 'dart:async';

import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/screens/confirm_email_screen.dart';
import 'package:resq360/features/customer/authentication/screens/reset_password_screen.dart';
import 'package:resq360/features/widgets/inputs/pin_field.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class VerifyResetTokenScreen extends StatefulWidget {
  const VerifyResetTokenScreen({required this.email, super.key});

  final String email;

  @override
  State<VerifyResetTokenScreen> createState() => _VerifyResetTokenScreenState();
}

class _VerifyResetTokenScreenState extends State<VerifyResetTokenScreen> {
  late final TextEditingController _tokenController;
  late final CountdownTimerController controller;

  int endTime =
      DateTime.now().add(const Duration(minutes: 4)).millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    controller = CountdownTimerController(endTime: endTime, onEnd: () {});
    _tokenController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> onResend() async {
    if (_tokenController.text.isNotEmpty) {
      _tokenController.clear();
    }
    context.read<CustomerAuthBloc>().add(
      CustomerRequestPasswordResetEvent(email: widget.email.trim()),
    );
  }

  Future<void> onVerify() async {
    log('TOKEN: ${_tokenController.text}');
    if (_tokenController.text.length < 6) {
      await showErrorSnackbar(context, 'Reset code must be 6 digits');
      return;
    }

    context.read<CustomerAuthBloc>().add(
      CustomerValidateResetTokenEvent(token: _tokenController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
      listener: (context, state) async {
        if (!context.mounted) return;

        if (state is! CustomerAuthLoading) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }

        if (state is CustomerAuthLoading) {
          showLoadingDialog(context);
          return;
        }

        if (state is CustomerAuthFailure) {
          Future.delayed(const Duration(seconds: 2), () async {
            if (!context.mounted) return;
            await showSnackBar(context, 'Error', state.error);
          });
        }

        if (state is CustomerPasswordResetEmailSentState) {
          await showSuccessSnackbar(context, 'Reset code resent successfully');
          controller
            ..endTime =
                DateTime.now()
                    .add(const Duration(seconds: 60))
                    .millisecondsSinceEpoch
            ..start();
          setState(() {});
        }

        if (state is CustomerResetTokenValidatedState) {
          await replaceScreen(context, const ResetPasswordScreen());
        }
      },
      listenWhen: (previous, current) => current is! CustomerAuthInitial,
      buildWhen: (previous, current) => false,
      builder: (context, state) {
        return AppScaffold(
          title: 'Enter Reset Code',
          subTitle: 'Please enter the reset code sent to your email',
          body: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NormalPinCodeField(
                      controller: _tokenController,
                      onDone: (code) {},
                      onChange: (value) => setState(() {}),
                    ),
                    25.verticalSpace,
                    Center(
                      child: CountdownTimer(
                        endTime: endTime,
                        controller: controller,
                        widgetBuilder: (_, CurrentRemainingTime? time) {
                          return Column(
                            children: [
                              GenText(
                                'Didn’t receive code?',
                                size: 12,
                                height: 20.5,
                                color: colors.neutral.shade500,
                                weight: FontWeight.w400,
                              ),
                              5.verticalSpace,
                              InkWell(
                                onTap: controller.isRunning ? null : onResend,
                                child: GoToWidget(
                                  ligthText: 'Resend code in ',
                                  coloredText:
                                      '0${time?.min ?? 0}:${(time?.sec ?? 0) < 10 ? '0${time?.sec ?? 0}' : time?.sec ?? 0}',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              WideButton(
                label: 'Verify & Continue',
                onPressed: _tokenController.text.length < 6 ? null : onVerify,
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
