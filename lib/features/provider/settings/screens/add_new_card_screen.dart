import 'package:resq360/__lib.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final cardNumberController = TextEditingController();
  final cardHolderController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        title: const GenText(
          'Manage Cards',
          size: 18,
          weight: FontWeight.w700,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KFormField(
                label: 'Card Number',
                controller: cardNumberController,
                hintText: 'Enter Your Card Number',
                keyboardType: TextInputType.number,
              ),
              16.verticalSpace,
              KFormField(
                label: 'Card Holder Name',
                controller: cardHolderController,
                hintText: 'Enter Card Holder Name',
                keyboardType: TextInputType.number,
              ),
              16.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: KFormField(
                      label: 'Expiry',
                      controller: cardHolderController,
                      hintText: 'MM/YY',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: KFormField(
                      label: 'CVV',
                      controller: cardHolderController,
                      hintText: '123',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
                    'Your card details are encrypted and securely stored.',
                    size: 12,
                    color: appColors.textColor.shade400,
                  ),
                ],
              ),
              const Spacer(),
              WideButton(
                label: 'Save Card',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
