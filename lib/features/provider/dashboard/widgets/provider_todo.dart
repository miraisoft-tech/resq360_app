import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/settings/screens/settings_screen.dart';
import 'package:resq360/features/settings/screens/update_service_screen.dart';
class ToDoSection extends StatelessWidget {
  const ToDoSection({required this.provider, super.key});

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final descriptionMissing =
        provider.description == null || provider.description!.trim().isEmpty;

    final servicesMissing =
        provider.providerServices == null || provider.providerServices!.isEmpty;

    final profileImageMissing =
        provider.profileImage == null || provider.profileImage!.trim().isEmpty;

    final todoItems = <Widget>[];

    if (descriptionMissing || servicesMissing) {
      todoItems.addAll([
        GenText(
          '⚠️ Add your service description and update your service type so clients can find you faster.',
          height: 24.5,
          weight: FontWeight.w400,
          color: colors.black,
        ),

        GestureDetector(
          onTap: () async {
            await pushScreen(context, const UpdateServiceScreen());
          },
          child: GenText(
            'Update Service Info',
            height: 24.5,
            weight: FontWeight.w400,
            color: colors.primary.shade600,
          ),
        ),

        10.verticalSpace,
      ]);
    }

    if (profileImageMissing) {
      todoItems.addAll([
        GenText(
          '⚠️ Upload your profile photo.',
          height: 24.5,
          weight: FontWeight.w400,
          color: colors.black,
        ),

        GestureDetector(
          onTap: () async {
            await pushScreen(context, const SettingsScreen());
          },
          child: GenText(
            'Upload Photo',
            height: 24.5,
            weight: FontWeight.w400,
            color: colors.primary.shade600,
          ),
        ),
      ]);
    }

    if (todoItems.isEmpty) return const SizedBox.shrink();

    return Col(
      children: [
        UrbText(
          'To-Do',
          size: 18,
          weight: FontWeight.w700,
          color: colors.black,
        ),
        20.verticalSpace,
        Container(
          padding: pad(horizontal: 14, vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: colors.textColor.shade100),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: todoItems,
          ),
        ),
      ],
    );
  }
}
