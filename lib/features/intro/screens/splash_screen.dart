import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/view_models/customer_auth_vm.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/intro/screens/intro_screen.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/view_models/provider_auth_vm.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _stageController;
  late Animation<double> _icon2SlideAnimation;
  int _currentStage = 0;

Future<void> _goToNext() async {
  try {
    await CustomerAuthProvider.instance.init();
    await ProviderAuthProvider.instance.init();

    final isIntroCompleted =
        await AuthLocalRepo.instance.getIsIntroCompleted();

    if (!mounted) return;

    if (!isIntroCompleted) {
      await replaceScreen(context, const IntroScreen());
      return;
    }

    final token = await AuthLocalRepo.instance.getAccessToken();
    if (token == null) {
      await replaceScreen(context, const SelectAccountTypeScreen());
      return;
    }

    final userTypeStr = await AuthLocalRepo.instance.getUserType();
    if (userTypeStr == null) {
      await replaceScreen(context, const SelectAccountTypeScreen());
      return;
    }

    final userType = userTypeStr == UserType.provider.value
        ? UserType.provider
        : UserType.customer;

    dashboardViewModel.userType = userType;


    await replaceScreen(
      context,
      MainLayoutPage(userType: userType),
    );

    if (!mounted) return;
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      if (userType == UserType.provider) {
        context.read<ProviderAuthBloc>()
          .add(const ProvidergetProviderProfile());
      } else {
        context.read<CustomerAuthBloc>()
          .add(const CustomergetUserProfile());
      }
    });

  } on Exception catch (e, s) {
    log('Splash Error: $e\n$s');
    if (mounted) {
      await replaceScreen(context, const IntroScreen());
    }
  }
}



//   Future<void> _navigateToNext() async {

//     final userTypeString = await AuthLocalRepo.instance.getUserType();
//     final userType =
//         userTypeString == UserType.provider.name
//             ? UserType.provider
//             : UserType.customer;
// log('LOCAL STORED USER TYPE = $userType');
//     if (userTypeString == null && mounted) {
//       await replaceScreen(
//         context,
//         const SelectAccountTypeScreen(),
//       );
//       return;
//     }

//     dashboardViewModel.userType = userType;

//     await replaceScreen(
//       context,
//       MainLayoutPage(userType: userType),
//     );
//   }

  @override
  void initState() {
    super.initState();

    _stageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _icon2SlideAnimation = Tween<double>(begin: 1.5, end: 0).animate(
      CurvedAnimation(
        parent: _stageController,
        curve: Curves.easeOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runAnimationSequence();
    });
  }

  Future<void> _runAnimationSequence() async {
    setState(() => _currentStage = 0);
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _currentStage = 1);
    await _stageController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _currentStage = 2);
    await Future<void>.delayed(const Duration(seconds: 1));

    if (mounted) {
      await _goToNext();
    }
  }

  @override
  void dispose() {
    _stageController.dispose();
    super.dispose();
  }

  Widget _buildScatteredIcons(Widget icon, {double opacity = 0.3}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: List.generate(20, (index) {
          final random = index * 123;
          final left = ((random * 37) % 100) / 100;
          final top = ((random * 59) % 100) / 100;
          final rotation = ((random * 73) % 360) * 0.0174533;
          final scale = 0.8 + ((random * 11) % 60) / 100;

          return Positioned(
            left: screenWidth * left - 30,
            top: screenHeight * top - 30,
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: icon,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const color1 = Color(0xffF2C079);
    const color2 = Color(0xffE8683B);
    const color3 = Color(0xffffffff);

    final baseAsset12 = AppAssets.ASSETS_LOGO_SPANNER_ICON_SVG.svg;
    final icon2 = AppAssets.ASSETS_LOGO_WHITE_NAME_LOGO_SVG.svg;
    final icon3 = AppAssets.ASSETS_LOGO_COLORED_NAME_LOGO_SVG.svg;

    return Scaffold(
      backgroundColor:
          _currentStage == 0
              ? color1
              : _currentStage == 1
              ? color2
              : color3,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child:
            _currentStage == 0
                ? Container(
                  key: const ValueKey(0),
                  color: color1,
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildScatteredIcons(baseAsset12, opacity: 0.4),
                )
                : _currentStage == 1
                ? AnimatedBuilder(
                  key: const ValueKey(1),
                  animation: _stageController,
                  builder: (context, child) {
                    return Container(
                      color: color2,
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                        children: [
                          _buildScatteredIcons(baseAsset12),

                          Align(
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                MediaQuery.of(context).size.height *
                                    _icon2SlideAnimation.value,
                              ),
                              child: SizedBox(
                                width: 200,
                                height: 100,
                                child: icon2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
                : Container(
                  key: const ValueKey(2),
                  color: color3,
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 100,
                      child: icon3,
                    ),
                  ),
                ),
      ),
    );
  }
}
