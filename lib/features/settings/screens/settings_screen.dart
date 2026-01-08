import 'dart:io';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/settings/data/bloc/update_profile_bloc.dart/profile_update_bloc.dart';
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? pickedImage;

  Future<void> _refreshProfile() async {
    if (dashboardViewModel.userType == UserType.provider) {
      context.read<ProviderAuthBloc>().add(const ProvidergetUserProfile());
    } else {
      context.read<CustomerAuthBloc>().add(const CustomergetUserProfile());
    }
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    final image = await AppFilePicker.pickImage();
    if (image == null) return;

    pickedImage = image;

    if (dashboardViewModel.userType == UserType.provider) {
      context.read<ProfileUpdateBloc>().add(
        UpdateProfileImageEvent(
          filePath: image.path,
        ),
      );
    } else {
      context.read<ProfileUpdateBloc>().add(
        UpdateProfileImageEvent(
          filePath: image.path,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dashboardViewModel.userType == UserType.provider) {
        context.read<ProviderAuthBloc>().add(const ProvidergetUserProfile());
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
          final email = await getEmail();
          if (email != null) {
            await pushScreen(context, ContactAdminScreen(email: email));
          }
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
          final email = await getEmail();
          if (email != null) {
            await pushScreen(context, ContactAdminScreen(email: email));
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
                if (state is ProfileUpdateLoading) {
                  await showLoadingDialog(context);
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
              child: _ProfileSection(
                isProvider: isProvider,
                refreshProfile: _refreshProfile,
                onPickImage: () => _pickProfileImage(context),
              ),
            ),
            10.verticalSpace,
            if (isProvider)
              BlocBuilder<ProviderAuthBloc, ProviderAuthState>(
                builder: (context, state) {
                  if (state is ProviderProfileLoadedState) {}
                  if (state is ProviderProfileLoadedState) {
                    final status = state.user.activityStatus ?? 'UNKNOWN';

                    return GestureDetector(
                      onTap: () async {
                        await GeneralDialogs.showCustomDialog<void>(
                          context,
                          body: AccountStatusDialog(
                            onTap: () async {
                              final email = await getEmail();

                              Navigator.pop(context);
                              await pushScreen(
                                context,
                                ContactAdminScreen(
                                  email: email ?? '',
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

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.isProvider,
    required this.refreshProfile,
    required this.onPickImage,
  });

  final bool isProvider;
  final void Function()? refreshProfile;
  final void Function() onPickImage;

  @override
  Widget build(BuildContext context) {
    if (isProvider) {
      return BlocBuilder<ProviderAuthBloc, ProviderAuthState>(
        builder: (context, state) {
          if (state is ProviderProfileLoadedState) {
            final fullName = state.user.fullName?.trim();
            final name =
                (fullName != null && fullName.isNotEmpty)
                    ? fullName.capitalize
                    : 'Provider User';

            return ProfileView(
              name: name.capitalize,
              imageUrl: state.user.profileImage,
              onPickImage: onPickImage,
            );
          }

          if (state is ProviderAuthLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return const SizedBox.shrink();
        },
      );
    }

    return BlocBuilder<CustomerAuthBloc, CustomerAuthState>(
      builder: (context, state) {
        if (state is CustomerProfileLoaded) {
          final fullName = state.user.fullName?.trim();
          final name =
              (fullName != null && fullName.isNotEmpty)
                  ? fullName.capitalize
                  : 'Customer User';

          return ProfileView(
            name: name.capitalize,
            imageUrl: state.user.profileImage,
            onPickImage: onPickImage,
          );
        }

        if (state is CustomerAuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CustomerAuthFailure) {
          return ErrorMessageAndButton(
            error: state.error,
            onPressed: refreshProfile,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({
    required this.name,
    required this.imageUrl,
    required this.onPickImage,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final VoidCallback onPickImage;

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
              backgroundImage: NetworkImage(
                imageUrl ?? 'https://randomuser.me/api/portraits/men/30.jpg',
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: GestureDetector(
                onTap: onPickImage,
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
            ),
          ],
        ),
        15.verticalSpace,
        UrbText(
          name,
          size: 16,
          weight: FontWeight.w700,
          color: appColors.black,
        ),
      ],
    );
  }
}
