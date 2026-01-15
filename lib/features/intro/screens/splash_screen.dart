import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/view_models/customer_auth_vm.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/intro/screens/intro_screen.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/authentication/view_models/provider_auth_vm.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _goToNext() async {
    try {
      await CustomerAuthProvider.instance.init();
      await ProviderAuthProvider.instance.init();

      final isIntroCompleted =
          await AuthLocalRepo.instance.getIsIntroCompleted();

      final hasCustomerAuth = CustomerAuthProvider.instance.authInfo != null;
      final hasProviderAuth = ProviderAuthProvider.instance.authInfo != null;

      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;

        if (!isIntroCompleted) {
          await replaceScreen(context, const IntroScreen());
          return;
        } else if (hasCustomerAuth || hasProviderAuth) {
          await _navigateToNext();
        } else {
          await replaceScreen(context, const SelectAccountTypeScreen());
        }
      });
    } on Exception catch (e, t) {
      log('e $e, $t');
      if (mounted) {
        await replaceScreen(context, const IntroScreen());
      }
    }
  }

  Future<void> _navigateToNext() async {
    final userTypeString = await AuthLocalRepo.instance.getUserType();
    final userType =
        userTypeString == UserType.provider.name
            ? UserType.provider
            : UserType.customer;

    if (userTypeString == null && mounted) {
      await replaceScreen(
        context,
        const SelectAccountTypeScreen(),
      );
      return;
    }

    dashboardViewModel.userType = userType;

    await replaceScreen(
      context,
      MainLayoutPage(userType: userType),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _goToNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      body: AppAssets.ASSETS_LOGO_SPLASH_2_PNG.imageAsset(
        height: double.infinity,
        width: double.infinity,
      ),
    );
  }
}
