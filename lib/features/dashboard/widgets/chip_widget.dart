import 'package:resq360/__lib.dart';

class ChipWidget extends StatelessWidget {
  const ChipWidget({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: pad(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.lightGreyColor,
      ),
      child: GenText(
        label,
        size: 10,
        height: 16.5,
        color: colors.textColor.shade300,
        weight: FontWeight.w500,
      ),
    );
  }
}
