// Reason: We have several fire-and-forget UI calls (dialogs, snackbars)
// in BlocListeners that do not need to be awaited.
// ignore_for_file: unawaited_futures
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/screens/provider_create_account_screen.dart';
import 'package:resq360/features/provider/authentication/screens/provider_forgot_password_screen.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class ProviderLoginScreen extends StatefulWidget {
  const ProviderLoginScreen({super.key});

  @override
  State<ProviderLoginScreen> createState() => _ProviderLoginScreenState();
}

class _ProviderLoginScreenState extends State<ProviderLoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
    passwordController = TextEditingController();

    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) => AppTrackingPermissionHandler.requestTrackingPermisssion(),
    // );
  }

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
          log(state.error);
          showSnackBar(context, 'Error', state.error);
        }

        if (state is ProviderAuthLoginSuccessState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          await replaceScreen(
            context,
             const MainLayoutPage(userType: UserType.provider),
          );
        }
      },
      child: AppScaffold(
        title: 'Welcome Back!',
        subTitle: 'Log into your account',
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KFormField(
                label: 'Email Address',
                hintText: 'Enter Your Email Address',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (a) {
                  setState(() {});
                },
                validator: Validators.validateEmail,
              ),
              16.verticalSpace,
              KFormField(
                label: 'Password',
                hintText: 'Enter Password',
                controller: passwordController,
                type: InputType.password,
                onChanged: (a) {
                  setState(() {});
                },
                validator: Validators.validatePassword,
              ),
              16.verticalSpace,
              GestureDetector(
                onTap: () async {
                  await pushScreen(
                    context,
                    const ProviderForgotPasswordScreen(),
                  );
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GenText(
                    'Forget Password?',
                    size: 12,
                    height: 20,
                    weight: FontWeight.w400,
                    color: colors.textColor.shade500,
                  ),
                ),
              ),
              24.verticalSpace,
              WideButton(
                label: 'Log in',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    context.read<ProviderAuthBloc>().add(
                      ProviderLoginWithEmail(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      ),
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
