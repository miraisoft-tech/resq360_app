import 'package:resq360/__lib.dart';

class ServiceCategoryWidget extends StatelessWidget {
  const ServiceCategoryWidget({
    required this.icon,
    required this.label,
    super.key,
  });
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 100.w,
      padding: pad(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: colors.lightGreyColor2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          6.verticalSpace,
          GenText(
            label,
            color: colors.black,
            size: 12,
            weight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
