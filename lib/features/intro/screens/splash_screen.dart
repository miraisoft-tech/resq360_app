import 'package:resq360/__lib.dart';
import 'package:resq360/features/authentication/data/service/auth.local.repo.dart';
import 'package:resq360/features/authentication/screens/login_screen.dart';
import 'package:resq360/features/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/intro/screens/intro_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Future<void> _goToNext() async {
    try {
      await ref.read(authProvider).init();

      final isIntroCompleted =
          await AuthLocalRepo.instance.getIsIntroCompleted();

      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;

        if (!isIntroCompleted) {
          await replaceScreen(
            context,
            const IntroScreen(),
          );
        } else if (isIntroCompleted &&
            (ref.read(authProvider).authInfo != null)) {
        } else {
          await replaceScreen(
            context,
            const LoginScreen(),
          );
        }
      });
    } on Exception catch (e, t) {
      log('e $e, $t');

      if (mounted) {
        await replaceScreen(
          context,
          const IntroScreen(),
        );
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
      body: Container(
        child: AppAssets.ASSETS_LOGO_SPLASH_2_PNG.imageAsset(
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }
}
