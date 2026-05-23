import 'package:resq360/__lib.dart';

class AddFunds extends StatelessWidget {
  const AddFunds({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: pad(vertical: 5, horizontal: 15),
        decoration: BoxDecoration(
          color: appColors.whiteColor,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: appColors.primary.shade500),
            GenText(
              'Add Funds',
              size: 12,
              height: 14,
              color: appColors.primary.shade500,
              weight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
