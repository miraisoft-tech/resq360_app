import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  Future<void> _handleDeleteAccount(BuildContext context) async {
    showLoadingDialog(context);

    try {
      final isProvider = dashboardViewModel.userType == UserType.provider;
      
      if (isProvider) {
        context.read<ProviderAuthBloc>().add(const ProviderDeleteAccount());
      } else {
        context.read<CustomerAuthBloc>().add(const CustomerDeleteAccount());
      }
    } on Exception catch (e) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      await showErrorSnackbar(context, 'Delete account failed: $e');
    }
  }

  Future<void> _clearDataAndNavigate(BuildContext context) async {
    try {
      await ChatSocketService.instance.dispose();
      await AuthLocalRepo.instance.clearAuthCredentials();
      await AuthLocalRepo.instance.clearAccessToken();
      await AuthLocalRepo.instance.clearUserType();
      await AuthLocalRepo.instance.clearLocalCredentials();

      log('Cleared all local auth data successfully');

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        await replaceScreen(context, const SelectAccountTypeScreen());
      }
    } on Exception catch (e) {
      log('Error clearing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isProvider = dashboardViewModel.userType == UserType.provider;

    return MultiBlocListener(
      listeners: [
        if (isProvider)
          BlocListener<ProviderAuthBloc, ProviderAuthState>(
            listener: (context, state) async {
              if (state is ProviderAccountDeletedState) {
                await _clearDataAndNavigate(context);
                if (context.mounted) {
                  await showSuccessSnackbar(context, state.message);
                }
              } else if (state is ProviderAccountDeletionFailedState) {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                await showErrorSnackbar(context, state.error);
              }
            },
          )
        else
          BlocListener<CustomerAuthBloc, CustomerAuthState>(
            listener: (context, state) async {
              if (state is CustomerAccountDeletedState) {
                await _clearDataAndNavigate(context);
                if (context.mounted) {
                  await showSuccessSnackbar(context, state.message);
                }
              } else if (state is CustomerAccountDeletionFailedState) {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                await showErrorSnackbar(context, state.error);
              }
            },
          ),
      ],
      child: Padding(
        padding: EdgeInsets.only(top: 290.h, bottom: 150.h),
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 150.h,
            margin: pad(horizontal: 20,),
            padding: pad(horizontal: 25, vertical: 25),
            decoration: BoxDecoration(
              color: appColors.whiteColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: appColors.error.shade500,
                  size: 48,
                ),
                16.verticalSpace,
                UrbText(
                  'Delete Account',
                  size: 22,
                  weight: FontWeight.w700,
                  color: appColors.black,
                ),
                12.verticalSpace,
                UrbText(
                  'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                  height: 20,
                  weight: FontWeight.w400,
                  color: appColors.textColor.shade400,
                  textAlign: TextAlign.center,
                ),
                30.verticalSpace,
                WideButton(
                  label: 'Yes, Delete Account',
                  backgroundColor: appColors.error.shade500,
                  textColor: appColors.whiteColor,
                  onPressed: () async => _handleDeleteAccount(context),
                ),
                16.verticalSpace,
                WideButton(
                  label: 'Cancel',
                  backgroundColor: appColors.textColor.shade50,
                  textColor: appColors.textColor.shade600,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
