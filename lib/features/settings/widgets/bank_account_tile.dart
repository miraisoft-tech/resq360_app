import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';
import 'package:resq360/features/settings/data/bloc/bank_bloc/bloc/bank_bloc.dart';


class BankAccountTile extends StatelessWidget {
  const BankAccountTile({
    required this.bank, super.key,
  });

  final BankDetails bank;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return GestureDetector(
      // onTap: () async {
      //  await pushScreen(context, EditBankDetailScreen(bank: bank));
      // },
      child: Container(
        padding: pad(vertical: 12, horizontal: 12),
        margin: pad(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: appColors.lightGreyColor3),
          color: bank.isDefault ?? false
              ? appColors.primary.shade50
              : appColors.whiteColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(bank.bankName ?? '', weight: FontWeight.w600),
                4.verticalSpace,
                GenText('Acc No: ${bank.accountNumber}', size: 12),
              ],
            ),

            if (bank.isDefault == false) GestureDetector(
                    onTap: () {
                      context
                          .read<BankBloc>()
                          .add(BankSetDefaultAccount(bankAccountId: bank.id!));
                    },
                    child: GenText(
                      'Set Default',
                      size: 12,
                      color: appColors.primary,
                      weight: FontWeight.w600,
                    ),
                  ) else GenText(
                    'Default',
                    size: 12,
                    color: appColors.primary,
                    weight: FontWeight.w600,
                  ),
          ],
        ),
      ),
    );
  }
}
