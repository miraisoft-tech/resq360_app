import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/screens/login_screen.dart';
import 'package:resq360/features/widgets/dialogs/step.modal.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        title: UrbText(
          'Change Password',
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
        forceMaterialTransparency: true,
        backgroundColor: appColors.whiteColor,
        foregroundColor: appColors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KFormField(
                label: 'Current Password',
                controller: currentPasswordController,
                hintText: 'Enter Your Current Password',
                onChanged: (value) {},
              ),
              20.verticalSpace,
              KFormField(
                label: 'New Password',
                controller: newPasswordController,
                hintText: 'Enter Your New Password',
                onChanged: (value) {},
              ),
              20.verticalSpace,
              KFormField(
                label: 'Confirm New Password',
                controller: confirmPasswordController,
                hintText: 'Enter Your New Password',
                onChanged: (value) {},
              ),

              10.verticalSpace,
              GenText(
                'Password should be at least 8 characters',
                size: 12,
                color: appColors.textColor.shade400,
              ),
              const Spacer(),
              WideButton(
                label: 'Change Password',
                onPressed: () async {
                  await GeneralDialogs.showCustomBottomSheet(
                    context,
                    body: StepModal(
                      title: 'Password Changed Successfully!',
                      description: 'Please log in again to continue',
                      buttonText: 'Log in',
                      icon: AppAssets.ASSETS_IMAGES_PASSWORD_RESET_SUCCESS_PNG,
                      onContinuePressed: () async {
                        await pop(context);

                        if (context.mounted) {
                          await replaceScreen(
                            context,
                            const LoginScreen(),
                          );
                        }
                      },
                    ),
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
