import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/screens/forgot_password_screen.dart';
import 'package:resq360/features/provider/authentication/screens/provider_create_account_screen.dart';
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

    return AppScaffold(
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
                await showErrorSnackbar(context, 'Coming Soon!');
                // await replaceScreen(
                //   context,
                //   const MainLayoutPage(),
                // );
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
    );
  }
}
