import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/biometric_auth_service.dart';
import 'package:resq360/core/utils/app_tracking_permission_handler.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/screens/provider_confirm_email_screen.dart';
import 'package:resq360/features/provider/authentication/screens/provider_create_account_screen.dart';
import 'package:resq360/features/provider/authentication/screens/provider_forgot_password_screen.dart';
import 'package:resq360/features/provider/authentication/view_models/provider_auth_vm.dart';
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

  bool _canUseBiometrics = false;
  bool _hasStoredCredentials = false;

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
    passwordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppTrackingPermissionHandler.requestTrackingPermisssion();
    });

    unawaited(init());
  }

  Future<void> init() async {
    final providerRef = ProviderAuthProvider.instance;

    await providerRef.init();

    if (providerRef.isLocalCredStored) {
      emailController.text = providerRef.localCred?.userName ?? '';
      _hasStoredCredentials = true;

      setState(() {});
    }

    await _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final providerRef = ProviderAuthProvider.instance;
    final biometricService = BiometricAuthService.instance;

    final isAvailable = await biometricService.isBiometricAvailable();
    final hasBiometricsEnabled = providerRef.useBiometics;

    setState(() {
      _canUseBiometrics =
          isAvailable && hasBiometricsEnabled && _hasStoredCredentials;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    final providerRef = ProviderAuthProvider.instance;
    final biometricService = BiometricAuthService.instance;

    final authenticated = await biometricService.authenticate(
      reason: 'Authenticate to login to your account',
    );

    if (authenticated && providerRef.localCred != null) {
      emailController.text = providerRef.localCred!.userName ?? '';
      passwordController.text = providerRef.localCred!.password ?? '';

      setState(() {});

      if (_formKey.currentState?.validate() ?? false) {
        if (mounted) {
          context.read<ProviderAuthBloc>().add(
            ProviderLoginWithEmail(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            ),
          );
        }
      }
    }
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
          await showErrorSnackbar(context, state.error);
        }

        if (state is ProviderAuthEmailPendingState) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          await pushAndReplaceScreen(
            context: context,
            ProviderConfirmEmailScreen(
              email: emailController.text,
            ),
          );
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
              if (_canUseBiometrics) ...[
                16.verticalSpace,
                GestureDetector(
                  onTap: _authenticateWithBiometrics,
                  child: Center(
                    child: Container(
                      padding: pad(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.primary.shade500),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.fingerprint,
                        color: colors.primary.shade500,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
              25.verticalSpace,
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await pushAndReplaceScreen(
                      const ProviderCreateAccountScreen(),
                      context: context,
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
