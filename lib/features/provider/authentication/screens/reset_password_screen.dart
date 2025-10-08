import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/screens/login_screen.dart';
import 'package:resq360/features/widgets/dialogs/step.modal.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late TextEditingController newPasswordController;
  late TextEditingController passwordController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    newPasswordController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    newPasswordController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reset Password',
      subTitle: 'Create your new password',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KFormField(
              label: 'New Password',
              hintText: 'Enter Your New Password',
              controller: newPasswordController,
              type: InputType.password,
              onChanged: (a) {
                setState(() {});
              },
            ),
            16.verticalSpace,
            KFormField(
              label: 'Confirm Password',
              hintText: 'Re-enter Your New Password',
              controller: passwordController,
              type: InputType.password,
              onChanged: (a) {
                setState(() {});
              },
            ),

            24.verticalSpace,
            WideButton(
              label: 'Reset Password',
              onPressed: () async {
                if (context.mounted) {
                  await GeneralDialogs.showCustomBottomSheet(
                    context,
                    body: StepModal(
                      title: 'Successful!',
                      description: 'Your password has been changed',
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
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
