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
      decoration: BoxDecoration(
        border: Border.all(color: colors.lightGreyColor2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.hardEdge,
            child: icon,
          ),
          6.verticalSpace,
          GenText(
            label,
            color: colors.black,
            size: 12,
            weight: FontWeight.w400,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
