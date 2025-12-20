import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/screens/provider_verification_steps_screen.dart';
import 'package:resq360/features/widgets/inputs/pin_field.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class ProviderConfirmEmailScreen extends StatefulWidget {
  const ProviderConfirmEmailScreen({
    required this.email,
    super.key,
  });

  final String email;

  @override
  State<ProviderConfirmEmailScreen> createState() =>
      _ProviderConfirmEmailScreenState();
}

class _ProviderConfirmEmailScreenState
    extends State<ProviderConfirmEmailScreen> {
  int endTime =
      DateTime.now()
          .add(const Duration(seconds: 5 * 60))
          .millisecondsSinceEpoch;

  late TextEditingController _otpController1;
  late CountdownTimerController controller;
  @override
  void initState() {
    super.initState();
    controller = CountdownTimerController(endTime: endTime, onEnd: () {});

    _otpController1 = TextEditingController();
  }

  @override
  void dispose() {
    _otpController1 = TextEditingController();

    super.dispose();
  }

  Future<void> onResend() async {
    if (controller.isRunning) {
      return;
    }

    context.read<ProviderAuthBloc>().add(
      ProviderResendVerificationOtp(email: widget.email),
    );

    controller
      ..endTime =
          DateTime.now()
              .add(const Duration(seconds: 5 * 60))
              .millisecondsSinceEpoch
      ..start();
  }

  Future<void> onVerify() async {
    if (_otpController1.text.length < 6) {
      await showErrorSnackbar(context, 'otp field must be 6 digits');
      return;
    }
    context.read<ProviderAuthBloc>().add(
      ProviderverifyEmail(
        emailVerificationToken: _otpController1.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<ProviderAuthBloc, ProviderAuthState>(
      listener: (context, state) async {
        if (!context.mounted) return;
        if (state is ProviderAuthLoadingState) {
          await showLoadingDialog(context);
        }

        if (state is ProviderAuthFailureState) {
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          await showSnackBar(context, 'Error', state.error);
        }
        if (state is ProviderVerificationResent) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          await showSuccessSnackbar(context, state.message);

          controller
            ..endTime =
                DateTime.now()
                    .add(const Duration(seconds: 5 * 60))
                    .millisecondsSinceEpoch
            ..start();

          setState(() {});
        }

        if (state is ProviderEmailVerifiedState) {
          if (!context.mounted) return;
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          log('Email verified, navigating to main layout');
          await replaceScreen(context, const ProviderVerificationStepsScreen());
        }
      },
      child: AppScaffold(
        title: 'Verify Email',
        subTitle: 'Please enter the 6-digit code sent to your email',
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  NormalPinCodeField(
                    controller: _otpController1,
                    onDone: (code) {},
                    onChange: (dynamic value) {
                      log(value);
                      setState(() {});
                    },
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
                            GoToWidget(
                              ligthText: 'Resend code in ',
                              onTap: onResend,
                              coloredText:
                                  '0${time?.min ?? 0}:${(time?.sec ?? 0) < 10 ? '0${time?.sec ?? 0}' : time?.sec ?? 0}',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  50.verticalSpace,
                ],
              ),
            ),

            WideButton(
              label: 'Verify & Continue',
              onPressed: (_otpController1.text.length < 6 ? null : onVerify),
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class GoToWidget extends StatelessWidget {
  const GoToWidget({
    required this.ligthText,
    required this.coloredText,
    this.onTap,
    this.size = 14,
    this.height = 17.71,
    super.key,
  });

  final String ligthText;
  final String coloredText;
  final void Function()? onTap;
  final double size;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: size.sp,
          height: height.toFigmaHeight(size.sp),
          decorationColor: colors.primary.shade500,
        ),

        children: [
          circularSTDTextSpan(
            ligthText,
            color: colors.primary.shade500,
            decoration: TextDecoration.underline,
          ),
          circularSTDTextSpan(
            coloredText,
            color: colors.primary.shade500,
            weight: FontWeight.w700,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
