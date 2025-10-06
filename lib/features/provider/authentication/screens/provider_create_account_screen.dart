import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/screens/provider_business_details_screen.dart';
import 'package:resq360/features/provider/authentication/screens/provider_login_screen.dart';
import 'package:resq360/features/widgets/scaffolds/app_scaffold.dart';

class ProviderCreateAccountScreen extends StatefulWidget {
  const ProviderCreateAccountScreen({super.key});

  @override
  State<ProviderCreateAccountScreen> createState() =>
      _ProviderCreateAccountScreenState();
}

class _ProviderCreateAccountScreenState
    extends State<ProviderCreateAccountScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  final _formKey = GlobalKey<FormState>();
  bool _agree = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppScaffold(
      title: 'Create Account',
      subTitle: 'Join our community of trusted users',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              label: 'Phone Number',
              hintText: 'Enter Your Phone Number',
              controller: phoneController,
              keyboardType: TextInputType.phone,
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
                          const ProviderBusinessDetailsScreen(),
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
            const Spacer(),
            Center(
              child: GestureDetector(
                onTap: () async {
                  await pushScreen(context, const ProviderLoginScreen());
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
      child: SizedBox(
        child: icon.imageAsset(height: 40, width: 40),
      ),
    );
  }
}
