import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/screens/confirm_email_screen.dart';
import 'package:resq360/features/customer/authentication/screens/reset_password_screen.dart';
import 'package:resq360/features/widgets/inputs/pin_field.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    required this.email,
    super.key,
  });

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final TextEditingController _otpController1;
  late final CountdownTimerController controller;

  int endTime =
      DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    controller = CountdownTimerController(endTime: endTime, onEnd: () {});
    _otpController1 = TextEditingController();
  }

  @override
  void dispose() {
    _otpController1.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> onResend() async {
    context.read<CustomerAuthBloc>().add(
      CustomerForgotPassword(
        email: widget.email.trim(),
      ),
    );
  }

  Future<void> onVerify() async {
    if (_otpController1.text.length < 6) {
      await showErrorSnackbar(context, 'OTP field must be 6 digits');
      return;
    }

    context.read<CustomerAuthBloc>().add(
      CustomerVerifyForgotPasswordOtp(token: _otpController1.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
      listener: (context, state) async {
        if (!mounted) return;
        if (state is! CustomerAuthLoading) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
        if (state is CustomerAuthLoading) {
          await showLoadingDialog(context);
          return;
        }

        if (state is CustomerAuthFailure) {
          await pop(context);
          Future.delayed(const Duration(seconds: 2), () async{
             await showSnackBar(context, 'Error', state.error);
          });
        }

        if (state is CustomerForgotPasswordOtpSent) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          await showSuccessSnackbar(context, 'Otp resent ');
          controller
            ..endTime =
                DateTime.now()
                    .add(const Duration(seconds: 5 * 60))
                    .millisecondsSinceEpoch
            ..start();

          setState(() {});
        }

        if (state is CustomerForgotPasswordOtpSent && context.mounted) {
          await replaceScreen(context, const ResetPasswordScreen());
        }
      },
      listenWhen: (previous, current) => current is! CustomerAuthInitial,
      buildWhen: (previous, current) => false,
      builder: (context, state) {
        return AppScaffold(
          title: 'Enter Code',
          subTitle: 'Please enter the reset code sent to your email',
          body: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NormalPinCodeField(
                      controller: _otpController1,
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
                onPressed: _otpController1.text.length < 6 ? null : onVerify,
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
