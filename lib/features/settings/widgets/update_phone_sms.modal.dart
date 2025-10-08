import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/screens/provider_verify_email_screen.dart';
import 'package:resq360/features/settings/widgets/update_phone_success.modal.dart';
import 'package:resq360/features/widgets/inputs/pin_field.dart';

class UpdateSMSModal extends StatefulWidget {
  const UpdateSMSModal({super.key});

  @override
  State<UpdateSMSModal> createState() => _UpdateSMSModalState();
}

class _UpdateSMSModalState extends State<UpdateSMSModal> {
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
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(
        top: 240.h,
        bottom: 235.h,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Col(
            children: [
              Row(
                children: [
                  UrbText(
                    'Verify Your Number',
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
              20.verticalSpace,
              GenText(
                'Enter the 6-digit code sent to 08056749303',
                size: 12,
                height: 12.5,
                weight: FontWeight.w500,
                color: appColors.black,
                textAlign: TextAlign.center,
              ),
              20.verticalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NormalPinCodeField(
                      height: 40,
                      width: 40,
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
                                  color: appColors.neutral.shade500,
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

              30.verticalSpace,
              WideButton(
                heigth: 45,
                label: 'Verify',
                backgroundColor: appColors.primary.shade500,
                textColor: appColors.whiteColor,
                onPressed: () async {
                  Navigator.pop(context);
                  await GeneralDialogs.showCustomDialog(
                    context,
                    body: const UpdatePhoneSuccessModal(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
