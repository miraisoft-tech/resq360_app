import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/dashboard/screens/promote_service_review.dart';

class PromoteServiceScreen extends StatefulWidget {
  const PromoteServiceScreen({super.key});

  @override
  State<PromoteServiceScreen> createState() => _PromoteServiceScreenState();
}

class _PromoteServiceScreenState extends State<PromoteServiceScreen> {
  late TextEditingController nameController;
  late TextEditingController promoController;
  late TextEditingController discountController;

  final ValueNotifier<String?> _selectType = ValueNotifier(null);
  final List<String> categoryTypes = [
    '24 hours',
    '48 hours',
    '72 hours',
    '1 week',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    promoController = TextEditingController();
    discountController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    promoController.dispose();
    discountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
          child: Col(
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
                keyboardType: TextInputType.text,
                onChanged: (a) {
                  setState(() {});
                },
              ),
              16.verticalSpace,
              ValueListenableBuilder<String?>(
                valueListenable: _selectType,
                builder: (
                  BuildContext context,
                  String? value,
                  Widget? child,
                ) {
                  return ObjectKDropDown(
                    label: 'Promotion Duration',
                    hintText: 'Select the Promotion Duration ',
                    displayStringForOption: (String? id) => id ?? '',
                    showPrefix: false,
                    value: value,
                    dropdownItems: categoryTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectType.value = value;
                      });
                    },
                  );
                },
              ),
              const Spacer(),
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
                        await pushScreen(
                          context,
                          const PromoteServiceReviewScreen(),
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
