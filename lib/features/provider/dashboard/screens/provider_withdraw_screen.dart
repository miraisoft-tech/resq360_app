import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/wallet_bloc/wallet_bloc.dart';
import 'package:resq360/core/bloc/wallet_transaction_bloc/wallet_transaction_bloc.dart';
import 'package:resq360/core/theme/static_colors.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';
import 'package:resq360/features/provider/dashboard/widgets/no_bank_account_dialog.dart';
import 'package:resq360/features/provider/dashboard/widgets/saved_bank_accounts_section.dart';
import 'package:resq360/features/settings/data/bloc/bank_bloc/bloc/bank_bloc.dart';

class ProviderWithdrawScreen extends StatefulWidget {
  const ProviderWithdrawScreen({required this.balance, super.key});
  final String balance;
  @override
  State<ProviderWithdrawScreen> createState() => _ProviderWithdrawScreenState();
}

class _ProviderWithdrawScreenState extends State<ProviderWithdrawScreen> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController accountNumberController;

  final List<String> values = [
    '₦ 5,000',
    '₦ 10,000',
    '₦ 20,000',
    '₦ 50,000',
  ];

  List<BankDetails> existingAccounts = [];

  @override
  void initState() {
    super.initState();
    context.read<BankBloc>().add(BankFetchAccounts());
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<WalletTransactionsBloc, WalletTransactionsState>(
            listener: (context, state) async {
              if (state is WithdrawalSuccess) {
                context.read<WalletBloc>().add(FetchWalletInfo());
                context.read<WalletTransactionsBloc>().add(
                  FetchWalletTransactions(),
                );
                Navigator.pop(context);
                await GeneralDialogs.showCustomDialog<void>(
                  context,
                  body: WithdrawalCompletedModal(
                    amount: state.payout.amount ?? 0,
                    reference: state.payout.reference ?? '',
                  ),
                );
              }

              if (state is WithdrawalFailure) {
                final error = state.error.toLowerCase();

                if (error.contains('add a verified bank account first')) {
                  await GeneralDialogs.showCustomDialog<void>(
                    context,
                    body: const NoBankAccountDialog(),
                  );
                } else {
                  await showErrorSnackbar(context, state.error);
                }
              }
            },
          ),
          BlocListener<BankBloc, BankState>(
            listener: (context, state) async {
              // if ( state is BankLoading) {
              //   showLoadingDialog(context);
              // } else{
              //   Navigator()
              // }

              if (state is BankAccountsFetched) {
                setState(() {
                  existingAccounts = state.bankAcounts;
                });
              }
              if (state is CustomerDefaultBankAccountSetSuccesful) {
                context.read<BankBloc>().add(BankFetchAccounts());
                await showSuccessSnackbar(
                  context,
                  'Default bank account updated',
                );
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
          ),
        ],

        child: SafeArea(
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
                        '₦ ${AppTextUtil.formatAmount(widget.balance)}',
                        size: 18,
                        height: 24.5,
                        weight: FontWeight.w700,
                        color: appColors.textColor.shade800,
                      ),
                    ],
                  ),
                ),
                20.verticalSpace,
                const SavedBankAccountsSection(),
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
                BlocBuilder<WalletTransactionsBloc, WalletTransactionsState>(
                  builder: (context, state) {
                    return WideButton(
                      label: 'Withdraw',
                      loading: state is WithdrawalProcessing,
                      onPressed: () async {
                        final amount = int.tryParse(
                          amountController.text.replaceAll(
                            RegExp('[^0-9]'),
                            '',
                          ),
                        );
                        final parsedBalance = double.parse(widget.balance);
                        if (parsedBalance.toInt() < (amount ?? 0)) {
                          await showErrorSnackbar(
                            context,
                            'Insufficient balance',
                          );
                          return;
                        }
                        if (amount == null || amount <= 0) {
                          await showErrorSnackbar(
                            context,
                            'Enter a valid amount',
                          );
                          return;
                        }

                        context.read<WalletTransactionsBloc>().add(
                          RequestWithdrawal(
                            amount: amount,
                            reason: 'Provider withdrawal',
                          ),
                        );
                      },
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

class WithdrawalCompletedModal extends StatelessWidget {
  const WithdrawalCompletedModal({
    required this.amount,
    required this.reference,
    super.key,
  });
  final int amount;
  final String reference;
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
                '₦${AppTextUtil.formatAmount(amount.toString())}',
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
