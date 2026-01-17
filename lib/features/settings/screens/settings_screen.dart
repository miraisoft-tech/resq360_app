import 'dart:io';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/kyc_enums.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/screens/verification_steps_screen.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/screens/provider_verification_steps_screen.dart';
import 'package:resq360/features/settings/data/bloc/update_profile_bloc.dart/profile_update_bloc.dart';
import 'package:resq360/features/settings/data/models/admin_types.enums.dart';
import 'package:resq360/features/settings/data/models/settings_model.dart';
import 'package:resq360/features/settings/screens/change_password_screen.dart';
import 'package:resq360/features/settings/screens/contact_admin_screen.dart';
import 'package:resq360/features/settings/screens/notification_settings_screen.dart';
import 'package:resq360/features/settings/screens/ratings_screen.dart';
import 'package:resq360/features/settings/screens/update_service_screen.dart';
import 'package:resq360/features/settings/widgets/account_status_dialog.dart';
import 'package:resq360/features/settings/widgets/logout.dialog.dart';
import 'package:resq360/features/settings/widgets/pick_image.modal.dart';
import 'package:resq360/features/settings/widgets/profile_section_header.dart';
import 'package:resq360/keys.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? pickedImage;

  Future<void> _refreshProfile() async {
    if (dashboardViewModel.userType == UserType.provider) {
      context.read<ProviderAuthBloc>().add(const ProvidergetProviderProfile());
    } else {
      context.read<CustomerAuthBloc>().add(const CustomergetUserProfile());
    }
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    await GeneralDialogs.showCustomBottomSheet(
      context,
      body: CameraModal(
        onTapGallery: () async {
          Navigator.pop(context);
          await _processPickedImage(context, ImageSource.gallery);
        },
        onTapCamera: () async {
          Navigator.pop(context);
          await _processPickedImage(context, ImageSource.camera);
        },
      ),
    );
  }

  Future<void> _processPickedImage(
    BuildContext context,
    ImageSource source,
  ) async {
    final image = await AppFilePicker.pickImage(source: source);
    if (image == null) return;

    pickedImage = image;

    if (!context.mounted) return;

    context.read<ProfileUpdateBloc>().add(
      UpdateProfileImageEvent(filePath: image.path),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dashboardViewModel.userType == UserType.provider) {
        context.read<ProviderAuthBloc>().add(
          const ProvidergetProviderProfile(),
        );
      } else {
        context.read<CustomerAuthBloc>().add(const CustomergetUserProfile());
      }
    });
  }

  Future<String?> getEmail() async {
    var email = '';
    final cred = await AuthLocalRepo.instance.getLocalCredentials();
    if (cred != null) {
      email = cred.userName ?? '';
    }
    return email;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final appColors = context.appColors;

    final isProvider = dashboardViewModel.userType == UserType.provider;

    final customerSettingsOptions = [
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_RATINGS_SVG.svg,
        title: 'Rating',
        onTap: () async {
          await pushScreen(
            context,
            RatingScreen(
              isProvider: isProvider,
            ),
          );
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_REFER_SVG.svg,
        title: 'KYC',
        onTap: () async {
          final userInfo =
              await AuthLocalRepo.instance.getCustomerAuthCredentials();
          if (userInfo?.kycStatus == KycEnums.approved.name) {
            await showSuccessSnackbar(context, 'Your KYC is already approved');
          } else {
            await pushScreen(
              context,
              const VerificationStepsScreen(),
            );
          }
        },
      ),
      // SettingsItem(
      //   icon: AppAssets.ASSETS_ICONS_SETTINGS_CARDS_SVG.svg,
      //   title: 'Manage Cards',
      //   onTap: () async {
      //     await pushScreen(context, const ManageCardsScreen());
      //   },
      // ),
      // SettingsItem(
      //   icon: AppAssets.ASSETS_ICONS_SETTINGS_REFER_SVG.svg,
      //   title: 'Refer and Earn',
      //   onTap: () async {
      //     await pushScreen(context, const ReferScreen());
      //   },
      // ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_PRIVACY_POLICY_SVG.svg,
        title: 'Terms of Use Policy',
        onTap: () async {
          await AppGenUtil.launchUrlText(AppKeys.termsAndConditionsUrl);
        },
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
          await pushScreen(
            context,
            const ContactAdminScreen(
              issueType: AdminIssueType.complaint,
            ),
          );
        },
      ),
    ];

    final providerSettingsOptions = [
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_RATINGS_SVG.svg,
        title: 'Rating',
        onTap: () async {
          await pushScreen(context, RatingScreen(isProvider: isProvider));
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
        icon: AppAssets.ASSETS_ICONS_SETTINGS_REFER_SVG.svg,
        title: 'KYC',
        onTap: () async {
          final userInfo =
              await AuthLocalRepo.instance.getProviderAuthCredentials();
          if (userInfo?.kycStatus == KycEnums.approved.name) {
            await showSuccessSnackbar(context, 'Your KYC is already approved');
          } else {
            await pushScreen(
              context,
              const ProviderVerificationStepsScreen(),
            );
          }
        },
      ),
      // SettingsItem(
      //   icon: AppAssets.ASSETS_ICONS_SETTINGS_CARDS_SVG.svg,
      //   title: 'Manage Cards',
      //   onTap: () async {
      //     await pushScreen(context, const ManageCardsScreen());
      //   },
      // ),
      // SettingsItem(
      //   icon: AppAssets.ASSETS_ICONS_SETTINGS_ADD_BANK_SVG.svg,
      //   title: 'Add Bank Details',
      //   onTap: () async {
      //     await pushScreen(context, const AddBankDetailsScreen());
      //   },
      // ),
      // SettingsItem(
      //   icon: AppAssets.ASSETS_ICONS_SETTINGS_REFER_SVG.svg,
      //   title: 'Refer and Earn',
      //   onTap: () async {
      //     await pushScreen(context, const ReferScreen());
      //   },
      // ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_NOTIFICATIONS_SVG.svg,
        title: 'Notification Settings',
        onTap: () async {
          await pushScreen(
            context,
            NotificationSettingsScreen(isProvider: isProvider),
          );
        },
      ),
      SettingsItem(
        icon: AppAssets.ASSETS_ICONS_SETTINGS_PRIVACY_POLICY_SVG.svg,
        title: 'Terms of Use Policy',
        onTap: () async {
          await AppGenUtil.launchUrlText(AppKeys.termsAndConditionsUrl);
        },
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
          final email = await getEmail();
          if (email != null) {
            await pushScreen(
              context,
              const ContactAdminScreen(
                issueType: AdminIssueType.complaint,
              ),
            );
          }
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
      body: RefreshIndicator(
        color: appColors.primary,
        onRefresh: _refreshProfile,
        child: ListView(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            bottom: 100.h,
          ),
          children: [
            10.verticalSpace,
            BlocListener<ProfileUpdateBloc, ProfileUpdateState>(
              listener: (context, state) async {
                if (state is Loading) {
                  showLoadingDialog(context);
                }
                if (state is ProfileUpdateSuccess) {
                  Navigator.pop(context);
                  await _refreshProfile();
                }

                if (state is ProfileUpdateError) {
                  Navigator.pop(context);
                  await showErrorSnackbar(context, state.message);
                }
              },
              child: ProfileSection(
                isProvider: isProvider,
                refreshProfile: _refreshProfile,
                onPickImage: () => _pickProfileImage(context),
              ),
            ),
            10.verticalSpace,
            if (isProvider)
              BlocBuilder<ProviderAuthBloc, ProviderAuthState>(
                builder: (context, state) {
                  if (state is ProviderProfileLoadedState) {
                    final status = state.user.activityStatus ?? 'UNKNOWN';

                    return GestureDetector(
                      onTap: () async {
                        await GeneralDialogs.showCustomDialog<void>(
                          context,
                          body: AccountStatusDialog(
                            onTap: () async {
                              Navigator.pop(context);
                              await pushScreen(
                                context,
                                const ContactAdminScreen(
                                  issueType: AdminIssueType.complaint,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GenText(
                            'Account Status: $status',
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
                    );
                  }

                  return const SizedBox.shrink();
                },
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
                          Divider(
                            height: 5,
                            color: appColors.textColor.shade100,
                          ),
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
                          Divider(
                            height: 5,
                            color: appColors.textColor.shade100,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            30.verticalSpace,
            GestureDetector(
              onTap: () async {
                await GeneralDialogs.showCustomDialog<void>(
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
      ),
    );
  }
}
