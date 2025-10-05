import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/screens/verification_steps_screen.dart';
import 'package:resq360/features/widgets/inputs/pin_field.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class ConfirmEmailScreen extends StatefulWidget {
  const ConfirmEmailScreen({required this.email, super.key});

  final String email;

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen> {
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
    // showLoadingDialog();

    // final result = await AuthRemoteRepo.instance.resendVerifyEmail(
    //   email: widget.email,
    // );

    // if (result is ErrorResponse && mounted) {
    //   await pop(context);
    //   await showErrorSnackbar(result.errorMessage);
    // } else if (result is AuthResponse && mounted) {
    //   await pop(context);

    //   await showSuccessSnackbar('Verification mail resent successfully!');
    //   controller.endTime =
    //       DateTime.now()
    //           .add(const Duration(seconds: 5 * 60))
    //           .millisecondsSinceEpoch;
    //   controller.start();
    //   setState(() {});
    // }
  }

  Future<void> onVerify() async {
    if (_otpController1.text.length < 6) {
      await showErrorSnackbar(context, 'otp field must be 6 digits');
      return;
    }

    await pushScreen(context, const VerificationStepsScreen());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppScaffold(
      title: 'Verify Email',
      subTitle: 'Please enter the 6-digit code sent to your email',
      body: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          InkWell(
                            onTap: onResend,
                            child: GenText(
                              'Didn’t receive code?',
                              size: 12,
                              height: 20.5,
                              color: colors.neutral.shade500,
                              weight: FontWeight.w400,
                            ),
                          ),
                          5.verticalSpace,
                          GoToWidget(
                            ligthText: 'Resend code in ',
                            coloredText:
                                '0${time?.min ?? 0}:${(time?.sec ?? 0) < 10 ? '0${time?.sec ?? 0}' : time?.sec ?? 0}',
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
            onPressed: (_otpController1.text.length < 6 ? null : onVerify),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class GoToWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
