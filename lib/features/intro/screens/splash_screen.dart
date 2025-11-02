import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/customer/dashboard/screens/dashboard.dart';
import 'package:resq360/features/intro/screens/intro_screen.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/provider/dashboard/screens/provider_dashboard.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Future<void> _goToNext() async {
    try {
      // Initialize auth provider and local repo
      await ref.read(authProvider).init();

      final authRepo = AuthLocalRepo.instance;
      final isIntroCompleted = await authRepo.getIsIntroCompleted();
      final userType = await authRepo.getUserType();
      final isLoggedIn = ref.read(authProvider).authInfo != null;
      log('📄 Intro completed: $isIntroCompleted');
      log('👤 User type: $userType');
      log('🔐 Is logged in: $isLoggedIn');

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      //Intro not completed
      if (!isIntroCompleted) {
        log('🧭 Redirecting to IntroScreen...');
        await replaceScreen(context, const IntroScreen());
        return;
      }

      // // Logged in
      // if (isLoggedIn) {
      //   if (userType == 'user') {
      //     log('🏠 Redirecting to Customer Dashboard...');
      //     await replaceScreen(context, const HomeScreen());
      //   } else if (userType == 'provider') {
      //     log('🧰 Redirecting to Provider Dashboard...');
      //     await replaceScreen(context, const ProviderHomeScreen());
      //   } else {
      //     log('❓ User type missing — redirecting to Account Type Selection');
      //     await replaceScreen(context, const SelectAccountTypeScreen());
      //   }
      //   return;
      // }

      // Not logged in at all
      log('🚪 User not logged in — redirecting to Account Type Selection');
      await replaceScreen(context, const SelectAccountTypeScreen());
    } on Exception catch (e, t) {
      log('Splash error: $e');
      log(t);
      if (mounted) {
        await replaceScreen(context, const IntroScreen());
      }
    }
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
      body: Center(
        child: AppAssets.ASSETS_LOGO_SPLASH_2_PNG.imageAsset(
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }
}
