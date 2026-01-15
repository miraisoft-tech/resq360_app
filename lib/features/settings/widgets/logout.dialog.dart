import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    unawaited(showLoadingDialog(context));

    try {
      await AuthLocalRepo.instance.clearAuthCredentials();
      await AuthLocalRepo.instance.clearAccessToken();
      await AuthLocalRepo.instance.clearUserType();

      log('Cleared all local auth data successfully');

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        await replaceScreen(context, const SelectAccountTypeScreen());
      }
    } on Exception catch (e) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await showErrorSnackbar(context, 'Logout failed: $e');
    }
  }

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
                onPressed: () async => _handleLogout(context),
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
