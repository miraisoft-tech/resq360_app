import 'dart:async';

import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/nav_item.model.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/chat/bloc/chat_list_bloc/chat_list_bloc.dart';
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
    context.read<ChatListBloc>().add(LoadChatList());
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

  Future<void> _onNavItemTapped(int index) async {
    await HapticFeedback.lightImpact();

    if (widget.userType == UserType.customer && _isGuest && index > 1) {
      await _requireLogin();
      return;
    }

    dashboardVM.onChanged(index);
  }

  Widget _navIcon(String assetPath, Color color) {
    return SvgPicture.asset(
      assetPath,
      height: 24,
      width: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  BottomNavigationBarItem _bottomNavItem(
    NavItem item, {
    required Color selectedColor,
    required Color unselectedColor,
    int badgeCount = 0,
  }) {
    return BottomNavigationBarItem(
      icon: _navIconWithBadge(
        item.unselectedImgPath,
        unselectedColor,
        badgeCount,
      ),
      activeIcon: _navIconWithBadge(
        item.selectedImgPath,
        selectedColor,
        badgeCount,
      ),
      label: item.title,
    );
  }

  Widget _navIconWithBadge(String assetPath, Color color, int badgeCount) {
    final icon = _navIcon(assetPath, color);
    if (badgeCount <= 0) return icon;
    return Badge(
      label: Text(
        badgeCount > 99 ? '99+' : '$badgeCount',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      child: icon,
    );
  }

  List<BottomNavigationBarItem> _buildNavItems(
    List<NavItem> navItems, {
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final chatIndex = dashboardVM.userType == UserType.customer ? 3 : 2;
    final unreadCount = context.watch<ChatListBloc>().state.totalUnreadCount;

    return navItems
        .asMap()
        .entries
        .map((entry) {
          return _bottomNavItem(
            entry.value,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            badgeCount: entry.key == chatIndex ? unreadCount : 0,
          );
        })
        .toList(growable: false);
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
            body: navItems[selectedIndex].body,
            bottomNavigationBar: DecoratedBox(
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
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: selectedIndex,
                onTap: (index) => unawaited(_onNavItemTapped(index)),
                type: BottomNavigationBarType.fixed,
                backgroundColor: appColors.whiteColor,
                elevation: 10,
                selectedFontSize: 12,
                selectedItemColor: appColors.primary.shade600,
                unselectedItemColor: appColors.neutral.shade500,
                selectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  height: 1.26,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  height: 1.26,
                  fontWeight: FontWeight.w500,
                ),
                items: _buildNavItems(
                  navItems,
                  selectedColor: appColors.primary.shade600,
                  unselectedColor: appColors.neutral.shade500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
