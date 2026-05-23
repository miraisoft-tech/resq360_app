import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';

class PromotionOptionsSheet extends StatelessWidget {
  const PromotionOptionsSheet({
    required this.promotion,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final Advertisement promotion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: pad(both: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colors.neutral.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          24.verticalSpace,
          ListTile(
            leading: Icon(Icons.edit_outlined, color: colors.primary.shade500),
            title: const Text('Edit Promotion'),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: colors.error.shade600),
            title: const Text('Delete Promotion'),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          12.verticalSpace,
        ],
      ),
    );
  }
}
