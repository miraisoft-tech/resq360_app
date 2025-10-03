import 'package:resq360/__lib.dart';
import 'package:resq360/features/authentication/screens/create_account_screen.dart';
import 'package:resq360/features/authentication/screens/verify_email_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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

    return Scaffold(
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
        child: Column(
          children: [
            AppAssets.ASSETS_IMAGES_FORGOT_PASS_PNG.imageAsset(
              height: 164,
              width: 164,
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
                await pushScreen(
                  context,
                  VerifyEmailScreen(
                    email: emailController.text,
                  ),
                );
              },
            ),
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
    );
  }
}
