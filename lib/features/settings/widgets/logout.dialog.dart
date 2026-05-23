import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/chat_cache_service.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/main_layout_provider.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout(BuildContext context) async {
    if (_isLoggingOut) return;

    final navigator = Navigator.of(context, rootNavigator: true);

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ChatSocketService.instance.dispose();

      await AuthLocalRepo.instance.clearAuthCredentials();
      await AuthLocalRepo.instance.clearAccessToken();
      await AuthLocalRepo.instance.clearLocalCred();
      await AuthLocalRepo.instance.clearUserType();
      await AuthLocalRepo.instance.clearGuestMode();
      ChatCacheService.instance.clearAll();

      dashboardViewModel.reset();

      log('Cleared all local auth data successfully');

      if (!navigator.mounted) return;

      await navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const SelectAccountTypeScreen(),
        ),
        (_) => false,
      );
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }

      if (mounted) {
        await showErrorSnackbar(context, 'Logout failed: $e');
      }
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
                loading: _isLoggingOut,
                onPressed:
                    _isLoggingOut ? null : () async => _handleLogout(context),
              ),
              20.verticalSpace,
              WideButton(
                label: 'Back',
                backgroundColor: appColors.error.shade50,
                textColor: appColors.error.shade500,
                onPressed:
                    _isLoggingOut
                        ? null
                        : () async => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
