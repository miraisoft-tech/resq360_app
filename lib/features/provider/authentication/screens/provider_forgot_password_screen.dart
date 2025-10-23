// Reason: We have several fire-and-forget UI calls (dialogs, snackbars) 
// in BlocListeners that do not need to be awaited.
// ignore_for_file: unawaited_futures
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/verification_enum.dart';
import 'package:resq360/features/customer/authentication/screens/verify_email_screen.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/screens/provider_create_account_screen.dart';
import 'package:resq360/features/provider/authentication/screens/provider_verify_email_screen.dart';

class ProviderForgotPasswordScreen extends StatefulWidget {
  const ProviderForgotPasswordScreen({super.key});

  @override
  State<ProviderForgotPasswordScreen> createState() =>
      _ProviderForgotPasswordScreenState();
}

class _ProviderForgotPasswordScreenState
    extends State<ProviderForgotPasswordScreen> {
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<ProviderAuthBloc, ProviderAuthState>(
      listener: (context, state) async{
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

        if (state is ProviderForgotPasswordSucessState) {
          // showSuccessSnackbar(context, 'Password reset email sent successfully!');
             if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
          await pushScreen(
            context,
            ProviderVerifyEmailScreen(
              email: emailController.text,
              purpose: VerificationPurpose.passwordReset,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.whiteColor,
        appBar: AppBar(
          backgroundColor: colors.whiteColor,
          forceMaterialTransparency: true,
          leading: IconButton(
            onPressed: () => pop(context),
            icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
          ),
        ),
        body: Padding(
          padding: pad(horizontal: 16, vertical: 10),
          child: ListView(
            children: [
              AppAssets.ASSETS_IMAGES_FORGOT_PASS_PNG.imageAsset(
                height: 164,
                width: 164,
                fit: BoxFit.contain,
              ),
              16.verticalSpace,
              UrbText(
                'Forgot Password?',
                size: 22,
                height: 32,
                weight: FontWeight.w700,
                color: colors.black,
                textAlign: TextAlign.center,
              ),
              GenText(
                'No worries! Let’s help you reset it',
                height: 18.5,
                weight: FontWeight.w400,
                color: colors.textColor.shade500,
                textAlign: TextAlign.center,
              ),
              30.verticalSpace,
              KFormField(
                label: 'Email Address',
                hintText: 'janedoe@gmail.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (a) {
                  setState(() {});
                },
              ),
              70.verticalSpace,
              WideButton(
                label: 'Send Reset Code',
                onPressed: () async {

                  if (emailController.text.isEmpty) {
                    showErrorSnackbar(context, 'Please enter a valid email.');
                    return;
                  } else {
                    context.read<ProviderAuthBloc>().add(
                      ProviderForgotPassword(email: emailController.text),
                    );
                  }
                },
              ),
              25.verticalSpace,
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await pushScreen(
                      context,
                      const ProviderCreateAccountScreen(),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: colors.textColor.shade500),
                      children: [
                        TextSpan(
                          text: 'Don’t have an account? ',
                          style: TextStyle(
                            fontFamily: 'inter',
                            fontSize: 12.sp,
                            color: colors.neutral.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: ' Sign up',
                          style: TextStyle(
                            fontFamily: 'inter',
                            fontSize: 12.sp,
                            color: colors.primary.shade500,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
