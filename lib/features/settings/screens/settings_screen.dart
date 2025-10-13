import 'package:resq360/__lib.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/settings/data/models/settings_model.dart';
import 'package:resq360/features/settings/screens/add_bank_details.dart';
import 'package:resq360/features/settings/screens/change_password_screen.dart';
import 'package:resq360/features/settings/screens/contact_admin_screen.dart';
import 'package:resq360/features/settings/screens/manage_cards_screen.dart';
import 'package:resq360/features/settings/screens/notification_settings_screen.dart';
import 'package:resq360/features/settings/screens/ratings_screen.dart';
import 'package:resq360/features/settings/screens/refer_screen.dart';
import 'package:resq360/features/settings/screens/update_service_screen.dart';
import 'package:resq360/features/settings/widgets/account_status_dialog.dart';
import 'package:resq360/features/settings/widgets/logout.dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = context.appColors;

    final isProvider =
        ref.read(dashboardViewModel).userType == UserType.provider;

    final customerSettingsOptions = [
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_RATINGS_SVG.svg,
        title: 'Rating',
        onTap: () async {
          await pushScreen(context, const RatingScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_CARDS_SVG.svg,
        title: 'Manage Cards',
        onTap: () async {
          await pushScreen(context, const ManageCardsScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_REFER_SVG.svg,
        title: 'Refer and Earn',
        onTap: () async {
          await pushScreen(context, const ReferScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_PRIVACY_POLICY_SVG.svg,
        title: 'Terms of Use Policy',
        onTap: () {},
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_PASSWORD_SVG.svg,
        title: 'Change Password',
        onTap: () async {
          await pushScreen(context, const ChangePasswordScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_ADMIN_SVG.svg,
        title: 'Contact Admin',
        onTap: () async {
          await pushScreen(context, const ContactAdminScreen());
        },
      ),
    ];

    final providerSettingsOptions = [
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_RATINGS_SVG.svg,
        title: 'Rating',
        onTap: () async {
          await pushScreen(context, const RatingScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_UPDATE_SERVICE_SVG.svg,
        title: 'Update Service',
        onTap: () async {
          await pushScreen(context, const UpdateServiceScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_CARDS_SVG.svg,
        title: 'Manage Cards',
        onTap: () async {
          await pushScreen(context, const ManageCardsScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_ADD_BANK_SVG.svg,
        title: 'Add Bank Details',
        onTap: () async {
          await pushScreen(context, const AddBankDetailsScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_REFER_SVG.svg,
        title: 'Refer and Earn',
        onTap: () async {
          await pushScreen(context, const ReferScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_NOTIFICATIONS_SVG.svg,
        title: 'Notification Settings',
        onTap: () async {
          await pushScreen(context, const NotificationSettingsScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_PRIVACY_POLICY_SVG.svg,
        title: 'Terms of Use Policy',
        onTap: () {},
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_PASSWORD_SVG.svg,
        title: 'Change Password',
        onTap: () async {
          await pushScreen(context, const ChangePasswordScreen());
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_ADMIN_SVG.svg,
        title: 'Contact Admin',
        onTap: () async {
          await pushScreen(context, const ContactAdminScreen());
        },
      ),
    ];

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        title: UrbText(
          'Settings',
          size: 22,
          weight: FontWeight.w700,
          color: appColors.black,
        ),
        centerTitle: true,
        backgroundColor: appColors.whiteColor,
        foregroundColor: appColors.black,
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          bottom: 100.h,
        ),
        children: [
          10.verticalSpace,
          const _ProfileSection(),
          10.verticalSpace,
          if (isProvider)
            GestureDetector(
              onTap: () async {
                await GeneralDialogs.showCustomDialog(
                  context,
                  body: AccountStatusDialog(
                    onTap: () async {
                      Navigator.pop(context);

                      await pushScreen(context, const ContactAdminScreen());
                    },
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GenText(
                    'Account Status: ACTIVE',
                    height: 24.5,
                    color: appColors.success.shade700,
                    weight: FontWeight.w500,
                  ),
                  4.horizontalSpace,
                  AppAssets.ASSETS_ICONS_ARROW_DROPDOWN_SVG.svgColor(
                    color: appColors.success.shade700,
                  ),
                ],
              ),
            ),
          20.verticalSpace,
          if (isProvider)
            Container(
              decoration: BoxDecoration(
                color: appColors.whiteColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  ...providerSettingsOptions.map(
                    (item) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: item.icon,
                          title: GenText(
                            item.title,
                            color: appColors.black,
                            weight: FontWeight.w500,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: appColors.textColor.shade200,
                          ),
                          onTap: item.onTap,
                        ),
                        Divider(height: 5, color: appColors.textColor.shade100),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: appColors.whiteColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  ...customerSettingsOptions.map(
                    (item) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: item.icon,
                          title: GenText(
                            item.title,
                            color: appColors.black,
                            weight: FontWeight.w500,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: appColors.textColor.shade200,
                          ),
                          onTap: item.onTap,
                        ),
                        Divider(height: 5, color: appColors.textColor.shade100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          30.verticalSpace,
          GestureDetector(
            onTap: () async {
              await GeneralDialogs.showCustomDialog(
                context,
                body: const LogoutDialog(),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: appColors.error.shade500,
                ),
                10.horizontalSpace,
                GenText(
                  'Log out',
                  color: appColors.error.shade500,
                  size: 15,
                  weight: FontWeight.w600,
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: appColors.textColor.shade200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 45.r,
              backgroundImage: const NetworkImage(
                'https://randomuser.me/api/portraits/men/30.jpg',
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: pad(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: appColors.primary.shade500,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: appColors.whiteColor,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        15.verticalSpace,
        UrbText(
          'Jane Doe',
          size: 16,
          weight: FontWeight.w700,
          color: appColors.black,
        ),
      ],
    );
  }
}
