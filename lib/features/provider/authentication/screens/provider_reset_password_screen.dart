// Reason: We have several fire-and-forget UI calls (dialogs, snackbars)
// in BlocListeners that do not need to be awaited.
// ignore_for_file: unawaited_futures

import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/screens/provider_login_screen.dart';
import 'package:resq360/features/widgets/dialogs/step.modal.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class ProviderResetPasswordScreen extends StatefulWidget {
  const ProviderResetPasswordScreen({super.key});

  @override
  State<ProviderResetPasswordScreen> createState() =>
      _ProviderResetPasswordScreenState();
}

class _ProviderResetPasswordScreenState
    extends State<ProviderResetPasswordScreen> {
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProviderAuthBloc, ProviderAuthState>(
      listener: (context, state) async {
        if (!mounted) return;

        if (state is ProviderAuthLoadingState) {
          showLoadingDialog(context);
        }

        if (state is ProviderAuthFailureState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          showSnackBar(context, 'Error', state.error);
        }

        if (state is ProviderResetPasswordSuccesState) {
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
                      const ProviderLoginScreen(),
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
                onChanged: (_) => setState(() {}),
                validator: Validators.validatePassword,
              ),
              16.verticalSpace,
              KFormField(
                label: 'Confirm Password',
                hintText: 'Re-enter Your New Password',
                controller: confirmPasswordController,
                type: InputType.password,
                onChanged: (_) => setState(() {}),
                validator: (value) =>
                    Validators.validateNotEmpty(value, 'confirm password'),
              ),
              60.verticalSpace,
              WideButton(
                label: 'Reset Password',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      showSnackBar(
                        context,
                        'Error',
                        'Passwords do not match',
                      );
                      return;
                    }

                    context.read<ProviderAuthBloc>().add(
                      ProviderSetNewPasswordEvent(
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
