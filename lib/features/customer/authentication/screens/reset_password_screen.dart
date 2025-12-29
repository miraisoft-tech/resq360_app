// Reason: We have several fire-and-forget UI calls (dialogs, snackbars)
// in BlocListeners that do not need to be awaited.
// ignore_for_file: unawaited_futures
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
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
    return BlocListener<CustomerAuthBloc, CustomerAuthState>(
      listener: (context, state) async {
        if (!mounted) return;
        if (state is! CustomerAuthLoading) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
        if (state is CustomerAuthLoading) {
          showLoadingDialog(context);
          return; 
        }

        if (state is CustomerAuthFailure) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          showSnackBar(context, 'Error', state.error);
        }

        if (state is CustomerPasswordResetSuccessState) {
          // showSuccessSnackbar(context, 'Password reset email sent successfully!');
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
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
        }
      },
      child: AppScaffold(
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
                validator: Validators.validatePassword,
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
                validator:
                    (value) =>
                        Validators.validateNotEmpty(value, 'confirm password'),
              ),
              60.verticalSpace,
              WideButton(
                label: 'Reset Password',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (newPasswordController.text != passwordController.text) {
                      showSnackBar(
                        context,
                        'Error',
                        'Passwords do not match',
                      );
                      return;
                    }

                    context.read<CustomerAuthBloc>().add(
                      CustomerSetNewPasswordEvent(
                        password: newPasswordController.text,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
