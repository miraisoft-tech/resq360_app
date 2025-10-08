import 'package:resq360/__lib.dart';

class IssueRadio extends StatelessWidget {
  const IssueRadio({
    required this.label,
    required this.selected,
    this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: pad(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: appColors.primary.shade500,
            ),
            12.horizontalSpace,
            GenText(
              label,
              size: 15,
              color: appColors.textColor.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
