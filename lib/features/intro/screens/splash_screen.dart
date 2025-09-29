import 'package:resq360/__lib.dart';
import 'package:resq360/features/intro/screens/intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _goToNext() async {
    try {
      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;

        await pushScreen(
          context,
          const IntroScreen(),
        );

        // if (!mounted) return;

        // if (isOnboardingCompleted == false) {
        // } else if (isIntroCompleted == false) {
        // } else if (isIntroCompleted == true && (authRef.authInfo != null)) {

        //       : DashboardArtisanRoute().go(context);
        // } else {}
      });
    } on Exception catch (e, t) {
      log('e $e, $t');

      if (mounted) {}
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
