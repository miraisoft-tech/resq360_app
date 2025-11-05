import 'package:badges/badges.dart' as badges;
import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout_provider.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

GlobalKey<ScaffoldState> mainLayoutScaffoldKey = GlobalKey<ScaffoldState>();

class _MainLayoutPageState extends State<MainLayoutPage> {
  final DashboardViewModel dashboardVM = DashboardViewModel();

  DateTime currentBackPressTime = DateTime.now();

  Future<bool> onWillPop() async {
    if (dashboardVM.currentIndex == 0) {
      final now = DateTime.now();
      final diff = now.difference(currentBackPressTime).inSeconds;
      if (diff > 2) {
        currentBackPressTime = now;
        return false;
      }
      return true;
    } else {
      dashboardVM.onChanged(0);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final navItems = dashboardVM.userType == UserType.customer
        ? dashboardVM.customerDisplayNavItems
        : dashboardVM.providerDisplayNavItems;

    return PopScope(
      onPopInvokedWithResult: (bool res, dynamic value) async => onWillPop(),
      child: AnimatedBuilder(
        animation: dashboardVM,
        builder: (context, _) {
          final selectedIndex = dashboardVM.currentIndex;

          return Scaffold(
            key: mainLayoutScaffoldKey,
            body: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  bottom: 40.h,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: navItems[selectedIndex].body,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: pad(horizontal: 8),
                    height: (75 + 10).h,
                    decoration: BoxDecoration(
                      color: appColors.whiteColor,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 64,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: List.generate(navItems.length, (index) {
                        final item = navItems[index];
                        final isSelected = selectedIndex == index;
                        return Expanded(
                          child: InkWell(
                            onTap: () async {
                              await HapticFeedback.lightImpact();
                              dashboardVM.onChanged(index);
                            },
                            child: Column(
                              children: <Widget>[
                                15.verticalSpace,
                                badges.Badge(
                                  position: badges.BadgePosition.topEnd(),
                                  showBadge: false,
                                  ignorePointer: true,
                                  badgeContent: GenText(
                                    '0',
                                    size: 12,
                                    height: 12,
                                    weight: FontWeight.w600,
                                    textAlign: TextAlign.center,
                                    color: appColors.whiteColor,
                                  ),
                                  badgeStyle: badges.BadgeStyle(
                                    shape: badges.BadgeShape.square,
                                    badgeColor: const Color(0xffCE2C60),
                                    padding: pad(horizontal: 5, vertical: 3),
                                    borderRadius: BorderRadius.circular(3),
                                    elevation: 0,
                                  ),
                                  child: SvgPicture.asset(
                                    isSelected
                                        ? item.selectedImgPath
                                        : item.unselectedImgPath,
                                    colorFilter: ColorFilter.mode(
                                      isSelected
                                          ? appColors.primary.shade500
                                          : appColors.neutral.shade300,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                4.verticalSpace,
                                GenText(
                                  item.title,
                                  size: 12,
                                  height: 15.1,
                                  weight: FontWeight.w500,
                                  color: isSelected
                                      ? appColors.primary.shade500
                                      : appColors.neutral.shade300,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
