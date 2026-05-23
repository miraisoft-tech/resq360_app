import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/screens/provider_verify_email_screen.dart';
import 'package:resq360/features/settings/data/bloc/phone_update_bloc/phone_update_bloc.dart';
import 'package:resq360/features/settings/widgets/update_phone_success.modal.dart';
import 'package:resq360/features/widgets/inputs/pin_field.dart';

class UpdateSMSModal extends StatefulWidget {
  const UpdateSMSModal({
    required this.number,
    super.key,
  });

  final String number;

  @override
  State<UpdateSMSModal> createState() => _UpdateSMSModalState();
}

class _UpdateSMSModalState extends State<UpdateSMSModal> {
  late int endTime;
  late TextEditingController _otpController;
  late CountdownTimerController controller;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _otpController = TextEditingController();
  }

  void _initializeTimer() {
    endTime = DateTime.now()
        .add(const Duration(seconds: 1 * 60))
        .millisecondsSinceEpoch;
    controller = CountdownTimerController(
      endTime: endTime,
      onEnd: () {
        setState(() {
          canResend = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _onResend() async {
    if (!canResend) return;

    setState(() {
      canResend = false;
    });

    context.read<PhoneUpdateBloc>().add(
      RequestPhoneOtpEvent(
        newPhoneNumber: widget.number,
      ),
    );

    _initializeTimer();
    setState(() {});
  }

  Future<void> _onVerify() async {
    if (_otpController.text.length != 6) {
      await showErrorSnackbar(context, 'Please enter 6-digit OTP');
      return;
    }

    context.read<PhoneUpdateBloc>().add(
      VerifyPhoneOtpEvent(
        newPhoneNumber: widget.number,
        otp: _otpController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return BlocConsumer<PhoneUpdateBloc, PhoneUpdateState>(
      listener: (context, state) async {
        if (state is PhoneUpdateError) {
          await showErrorSnackbar(context, state.error);
        }
    
        if (state is PhoneUpdateSuccess) {
          Navigator.pop(context);
          await GeneralDialogs.showCustomDialog<void>(
            context,
            body: UpdatePhoneSuccessModal(
              phoneNumber: state.phoneNumber,
            ),
          );
        }
    
        if (state is PhoneOtpSent) {
          await showSuccessSnackbar(context, 'OTP resent successfully');
        }
      },
      builder: (context, state) {
        final isLoading = state is PhoneUpdateLoading;
    
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
                        onPressed: isLoading 
                            ? null 
                            : () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  20.verticalSpace,
                  GenText(
                    'Enter the 6-digit code sent to ${widget.number}',
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
                          controller: _otpController,
                          // enabled: !isLoading,
                          onDone: (code) async {
                            if (code.length == 6 && !isLoading) {
                              await _onVerify();
                            }
                          },
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
                                    onTap: canResend && !isLoading 
                                        ? _onResend 
                                        : null,
                                    child: GenText(
                                      "Didn't receive code?",
                                      size: 12,
                                      height: 20.5,
                                      color: appColors.neutral.shade500,
                                      weight: FontWeight.w400,
                                    ),
                                  ),
                                  5.verticalSpace,
                                  if (!canResend)
                                    GoToWidget(
                                      ligthText: 'Resend code in ',
                                      coloredText:
                                          '0${time?.min ?? 0}:${(time?.sec ?? 0) < 10 ? '0${time?.sec ?? 0}' : time?.sec ?? 0}',
                                    )
                                  else
                                    InkWell(
                                      onTap: !isLoading ? _onResend : null,
                                      child: GenText(
                                        'Resend Code',
                                        size: 12,
                                        height: 20.5,
                                        color: appColors.primary.shade500,
                                        weight: FontWeight.w600,
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
                  30.verticalSpace,
                  WideButton(
                    heigth: 45,
                    label: isLoading ? 'Verifying...' : 'Verify',
                    backgroundColor: appColors.primary.shade500,
                    textColor: appColors.whiteColor,
                    onPressed: _otpController.text.length != 6 || isLoading
                        ? null
                        : _onVerify,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
