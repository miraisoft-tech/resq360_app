import 'package:resq360/__lib.dart';

class AddBankDetailsScreen extends StatefulWidget {
  const AddBankDetailsScreen({super.key});

  @override
  State<AddBankDetailsScreen> createState() => _AddBankDetailsScreenState();
}

class _AddBankDetailsScreenState extends State<AddBankDetailsScreen> {
  final accountNumberController = TextEditingController();
  final nameController = TextEditingController();
  final cardNumberController = TextEditingController();

  final ValueNotifier<String?> _selectBank = ValueNotifier(null);

  final List<String> banks = ['GTBank', 'Access Bank'];
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const GenText(
          'Add Bank Details',
          size: 18,
          weight: FontWeight.w700,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        foregroundColor: appColors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: _selectBank,
                      builder: (
                        BuildContext context,
                        String? value,
                        Widget? child,
                      ) {
                        return ObjectKDropDown(
                          label: 'Bank Name',
                          hintText: 'Enter Your Bank Name',
                          displayStringForOption: (String? id) => id ?? '',
                          showPrefix: false,
                          value: value,
                          dropdownItems: banks,
                          onChanged: (value) {
                            setState(() {
                              _selectBank.value = value;
                            });
                          },
                        );
                      },
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Account Name',
                      controller: nameController,
                      hintText: 'Enter Your Account Name',
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Account Number',
                      controller: accountNumberController,
                      hintText: 'Enter Account Number',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    16.verticalSpace,
                    KFormField(
                      label: 'Card Number',
                      controller: cardNumberController,
                      hintText: '1234 5678 8123 4567',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    20.verticalSpace,
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: appColors.textColor.shade400,
                        ),
                        6.horizontalSpace,
                        GenText(
                          'Your bank details are encrypted and securely stored.',
                          size: 12,
                          color: appColors.textColor.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              WideButton(
                label: 'Add Bank Details',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
