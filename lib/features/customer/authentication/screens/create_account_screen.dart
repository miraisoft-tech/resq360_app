import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/screens/confirm_email_screen.dart';
import 'package:resq360/features/customer/authentication/screens/login_screen.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  final _formKey = GlobalKey<FormState>();
  bool _agree = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
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

    return AppScaffold(
      title: 'Create Account',
      subTitle: 'Join our community of trusted users',
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    KFormField(
                      label: 'Full Name',
                      hintText: 'Enter Your Full Name',
                      controller: nameController,
                      onChanged: (a) {
                        setState(() {});
                      },
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Email Address',
                      hintText: 'Enter Your Email Address',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (a) {
                        setState(() {});
                      },
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Password',
                      hintText: 'Create a Password',
                      controller: passwordController,
                      type: InputType.password,
                      onChanged: (a) {
                        setState(() {});
                      },
                    ),
                    30.verticalSpace,
                    Row(
                      children: [
                        CheckBoxWidget(
                          isChecked: _agree,
                          onChanged: (value) {
                            _agree = value!;

                            setState(() {});
                          },
                        ),
                        6.horizontalSpace,
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: colors.textColor.shade500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'I agree to the ',
                                  style: TextStyle(
                                    fontFamily: 'inter',
                                    fontSize: 12.sp,
                                    color: colors.neutral.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Terms and Conditions',
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
                      ],
                    ),
                    20.verticalSpace,
                    WideButton(
                      label: 'Create Account',
                      onPressed:
                          _agree
                              ? () async {
                                await pushScreen(
                                  context,
                                  ConfirmEmailScreen(
                                    email: emailController.text,
                                  ),
                                );
                              }
                              : null,
                    ),
                    30.verticalSpace,
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: pad(horizontal: 8),
                          child: GenText(
                            'or sign up with',
                            color: colors.textColor.shade500,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    20.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(
                          icon: AppAssets.ASSETS_IMAGES_GOOGLE_PNG,
                          onTap: () {},
                        ),
                        40.horizontalSpace,
                        _SocialButton(
                          icon: AppAssets.ASSETS_IMAGES_APPLE_PNG,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await pushScreen(context, const LoginScreen());
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: colors.textColor.shade500),
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            fontFamily: 'inter',
                            fontSize: 12.sp,
                            color: colors.neutral.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'Log in',
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
              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.onTap,
  });
  final String icon;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: icon.imageAsset(height: 40, width: 40),
    );
  }
}
