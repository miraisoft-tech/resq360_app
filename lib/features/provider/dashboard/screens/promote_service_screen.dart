import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/dashboard/models/duration.enum.dart';
import 'package:resq360/features/provider/dashboard/screens/promote_service_review.dart';

class PromoteServiceScreen extends StatefulWidget {
  const PromoteServiceScreen({super.key});

  @override
  State<PromoteServiceScreen> createState() => _PromoteServiceScreenState();
}

class _PromoteServiceScreenState extends State<PromoteServiceScreen> {
  late TextEditingController promoController;
  late TextEditingController discountController;

  final ValueNotifier<PromotionDuration?> _selectDuration =
      ValueNotifier<PromotionDuration?>(null);

  @override
  void initState() {
    super.initState();
    promoController = TextEditingController();
    discountController = TextEditingController();
  }

  @override
  void dispose() {
    promoController.dispose();
    discountController.dispose();
    _selectDuration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final categoryDurations = PromotionDuration.values.toList();
    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => pop(context),
          icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
        ),
        centerTitle: true,
        title: UrbText(
          'Promote Your Page',
          size: 22,
          height: 32.5,
          weight: FontWeight.w700,
          color: appColors.textColor.shade800,
        ),
        actions: const [SizedBox(width: 40)],
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    GenText(
                      'Promotion Details',
                      size: 16,
                      height: 24.5,
                      weight: FontWeight.w700,
                      color: appColors.textColor.shade800,
                    ),
                    20.verticalSpace,
                    KFormField(
                      label: 'Promotion Description',
                      hintText: 'Get 30% off every towing service today.',
                      controller: promoController,
                      keyboardType: TextInputType.text,
                      maxLines: 10,
                      minLines: 8,
                      onChanged: (a) {
                        setState(() {});
                      },
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Discount Rate',
                      hintText: 'Enter a Discount Rate',
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (a) {
                        setState(() {});
                      },
                    ),
                    16.verticalSpace,
                    ValueListenableBuilder<PromotionDuration?>(
                      valueListenable: _selectDuration,
                      builder: (context, value, child) {
                        return ObjectKDropDown<PromotionDuration>(
                          label: 'Promotion Duration',
                          hintText: 'Select the Promotion Duration',
                          showPrefix: false,

                          displayStringForOption:
                              (PromotionDuration d) => d.label,

                          value: value,
                          dropdownItems: categoryDurations,

                          onChanged: (selected) {
                            _selectDuration.value = selected;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: WideButton(
                      label: 'Cancel',
                      backgroundColor: appColors.primary.shade50,
                      textColor: appColors.primary.shade500,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: WideButton(
                      label: 'Continue',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        final selected = _selectDuration.value;
                        final discount = int.tryParse(
                          discountController.text.trim(),
                        );

                        if (promoController.text.trim().isEmpty) {
                          await showErrorSnackbar(
                            context,
                            'Please enter a promotion description',
                          );
                          return;
                        }

                        if (discount == null) {
                          await showErrorSnackbar(
                            context,
                            'Please enter a valid discount rate',
                          );
                          return;
                        }

                        if (selected == null) {
                          await showErrorSnackbar(
                            context,
                            'Please select the promotion duration',
                          );
                          return;
                        }

                        await pushScreen(
                          context,
                          PromoteServiceReviewScreen(
                            promotionDescription: promoController.text.trim(),
                            discount: discount.toString(),
                            duration: selected,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
