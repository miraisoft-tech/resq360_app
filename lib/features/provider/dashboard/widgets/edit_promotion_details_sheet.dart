import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';

class EditPromotionSheet extends StatefulWidget {
  const EditPromotionSheet({required this.promotion, super.key});
  final Advertisement promotion;

  @override
  State<EditPromotionSheet> createState() => _EditPromotionSheetState();
}

class _EditPromotionSheetState extends State<EditPromotionSheet> {
  late TextEditingController _descriptionCtrl;
  late TextEditingController _discountCtrl;

  @override
  void initState() {
    super.initState();
    _descriptionCtrl = TextEditingController(
      text: widget.promotion.description ?? '',
    );
    _discountCtrl = TextEditingController(
      text: widget.promotion.budget?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    Navigator.pop(context);

    context.read<PromotionBloc>().add(
      UpdatePromotion(
        id: widget.promotion.id!,
        description: _descriptionCtrl.text.trim(),
        discountPercentage: int.tryParse(_discountCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 100,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GenText('Edit Promotion', size: 18, weight: FontWeight.w700),
          20.verticalSpace,
          KFormField(
            label: 'Description',
            controller: _descriptionCtrl,
            maxLines: 4,
            hintText: '',
          ),
          16.verticalSpace,
          KFormField(
            label: 'Discount (%)',
            controller: _discountCtrl,
            keyboardType: TextInputType.number,
            hintText: '',
          ),
          24.verticalSpace,
          WideButton(label: 'Save Changes', onPressed: _saveChanges),
        ],
      ),
    );
  }
}
