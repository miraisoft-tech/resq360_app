import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/widgets/update_phone_sms.modal.dart';

class UpdatePhoneModal extends StatefulWidget {
  const UpdatePhoneModal({super.key});

  @override
  State<UpdatePhoneModal> createState() => _UpdatePhoneModalState();
}

class _UpdatePhoneModalState extends State<UpdatePhoneModal> {
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              20.verticalSpace,
              GenText(
                '08145660699',
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
                onChanged: (value) {
                  setState(() {});
                },
              ),
              30.verticalSpace,
              WideButton(
                heigth: 45,
                label: 'Continue',
                backgroundColor: appColors.primary.shade500,
                textColor: appColors.whiteColor,
                onPressed:
                    phoneController.text.isEmpty
                        ? null
                        : () async {
                          Navigator.pop(context);
                          await GeneralDialogs.showCustomDialog(
                            context,
                            body: const UpdateSMSModal(),
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
