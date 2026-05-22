import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/main_layout_provider.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({required this.userType, super.key});
  final UserType userType;
  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

GlobalKey<ScaffoldState> mainLayoutScaffoldKey = GlobalKey<ScaffoldState>();

class _MainLayoutPageState extends State<MainLayoutPage> {
  late DashboardViewModel dashboardVM;
  bool _isGuest = false;
  bool _ownsDashboardVM = false;

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
  void initState() {
    super.initState();
    dashboardVM = dashboardViewModel;
    dashboardVM.userType = widget.userType;
    _ownsDashboardVM = false;
    unawaited(_loadGuestMode());
  }

  Future<void> _loadGuestMode() async {
    final isGuest = await AuthLocalRepo.instance.getGuestMode();
    if (!mounted) return;
    setState(() => _isGuest = isGuest);
  }

  Future<void> _requireLogin() async {
    await showErrorSnackbar(context, 'Please log in to continue');
    await pushScreen(context, const SelectAccountTypeScreen());
  }

  @override
  void dispose() {
    if (_ownsDashboardVM) {
      dashboardVM.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final navItems =
        dashboardVM.userType == UserType.customer
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
            body: Column(
              children: [
                Expanded(child: navItems[selectedIndex].body),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 15.h,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.whiteColor,
                    border: Border(
                      top: BorderSide(
                        color: appColors.neutral.shade100,
                        width: 0.6,
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 64,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    minimum: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      children: List.generate(navItems.length, (index) {
                        final item = navItems[index];
                        final isSelected = selectedIndex == index;
                        return Expanded(
                          child: InkWell(
                            onTap: () async {
                              await HapticFeedback.lightImpact();
                              if (widget.userType == UserType.customer &&
                                  _isGuest &&
                                  index > 1) {
                                await _requireLogin();
                                return;
                              }
                              dashboardVM.onChanged(index);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
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
                                    height: 24,
                                    width: 24,
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
                                  color:
                                      isSelected
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
