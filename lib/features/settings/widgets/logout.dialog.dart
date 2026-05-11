import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/chat_cache_service.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/main_layout_provider.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    showLoadingDialog(context);

    try {
      await ChatSocketService.instance.dispose();

      await AuthLocalRepo.instance.clearAuthCredentials();
      await AuthLocalRepo.instance.clearAccessToken();
      await AuthLocalRepo.instance.clearUserType();
      ChatCacheService.instance.clearAll();

      dashboardViewModel.reset();

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
      padding: EdgeInsets.only(top: 280.h, bottom: 280.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 16),
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
                height: 20.5,
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
