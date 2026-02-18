import 'package:resq360/__lib.dart';

class PromotionMetricColumn extends StatelessWidget {

  const PromotionMetricColumn({
    required this.icon,
    required this.label,
    required this.value,
    super.key,

  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Icon(icon, size: 20, color: colors.primary.shade500),
        6.verticalSpace,
        GenText(
          value,
          size: 18,
          weight: FontWeight.w700,
          color: colors.black,
        ),
        4.verticalSpace,
        GenText(
          label,
          size: 11,
          color: colors.neutral.shade600,
        ),
      ],
    );
  }
}
