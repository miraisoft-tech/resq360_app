import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/bloc/bank_bloc/bloc/bank_bloc.dart';
import 'package:resq360/features/settings/screens/add_bank_details.dart';
import 'package:resq360/features/settings/widgets/bank_account_tile.dart';

class SavedBankAccountsSection extends StatefulWidget {
  const SavedBankAccountsSection({super.key});

  @override
  State<SavedBankAccountsSection> createState() =>
      _SavedBankAccountsSectionState();
}

class _SavedBankAccountsSectionState extends State<SavedBankAccountsSection> {
  @override
  void initState() {
    super.initState();
    context.read<BankBloc>().add(BankFetchAccounts());
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, state) {
        if (state is BankLoading) {
          return Column(
            children: List.generate(
              3,
              (_) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: appColors.darkGreyColor.withAlpha(35),
                ),
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          );
        }

        if (state is BankAccountsFetched && state.bankAcounts.isEmpty) {
          return Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await pushScreen(context, const AddBankDetailsScreen());
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: appColors.textColor.shade500),
                      children: [
                        TextSpan(
                          text: 'No Saved Bank Accounts',
                          style: TextStyle(
                            fontFamily: 'inter',
                            fontSize: 15.sp,
                            color: appColors.textColor.shade500,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              10.verticalSpace,
            ],
          );
        }
        if (state is BankAccountsFetched && state.bankAcounts.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenText(
                'Your Saved Bank Accounts',
                color: appColors.textColor.shade700,
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 10),

              ...state.bankAcounts.map(
                (acc) => Dismissible(
                  key: ValueKey(acc.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: appColors.error.shade500,
                    ),
                    child: Icon(Icons.delete, color: appColors.whiteColor),
                  ),
                  confirmDismiss: (_) async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            backgroundColor: appColors.whiteColor,
                            title: GenText(
                              'Delete Bank Account',
                              color: appColors.textColor.shade700,
                              weight: FontWeight.w600,
                            ),
                            content: GenText(
                              'Are you sure you want to delete this bank account?',
                              color: appColors.textColor.shade700,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: appColors.darkGreyColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: appColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );
                    return confirmed ?? false;
                  },
                  onDismissed: (_) {
                    context.read<BankBloc>().add(
                      DeleteBankAccount(bankAccountId: acc.id!),
                    );
                  },
                  child: BankAccountTile(bank: acc),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
