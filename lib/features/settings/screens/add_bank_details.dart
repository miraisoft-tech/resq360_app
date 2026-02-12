import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';
import 'package:resq360/features/provider/dashboard/widgets/saved_bank_accounts_section.dart';
import 'package:resq360/features/settings/data/bloc/bank_bloc/bloc/bank_bloc.dart';
import 'package:resq360/features/settings/data/models/banks_model.dart';

class AddBankDetailsScreen extends StatefulWidget {
  const AddBankDetailsScreen({super.key});

  @override
  State<AddBankDetailsScreen> createState() => _AddBankDetailsScreenState();
}

class _AddBankDetailsScreenState extends State<AddBankDetailsScreen> {
  final accountNumberController = TextEditingController();
  final nameController = TextEditingController();
  final cardNumberController = TextEditingController();

  String? selectedAccountName; // what user picked
  String? suggestedAccountName;
  bool isValidating = false;

  final ValueNotifier<String?> _selectBank = ValueNotifier(null);

  List<BankModel> bankList = [];
  List<BankDetails> existingAccounts = [];

  String? _getBankCodeFromList(List<BankModel> banks, String? selected) {
    try {
      return banks.firstWhere((e) => e.name == selected).code;
    } on Exception catch (_) {
      return null;
    }
  }

  bool _isFormValid() {
    return _selectBank.value != null &&
        accountNumberController.text.trim().length == 10 &&
        nameController.text.trim().isNotEmpty;
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
            await showSuccessSnackbar(context, 'Default bank account updated');
          }
          if (state is BankAccountDeleted) {
            await showSuccessSnackbar(context, 'Bank account deleted');
          }

          if (state is BankAccountUpdated) {
            await showSuccessSnackbar(
              context,
              'Bank details updated successfully',
            );
          }

          if (state is BankAccountValidating) {
            setState(() {
              isValidating = true;
            });
          }

          if (state is BankAccountValidated) {
            setState(() {
              isValidating = false;
              suggestedAccountName = state.accountName;
            });
          }
          if (state is BankFailure) {
            setState(() {
              isValidating = false;
              suggestedAccountName = null;
              nameController.clear();
            });
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
                      10.verticalSpace,
                      const SavedBankAccountsSection(
                        disableNavigation: true,
                      ),
                      20.verticalSpace,
                      ValueListenableBuilder<String?>(
                        valueListenable: _selectBank,
                        builder: (context, value, _) {
                          return KSearchDropDown(
                            label: 'Bank Name',
                            hintText: 'Select Bank',
                            value: _selectBank.value,
                            items: bankList.map((b) => b.name ?? '').toList(),
                            onChanged: (value) {
                              setState(() {});
                              return _selectBank.value = value;
                            },
                          );
                        },
                      ),

                      16.verticalSpace,

                      KFormField(
                        label: 'Account Number',
                        controller: accountNumberController,
                        hintText: 'Enter Account Number',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            suggestedAccountName =
                                null; // reset suggestion if user edits
                            selectedAccountName = null;
                            nameController.clear();
                          });

                          // Nigerian account numbers are 10 digits
                          if (value?.trim().length == 10 &&
                              _selectBank.value != null) {
                            final bankCode = _getBankCodeFromList(
                              bankList,
                              _selectBank.value,
                            );

                            if (bankCode != null && value != null) {
                              context.read<BankBloc>().add(
                                BankValidateAccount(
                                  accountNumber: value,
                                  bankCode: bankCode,
                                ),
                              );
                            }
                          }
                        },
                      ),

                      16.verticalSpace,

                      if (isValidating) ...[
                        8.verticalSpace,
                        LinearProgressIndicator(color: appColors.primary.shade200,),
                         8.verticalSpace,
                      ],

                      if (suggestedAccountName != null) ...[
                        8.verticalSpace,
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedAccountName = suggestedAccountName;
                                nameController.text = suggestedAccountName!;

                                suggestedAccountName = null;
                                isValidating = false;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: pad(both: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: appColors.whiteColor,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outline),
                                  8.horizontalSpace,
                                  Expanded(
                                    child: GenText(
                                      suggestedAccountName!,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

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
                      if (selectedAccountName != null) ...[
                        16.verticalSpace,
                        Container(
                          padding: pad(vertical: 12, horizontal: 12),
                          margin: pad(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: appColors.lightGreyColor3,
                            ),
                            color: appColors.primary.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GenText(
                                    'Account Name',
                                    size: 12,
                                    color: appColors.textColor.shade400,
                                  ),
                                  4.verticalSpace,
                                  GenText(
                                    selectedAccountName!,
                                    weight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              const Icon(Icons.person_outline),
                            ],
                          ),
                        ),
                      ],

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
                    return WideButton(
                      label: 'Add Bank Details',
                      loading: isLoading,
                      onPressed:
                          _isFormValid() && !isLoading
                              ? () async {
                                final bankCode = _getBankCodeFromList(
                                  bankList,
                                  _selectBank.value,
                                );

                                if (bankCode == null) {
                                  await showErrorSnackbar(
                                    context,
                                    'Bank code not found. Please reselect the bank.',
                                  );
                                  return;
                                }
                                context.read<BankBloc>().add(
                                  BankAddAccount(
                                    accountName: nameController.text.trim(),
                                    accountNumber:
                                        accountNumberController.text.trim(),
                                    bankName: _selectBank.value!,
                                    bankCode: bankCode,
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
