import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/push_notification_service.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/screens/login_screen.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/authentication/screens/provider_login_screen.dart';

class SelectAccountTypeScreen extends StatefulWidget {
  const SelectAccountTypeScreen({super.key});

  @override
  State<SelectAccountTypeScreen> createState() =>
      _SelectAccountTypeScreenState();
}

class _SelectAccountTypeScreenState extends State<SelectAccountTypeScreen> {
  int _selectedIndex = 0;

  Future<void> _onContinue() async {
    log('Selected index: $_selectedIndex');

    final selectedType =
        _selectedIndex == 0 ? UserType.customer : UserType.provider;

    await AuthLocalRepo.instance.saveUserType(selectedType);

    if (!mounted) return;

    dashboardViewModel.userType = selectedType;

    if (_selectedIndex == 0) {
      await pushScreen(
        context,
        BlocProvider(
          create: (_) => CustomerAuthBloc(),
          child: const LoginScreen(),
        ),
      );
    } else {
      await pushScreen(context, const ProviderLoginScreen());
    }
  }

  Future<void> _onContinueAsGuest() async {
    await AuthLocalRepo.instance.saveGuestMode(isGuest: true);
    await AuthLocalRepo.instance.saveUserType(UserType.customer);
    await AuthLocalRepo.instance.clearAccessToken();
    await AuthLocalRepo.instance.clearAuthCredentials();

    if (!mounted) return;

    dashboardViewModel.userType = UserType.customer;

    await replaceScreen(
      context,
      const MainLayoutPage(userType: UserType.customer),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await notificationService.initializeAppNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              40.verticalSpace,
              AppAssets.ASSETS_IMAGES_CREATE_ACCOUNT_TYPE_PNG.imageAsset(
                height: 170,
                width: 200,
                fit: BoxFit.contain,
              ),
              30.verticalSpace,
              UrbText(
                "Let's Get You Started",
                size: 26,
                height: 32,
                weight: FontWeight.w700,
                color: colors.black,
                textAlign: TextAlign.center,
              ),
              5.verticalSpace,
              GenText(
                'Are you here to request or provide a service?',
                height: 20,
                color: colors.textColor.shade300,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              40.verticalSpace,
              _AccountTypeCard(
                title: "I'm a client",
                subTitle: 'Looking for services',
                isSelected: _selectedIndex == 0,
                icon: AppAssets.ASSETS_ICONS_CLIENT_ICON_SVG.svg,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              20.verticalSpace,
              _AccountTypeCard(
                title: "I'm a Service Provider",
                subTitle: 'Offering my services',
                isSelected: _selectedIndex == 1,
                icon: AppAssets.ASSETS_ICONS_VENDOR_ICON_SVG.svg,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              const Spacer(),
              WideButton(label: 'Continue', onPressed: _onContinue),
              10.verticalSpace,
              if (_selectedIndex == 0)
                GestureDetector(
                  onTap: _onContinueAsGuest,
                  child: GenText(
                    'Continue as guest',
                    height: 20,
                    weight: FontWeight.w600,
                    color: colors.primary.shade500,
                    textAlign: TextAlign.center,
                  ),
                ),
              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.title,
    required this.subTitle,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String subTitle;
  final bool isSelected;
  final Widget icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: pad(vertical: 20, horizontal: 18),
        decoration: BoxDecoration(
          color: colors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary.shade500 : colors.greyColor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            icon,
            15.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UrbText(
                    title,
                    size: 18,
                    height: 28.5,
                    weight: FontWeight.w700,
                    color: colors.black,
                  ),
                  4.verticalSpace,
                  GenText(
                    subTitle,
                    height: 16.5,
                    color: colors.neutral.shade400,
                    weight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary.shade500, width: 1.5),
                color: isSelected ? colors.primary.shade500 : colors.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
