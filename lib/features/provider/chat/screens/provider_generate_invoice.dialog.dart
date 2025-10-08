import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/chat/screens/provider_invoice_confirm.dart';

class ProviderGenerateInvoiceDialog extends StatefulWidget {
  const ProviderGenerateInvoiceDialog({super.key});

  @override
  State<ProviderGenerateInvoiceDialog> createState() =>
      _ProviderGenerateInvoiceDialogState();
}

class _ProviderGenerateInvoiceDialogState
    extends State<ProviderGenerateInvoiceDialog> {
  final ValueNotifier<String?> _selectType = ValueNotifier(null);

  final List<String> categoryTypes = [
    'Towing',
    'Cleaning',
    'Mechanic',
    'Electrician',
  ];

  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 170.h, bottom: 90.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UrbText(
                    'Generate Invoice',
                    size: 22,
                    height: 32.5,
                    weight: FontWeight.w700,
                    color: appColors.black,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: appColors.textColor.shade400,
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<String?>(
                valueListenable: _selectType,
                builder: (
                  BuildContext context,
                  String? value,
                  Widget? child,
                ) {
                  return ObjectKDropDown(
                    label: 'Service Category',
                    hintText: 'select service category',
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
              14.verticalSpace,
              KFormField(
                label: 'Location',
                hintText: 'Enter your location',
                controller: locationController,
                keyboardType: TextInputType.text,
              ),
              14.verticalSpace,
              KFormField(
                label: 'Price',
                hintText: 'Enter the price',
                controller: priceController,
                keyboardType: TextInputType.number,
              ),
              14.verticalSpace,
              KFormField(
                label: 'Service Description(Optional)',
                hintText: 'Type service description here...',
                controller: serviceController,
                keyboardType: TextInputType.text,
                maxLines: 8,
                minLines: 6,
              ),
              24.verticalSpace,
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
                      label: 'Generate Invoice',
                      backgroundColor: appColors.primary.shade500,
                      textColor: appColors.whiteColor,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await GeneralDialogs.showCustomDialog(
                          context,
                          body: const ProviderInvoiceConfirmDialog(),
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
