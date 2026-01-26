import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';
import 'package:resq360/features/settings/data/bloc/bank_bloc/bloc/bank_bloc.dart';
import 'package:resq360/features/settings/data/models/banks_model.dart';
import 'package:resq360/features/settings/widgets/bank_account_tile.dart';

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

  List<BankModel> bankList = [];
  List<BankDetails> existingAccounts = [];

  String? _getBankCodeFromList(List<BankModel> banks, String? selected) {
    final bank = banks.firstWhere(
      (e) => e.name == selected,
      orElse: BankModel.new,
    );
    return bank.code?.toString();
  }

  bool _isFormValid() {
    return _selectBank.value != null &&
        nameController.text.trim().isNotEmpty &&
        accountNumberController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    context.read<BankBloc>().add(GetBanks());
    context.read<BankBloc>().add(BankFetchAccounts());
  }

  @override
  void dispose() {
    accountNumberController.dispose();
    nameController.dispose();
    cardNumberController.dispose();
    _selectBank.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final bloc = context.read<BankBloc>();
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
      body: BlocListener<BankBloc, BankState>(
        listener: (context, state) async {
          if (state is BankAccountAdded) {
            await showSuccessSnackbar(context, 'Account Added successfully');
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
          if (state is LocalBanksFetched) {
            setState(() {
              bankList = state.banks;
            });
          }
          if (state is BankAccountsFetched) {
            setState(() {
              existingAccounts = state.bankAcounts;
            });
          }

          if (state is CustomerDefaultBankAccountSetSuccesful) {
            context.read<BankBloc>().add(BankFetchAccounts());
            await showSuccessSnackbar(context, 'Default bank account updated');
          }
          if (state is BankAccountDeleted) {
              context.read<BankBloc>().add(BankFetchAccounts());
            await showSuccessSnackbar(context, 'Bank account deleted');
          }

          if (state is BankAccountUpdated) {
            await showSuccessSnackbar(
              context,
              'Bank details updated successfully',
            );
          }

          if (state is BankFailure) {
              context.read<BankBloc>().add(BankFetchAccounts());
            await showErrorSnackbar(
              context,
              state.error.isNotEmpty ? state.error : 'An error occurred',
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: pad(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      if (existingAccounts.isNotEmpty) ...[
                        GenText(
                          'Your Saved Bank Accounts',
                          weight: FontWeight.w600,
                          color: appColors.textColor.shade700,
                        ),
                        10.verticalSpace,

                        ...existingAccounts.map((acc) {
                          return Dismissible(
                            key: ValueKey(acc.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      backgroundColor: appColors.whiteColor,
                                      title: const Text('Delete Bank Account'),
                                      content: const Text(
                                        'Are you sure you want to delete this bank account?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: appColors.darkGreyColor,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
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
                              setState(() {
                                existingAccounts.removeWhere(
                                  (item) => item.id == acc.id,
                                );
                              });
                              context.read<BankBloc>().add(
                                DeleteBankAccount(bankAccountId: acc.id!),
                              );
                            },
                            child: BankAccountTile(bank: acc),
                          );
                        }),
                        20.verticalSpace,
                      ],

                      ValueListenableBuilder<String?>(
                        valueListenable: _selectBank,
                        builder: (context, value, _) {
                          return ObjectKDropDown(
                            label: 'Bank Name',
                            hintText: 'Select Bank',
                            maxHeight: 600,
                            value: _selectBank.value,
                            dropdownItems:
                                bankList.map((b) => b.name ?? '').toList(),
                            onChanged: (val) {
                              _selectBank.value = val;
                              setState(() {});
                            },
                            displayStringForOption: (String? name) {
                              return name ?? '';
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
                      // 16.verticalSpace,
                      // KFormField(
                      //   label: 'Card Number',
                      //   controller: cardNumberController,
                      //   hintText: '1234 5678 8123 4567',
                      //   keyboardType: TextInputType.number,
                      //   onChanged: (value) {
                      //     setState(() {});
                      //   },
                      // ),
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
                BlocBuilder<BankBloc, BankState>(
                  builder: (context, state) {
                    final isLoading = state is BankLoading;
                    var bankModels = <BankModel>[];
                    if (state is LocalBanksFetched) {
                      bankModels = state.banks;
                    }
                    return WideButton(
                      label: 'Add Bank Details',
                      loading: isLoading,
                      onPressed:
                          _isFormValid() && !isLoading
                              ? () {
                                final bankCode = _getBankCodeFromList(
                                  bankModels,
                                  _selectBank.value,
                                );
                                bloc.add(
                                  BankAddAccount(
                                    accountName: nameController.text.trim(),
                                    accountNumber:
                                        accountNumberController.text.trim(),
                                    bankName: _selectBank.value!,
                                    bankCode: bankCode ?? '',
                                    currency: 'NGN',
                                  ),
                                );
                              }
                              : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
