import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/biometric_auth_service.dart';
import 'package:resq360/core/utils/app_tracking_permission_handler.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/screens/confirm_email_screen.dart';
import 'package:resq360/features/customer/authentication/screens/create_account_screen.dart';
import 'package:resq360/features/customer/authentication/screens/forgot_password_screen.dart';
import 'package:resq360/features/customer/authentication/view_models/customer_auth_vm.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    final customerRef = CustomerAuthProvider.instance;

    await customerRef.init();

    if (customerRef.isLocalCredStored) {
      emailController.text = customerRef.localCred?.userName ?? '';
      _hasStoredCredentials = true;

      setState(() {});
    }

    await _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final customerRef = CustomerAuthProvider.instance;
    final biometricService = BiometricAuthService.instance;

    final isAvailable = await biometricService.isBiometricAvailable();
    final hasBiometricsEnabled = customerRef.useBiometrics;

    setState(() {
      _canUseBiometrics =
          isAvailable && hasBiometricsEnabled && _hasStoredCredentials;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    final customerRef = CustomerAuthProvider.instance;
    final biometricService = BiometricAuthService.instance;

    final authenticated = await biometricService.authenticate(
      reason: 'Authenticate to login to your account',
    );

    if (authenticated && customerRef.localCred != null) {
      emailController.text = customerRef.localCred!.userName ?? '';
      passwordController.text = customerRef.localCred!.password ?? '';

      setState(() {});

      if (_formKey.currentState?.validate() ?? false) {
        if (mounted) {
          context.read<CustomerAuthBloc>().add(
            CustomerLoginWithEmail(
              email: emailController.text,
              password: passwordController.text,
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

    return BlocListener<CustomerAuthBloc, CustomerAuthState>(
      listener: (context, state) async {
        if (!mounted) return;

        if (state is CustomerAuthLoading) {
          showLoadingDialog(context);
        }

        if (state is CustomerAuthFailure) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          log(state.error);
          await showSnackBar(context, 'Error', state.error);
        }

        if (state is CustomerAuthEmailPending) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          await pushAndReplaceScreen(
            context: context,
            ConfirmEmailScreen(
              email: emailController.text,
            ),
          );
        }

        if (state is CustomerAuthLoginSuccess) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          await replaceScreen(
            context,
            const MainLayoutPage(
              userType: UserType.customer,
            ),
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
                  await pushScreen(context, const ForgotPasswordScreen());
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
                    context.read<CustomerAuthBloc>().add(
                      CustomerLoginWithEmail(
                        email: emailController.text,
                        password: passwordController.text,
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
                    await pushScreen(context, const CreateAccountScreen());
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
