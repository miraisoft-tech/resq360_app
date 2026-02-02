import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';

class ProviderAccountProgress extends StatelessWidget {
  const ProviderAccountProgress({required this.provider, super.key,});
final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
final progress = calculateProviderProgress(provider);
    final percentText = (progress * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenText(
          'Complete Your Account Setup',
          weight: FontWeight.w500,
          color: colors.black,
        ),
        12.verticalSpace,
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colors.textColor.shade100,
          valueColor: AlwaysStoppedAnimation(colors.primary.shade500),
          minHeight: 6,
          borderRadius: BorderRadius.circular(13.r),
        ),
        8.verticalSpace,
        Align(
          alignment: Alignment.centerRight,
          child: GenText(
            '$percentText% complete',
            size: 12,
            color: colors.textColor.shade500,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
double calculateProviderProgress(ProviderModel provider) {
  const totalSteps = 5;
  var completed = 0;

  if (provider.profileImage != null &&
      provider.profileImage!.trim().isNotEmpty) {
    completed++;
  }

  if (provider.providerServices?.isNotEmpty ?? false) {
    completed++;
  }

  if (provider.description != null &&
      provider.description!.trim().isNotEmpty) {
    completed++;
  }

  if (provider.address != null) {
    completed++;
  }

  if (provider.openingHours != null &&
      provider.closingHours != null) {
    completed++;
  }

  return completed / totalSteps;
}
