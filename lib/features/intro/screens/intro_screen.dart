import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/nav_item.model.dart';
import 'package:resq360/features/customer/authentication/data/service/auth.local.repo.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int currentIndex = 0;

  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    log('skip');
    await AuthLocalRepo.instance.saveIntroCompleted(isIntroCompleted: true);
    if (!mounted) return;

    await replaceScreen(
      context,
      const SelectAccountTypeScreen(),
    );
  }

  Future<void> _continue() async {
    if (_pageController == null) return;
    if (currentIndex < 2) {
      await _pageController?.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    } else {
      await AuthLocalRepo.instance.saveIntroCompleted(isIntroCompleted: true);
      if (!mounted) return;

      await replaceScreen(
        context,
        const SelectAccountTypeScreen(),
      );
    }
  }

  final List<NavItem> introItems = [
    NavItem(
      title: 'Get Help When You Need It Most',
      subTitle:
          'Roadside emergencies? From breakdowns to flat tires, ResQ360 connects you to trusted providers instantly.',
      imagePath: AppAssets.ASSETS_IMAGES_INTRO_1_PNG,
    ),
    NavItem(
      title: 'Support Beyond Towing',
      subTitle:
          'Access mechanics, ambulance services, firefighters, electricians, and more, all in one app.',
      imagePath: AppAssets.ASSETS_IMAGES_INTRO_2_PNG,
    ),
    NavItem(
      title: 'Fast, Secure & Transparent',
      subTitle:
          'Track providers, chat in-app, review services, and pay securely, no hidden charges.',
      imagePath: AppAssets.ASSETS_IMAGES_INTRO_3_PNG,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: pad(vertical: 10),
          child: Column(
            children: [
              GestureDetector(
                onTap: _skip,
                child: Padding(
                  padding: pad(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: pad(horizontal: 10),
                      child: GenText(
                        'Skip',
                        size: 16,
                        height: 26,
                        color: colors.primary.shade500,
                        weight: FontWeight.w700,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
              ),
              50.verticalSpace,
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (newPage) {
                    setState(() {
                      currentIndex = newPage;
                    });
                  },
                  children:
                      introItems.map((e) {
                        return Padding(
                          padding: pad(horizontal: 25),
                          child: Column(
                            children: [
                              e.imagePath.imageAsset(
                                height: 300,
                                width: 300,
                              ),
                              40.verticalSpace,
                              UrbText(
                                e.title,
                                size: 26,
                                height: 36,
                                color: colors.black,
                                weight: FontWeight.w700,
                                textAlign: TextAlign.center,
                              ),
                              10.verticalSpace,
                              GenText(
                                e.subTitle,
                                height: 24,
                                color: colors.textColor.shade500,
                                weight: FontWeight.w400,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DotIndicator(
                    total: 3,
                    currentIndex: currentIndex,
                  ),
                ],
              ),
              30.verticalSpace,
              Padding(
                padding: pad(horizontal: 16, vertical: 20),
                child: WideButton(
                  label: currentIndex > 2 ? 'Get Started' : 'Next',
                  onPressed: _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
