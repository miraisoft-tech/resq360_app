import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/models/payment_cards_model.dart';
import 'package:resq360/features/settings/screens/add_new_card_screen.dart';

class ManageCardsScreen extends StatelessWidget {
  const ManageCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final cards = [
      PaymentCardModel(
        brand: 'Visa',
        last4: '1234',
        expiry: '08/26',
        isDefault: true,
      ),
      PaymentCardModel(
        brand: 'Mastercard',
        last4: '4321',
        expiry: '06/26',
      ),
    ];

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        title: UrbText(
          'Manage Cards',
          size: 22,
          weight: FontWeight.w700,
          color: appColors.black,
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
                child: ListView.separated(
                  itemCount: cards.length,
                  separatorBuilder: (_, _) => 16.verticalSpace,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return _CardTile(card: card);
                  },
                ),
              ),
              20.verticalSpace,
              WideButton(
                label: 'Add New Card',
                onPressed: () async {
                  await pushScreen(context, const AddCardScreen());
                },
                backgroundColor: appColors.primary.shade500,
                textColor: appColors.whiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});

  final PaymentCardModel card;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      padding: pad(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.textColor.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GenText(
                card.brand == 'Visa' ? 'VISA' : 'MasterCard',
                color: card.brand == 'Visa' ? Colors.blue.shade700 : Colors.red,
                weight: FontWeight.w700,
                size: 16,
              ),
              if (card.isDefault)
                Container(
                  padding: pad(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: appColors.textColor.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: GenText(
                    'Default',
                    size: 12,
                    color: appColors.textColor.shade500,
                    weight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          8.verticalSpace,
          GenText(
            '****  ****  ****  ${card.last4}',
            size: 15,
            weight: FontWeight.w500,
            color: appColors.black,
          ),
          10.verticalSpace,
          GenText(
            'Exp: ${card.expiry}',
            size: 13,
            color: appColors.textColor.shade400,
          ),
          20.verticalSpace,
          Row(
            children: [
              Expanded(
                child: WideButton(
                  label: 'Delete',
                  backgroundColor: appColors.error.shade50,
                  textColor: appColors.error.shade600,
                  onPressed: () {},
                ),
              ),
              10.horizontalSpace,
              if (!card.isDefault)
                Expanded(
                  child: WideButton(
                    label: 'Set as Default',
                    backgroundColor: appColors.primary.shade500,
                    textColor: appColors.whiteColor,
                    onPressed: () {},
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
