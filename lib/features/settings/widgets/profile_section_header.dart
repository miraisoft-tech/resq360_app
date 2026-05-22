import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    required this.isProvider,
    required this.refreshProfile,
    required this.onPickImage,
    super.key,
  });

  final bool isProvider;
  final void Function()? refreshProfile;
  final void Function() onPickImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
            return Center(
              child: CircularProgressIndicator(color: colors.primary.shade500),
            );
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
          return Center(
            child: CircularProgressIndicator(color: colors.primary.shade500),
          );
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
        GestureDetector(
          onTap: onPickImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              PictureWidget(image: imageUrl, radius: 50),
              Positioned(
                bottom: 5,
                right: 5,
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
