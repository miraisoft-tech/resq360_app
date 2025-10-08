import 'package:resq360/__lib.dart';

class ProviderAccountProgress extends StatelessWidget {
  const ProviderAccountProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
          value: 0.75,
          backgroundColor: colors.textColor.shade100,
          valueColor: AlwaysStoppedAnimation(colors.primary.shade500),
          minHeight: 6,
          borderRadius: BorderRadius.circular(13.r),
        ),
        8.verticalSpace,
        Align(
          alignment: Alignment.centerRight,
          child: GenText(
            '75% complete',
            size: 12,
            color: colors.textColor.shade500,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
