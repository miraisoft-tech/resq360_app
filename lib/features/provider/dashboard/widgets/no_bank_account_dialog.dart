import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/wallet_bloc/wallet_bloc.dart';
import 'package:resq360/core/bloc/wallet_transaction_bloc/wallet_transaction_bloc.dart';
import 'package:resq360/features/settings/screens/add_bank_details.dart';

class NoBankAccountDialog extends StatelessWidget {
  const NoBankAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 290.h, bottom: 250.h),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: pad(horizontal: 20),
          padding: pad(horizontal: 25, vertical: 25),
          decoration: BoxDecoration(
            color: appColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UrbText(
                'No Bank Account Found',
                size: 19,
                height: 26.5,
                weight: FontWeight.w700,
                color: appColors.black,
                textAlign: TextAlign.center,
              ),
              10.verticalSpace,
              GenText(
                'You need to add a bank account before making a withdrawal.',
                textAlign: TextAlign.center,
                color: appColors.textColor.shade400,
              ),
              40.verticalSpace,
              WideButton(
                label: 'Add Bank Account',
                onPressed: () async {
                  Navigator.pop(context);
                  await pushScreen(context, const AddBankDetailsScreen());
                },
              ),
              20.verticalSpace,
              WideButton(
                label: 'Back',
                backgroundColor: appColors.neutral.shade100,
                textColor: appColors.black,
                onPressed: () {
                  context.read<WalletBloc>().add(FetchWalletInfo());
                  context.read<WalletTransactionsBloc>().add(
                    FetchWalletTransactions(),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
