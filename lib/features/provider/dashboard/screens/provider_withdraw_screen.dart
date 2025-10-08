import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/static_colors.dart';

class ProviderWithdrawScreen extends StatefulWidget {
  const ProviderWithdrawScreen({super.key});

  @override
  State<ProviderWithdrawScreen> createState() => _ProviderWithdrawScreenState();
}

class _ProviderWithdrawScreenState extends State<ProviderWithdrawScreen> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController accountNumberController;

  final ValueNotifier<String?> _selectBank = ValueNotifier(null);
  final List<String> banks = [
    'GTB',
    'Access Bank',
    'Zenith Bank',
    'First Bank',
    'UBA',
  ];

  final List<String> values = [
    '₦ 5,000',
    '₦ 10,000',
    '₦ 20,000',
    '₦ 50,000',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    amountController = TextEditingController();
    accountNumberController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    amountController.dispose();
    accountNumberController.dispose();
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
          'Withdraw Funds',
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
              Container(
                width: double.infinity,
                padding: pad(horizontal: 10, vertical: 12),
                color: AppColors.grey,
                child: Col(
                  children: [
                    GenText(
                      'Available Balance',
                      size: 12,
                      height: 16.5,
                      weight: FontWeight.w400,
                      color: appColors.neutral.shade400,
                    ),
                    5.verticalSpace,
                    UrbText(
                      '₦48,000',
                      size: 18,
                      height: 24.5,
                      weight: FontWeight.w700,
                      color: appColors.textColor.shade800,
                    ),
                  ],
                ),
              ),
              20.verticalSpace,
              KFormField(
                label: 'Enter Amount',
                hintText: '₦ 0.00',
                controller: amountController,
                keyboardType: TextInputType.number,
                onChanged: (a) {
                  setState(() {});
                },
              ),
              16.verticalSpace,
              Wrap(
                spacing: 10.w,
                children: [
                  ...values.map(
                    (value) {
                      return GestureDetector(
                        onTap: () => amountController.text = value,
                        child: Container(
                          padding: pad(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  amountController.text == value
                                      ? appColors.primary.shade300
                                      : appColors.neutral.shade200,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),

                          child: GenText(
                            value,
                            size: 12,
                            height: 14.5,
                            weight: FontWeight.w400,
                            color: appColors.textColor.shade800,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              16.verticalSpace,
              KFormField(
                label: 'Account Number',
                hintText: 'Enter Account Number',
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                onChanged: (a) {
                  setState(() {});
                },
              ),
              16.verticalSpace,
              ValueListenableBuilder<String?>(
                valueListenable: _selectBank,
                builder: (
                  BuildContext context,
                  String? value,
                  Widget? child,
                ) {
                  return ObjectKDropDown(
                    label: 'Bank Name',
                    hintText: 'Select Bank ',
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
              20.verticalSpace,
              Container(
                padding: pad(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: appColors.error.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),

                child: GenText(
                  '''Your withdrawal request will be processed within 1-3 business days. You'll receive a notification once the funds are transferred.''',
                  height: 16.5,
                  weight: FontWeight.w400,
                  color: appColors.black,
                ),
              ),
              const Spacer(),
              WideButton(
                label: 'Withdraw',
                onPressed: () async {
                  await GeneralDialogs.showCustomDialog(
                    context,
                    body: const WithdrawalCompletedScreen(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WithdrawalCompletedScreen extends StatelessWidget {
  const WithdrawalCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 165.h, bottom: 165.h),
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
              AppAssets.ASSETS_IMAGES_PASSWORD_RESET_SUCCESS_PNG.imageAsset(),
              4.verticalSpace,
              UrbText(
                'Withdrawal Request Submitted',
                size: 20,
                height: 32.5,
                weight: FontWeight.w700,
                color: appColors.black,
                textAlign: TextAlign.center,
              ),
              4.verticalSpace,
              GenText(
                'Your withdrawal request has been received successfully.',
                height: 24.5,
                color: appColors.textColor.shade300,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              30.verticalSpace,
              GenText(
                'Withdrawal Amount',
                height: 24.5,
                color: appColors.textColor.shade300,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              5.verticalSpace,
              UrbText(
                '₦10,000',
                size: 18,
                height: 28.5,
                color: appColors.black,
                weight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
              20.verticalSpace,
              Container(
                padding: pad(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: appColors.error.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),

                child: GenText(
                  '''Your withdrawal request will be processed within 1-3 business days. You'll receive a notification once the funds are transferred.''',
                  size: 12,
                  height: 16.5,
                  weight: FontWeight.w400,
                  color: appColors.black,
                ),
              ),
              20.verticalSpace,
              WideButton(
                heigth: 45,
                label: 'Go to Wallet',
                backgroundColor: appColors.primary.shade500,
                textColor: appColors.whiteColor,
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
