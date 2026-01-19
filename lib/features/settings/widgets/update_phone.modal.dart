import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/bloc/phone_update_bloc/phone_update_bloc.dart';
import 'package:resq360/features/settings/widgets/update_phone_sms.modal.dart';

class UpdatePhoneModal extends StatefulWidget {
  const UpdatePhoneModal({
    required this.phoneNumber,
    required this.isProvider,
    super.key,
  });

  final String phoneNumber;
  final bool isProvider;

  @override
  State<UpdatePhoneModal> createState() => _UpdatePhoneModalState();
}

class _UpdatePhoneModalState extends State<UpdatePhoneModal> {
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return BlocProvider(
      create: (context) => PhoneUpdateBloc(),
      child: BlocConsumer<PhoneUpdateBloc, PhoneUpdateState>(
        listener: (context, state) async {
          if (state is PhoneUpdateError) {
            await showErrorSnackbar(context, state.error);
          }

          if (state is PhoneOtpSent) {
            final bloc = context.read<PhoneUpdateBloc>();

            // await Future.delayed(
            //   const Duration(milliseconds: 150),
            // ); 

            await GeneralDialogs.showCustomDialog<void>(
              context,
              body: BlocProvider.value(
                value: bloc,
                child: UpdateSMSModal(
                  number: state.phoneNumber,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PhoneUpdateLoading;

          return Padding(
            padding: EdgeInsets.only(
              top: 260.h,
              bottom: 260.h,
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
                          'Update SMS Number',
                          size: 20,
                          height: 32.5,
                          weight: FontWeight.w700,
                          color: appColors.black,
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: appColors.black),
                          onPressed:
                              isLoading ? null : () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    20.verticalSpace,
                    GenText(
                      widget.phoneNumber,
                      size: 12,
                      height: 12.5,
                      weight: FontWeight.w500,
                      color: appColors.black,
                      textAlign: TextAlign.center,
                    ),
                    20.verticalSpace,
                    KFormField(
                      label: 'Phone Number',
                      controller: phoneController,
                      hintText: 'Enter the new number',
                      // enabled: !isLoading,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    30.verticalSpace,
                    WideButton(
                      heigth: 45,
                      label: isLoading ? 'Sending...' : 'Continue',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed:
                          phoneController.text.isEmpty || isLoading
                              ? null
                              : () {
                                context.read<PhoneUpdateBloc>().add(
                                  RequestPhoneOtpEvent(
                                    newPhoneNumber: phoneController.text.trim(),
                                  ),
                                );
                              },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
