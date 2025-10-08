import 'package:resq360/__lib.dart';

class ProviderStatsCard extends StatelessWidget {
  const ProviderStatsCard({
    required this.icon,
    required this.title,
    required this.value,
    super.key,
  });
  final String icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Container(
        padding: pad(horizontal: 45, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: colors.textColor.shade100),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            icon.svg,
            8.verticalSpace,
            GenText(
              title,
              size: 10,
              height: 20.5,
              color: colors.textColor.shade500,
              weight: FontWeight.w400,
            ),
            8.verticalSpace,
            GenText(
              value,
              size: 18,
              height: 28.5,
              color: colors.black,
              weight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}
