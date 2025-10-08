import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/screens/login_screen.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 290.h, bottom: 290.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 25, vertical: 25),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UrbText(
                'Are you sure you want to log out?',
                size: 19,
                height: 26.5,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
              40.verticalSpace,
              WideButton(
                label: 'Yes',
                backgroundColor: appColors.error.shade500,
                textColor: appColors.whiteColor,
                onPressed: () async {
                  if (context.mounted) {
                    await replaceScreen(
                      context,
                      const LoginScreen(),
                    );
                  }
                },
              ),
              20.verticalSpace,
              WideButton(
                label: 'Back',
                backgroundColor: appColors.error.shade50,
                textColor: appColors.error.shade500,
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
