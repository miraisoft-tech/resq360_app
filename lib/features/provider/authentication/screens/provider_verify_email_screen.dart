
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/screens/provider_reset_password_screen.dart';
import 'package:resq360/features/widgets/inputs/pin_field.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class ProviderVerifyEmailScreen extends StatefulWidget {
  const ProviderVerifyEmailScreen({
    required this.email,
    super.key,
  });

  final String email;

  @override
  State<ProviderVerifyEmailScreen> createState() =>
      _ProviderVerifyEmailScreenState();
}

class _ProviderVerifyEmailScreenState extends State<ProviderVerifyEmailScreen> {
  int endTime =
      DateTime.now()
          .add(const Duration(seconds: 5 * 60))
          .millisecondsSinceEpoch;

  late TextEditingController _tokenController;
  late CountdownTimerController controller;
  @override
  void initState() {
    super.initState();
    controller = CountdownTimerController(endTime: endTime, onEnd: () {});

    _tokenController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController = TextEditingController();

    super.dispose();
  }

  Future<void> onResend() async {
    if (_tokenController.text.isNotEmpty) {
      _tokenController.clear();
    }
    context.read<ProviderAuthBloc>().add(
      ProviderRequestPasswordResetEvent(email: widget.email),
    );
  }

  Future<void> onVerify() async {
    if (_tokenController.text.length < 6) {
      await showErrorSnackbar(context, 'otp field must be 6 digits');
      return;
    }

    context.read<ProviderAuthBloc>().add(
      ProviderValidateResetTokenEvent(token: _tokenController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<ProviderAuthBloc, ProviderAuthState>(
      listener: (context, state) async {
        if (!mounted) return;
        if (state is! ProviderAuthLoadingState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
        if (state is ProviderAuthLoadingState) {
          await showLoadingDialog(context);
        }

        if (state is ProviderAuthFailureState) {
          await pop(context);
          Future.delayed(const Duration(seconds: 2), () async {
            await showSnackBar(context, 'Error', state.error);
          });
          log(state.error);
        }

        if (state is ProviderVerificationEmailResentState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          await showSuccessSnackbar(context, state.message);

          setState(() {
            controller
              ..endTime =
                  DateTime.now()
                      .add(const Duration(seconds: 5 * 60))
                      .millisecondsSinceEpoch
              ..start();
          });
        }
        if (state is ProviderResetTokenValidatedState) {
          await replaceScreen(context, const ProviderResetPasswordScreen());
        }
      },
      builder: (BuildContext context, ProviderAuthState state) {
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
                      controller: _tokenController,
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
                                onTap: onResend,
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
                onPressed: (_tokenController.text.length < 6 ? null : onVerify),
              ),
              const Spacer(),
            ],
          ),
        );
      },
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
            onTap: onTap,
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
