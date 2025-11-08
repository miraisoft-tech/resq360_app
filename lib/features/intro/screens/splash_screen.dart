import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/intro/screens/intro_screen.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/authentication/view_models/auth_vm.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _goToNext() async {
    try {
      // initialize both singletons (safe): they read local storage and populate authInfo if present
      await Future.wait([
        CustomerAuthProvider.instance.init(),
        ProviderAuthProvider.instance.init(),
      ]);

      final isIntroCompleted =
          await AuthLocalRepo.instance.getIsIntroCompleted();

      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;

        if (!isIntroCompleted) {
          await replaceScreen(context, const IntroScreen());
          return;
        }

        // If intro done: determine if there's a restored auth for either role.
        final hasCustomerAuth = CustomerAuthProvider.instance.authInfo != null;
        final hasProviderAuth = ProviderAuthProvider.instance.authInfo != null;
        log('Splash AuthProvider hash: ${CustomerAuthProvider.instance.hashCode}');
       
        log('Auth info: ${CustomerAuthProvider.instance.authInfo}');

        if (hasCustomerAuth || hasProviderAuth) {
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

  if (userTypeString == null && mounted) {
    await replaceScreen(
      context,
      const SelectAccountTypeScreen(),
    );
    return;
  }

  final userType = userTypeString == 'provider'
      ? UserType.provider
      : UserType.customer;

  dashboardViewModel.userType = userType;

  if (!mounted) return;

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
