import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/wallet_bloc/wallet_bloc.dart';
import 'package:resq360/core/bloc/wallet_transaction_bloc/wallet_transaction_bloc.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/payment_bloc/customer_payment_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/all_transactions_screen.dart';
import 'package:resq360/features/customer/dashboard/screens/paystack_webview.dart';
import 'package:resq360/features/customer/dashboard/screens/transaction_detail.modal.dart';
import 'package:resq360/features/customer/dashboard/widgets/wallet_transaction_tile.dart';
import 'package:resq360/features/provider/dashboard/screens/provider_withdraw_screen.dart';
import 'package:resq360/features/settings/screens/contact_admin_screen.dart';
import 'package:resq360/features/widgets/dialogs/fund_wallet_completed.dialog.dart';
import 'package:resq360/features/widgets/dialogs/fund_wallet_confirm.dialog.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';

class ProviderWalletScreen extends StatefulWidget {
  const ProviderWalletScreen({super.key});

  @override
  State<ProviderWalletScreen> createState() => _ProviderWalletScreenState();
}

class _ProviderWalletScreenState extends State<ProviderWalletScreen> {
  bool isLoadingDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<WalletBloc>().add(FetchWalletInfo());
      context.read<WalletTransactionsBloc>().add(FetchWalletTransactions());
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return BlocListener<CustomerPaymentBloc, CustomerPaymentState>(
      listener: (context, state) async {
        if (state is WalletFundingLoadingState) {
          if (!isLoadingDialogShown) {
            isLoadingDialogShown = true;
            showLoadingDialog(context);
            log(isLoadingDialogShown);
          }
          return;
        }

        if (isLoadingDialogShown) {
          isLoadingDialogShown = false;
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is WalletFundingInitiatedState) {
          if (isLoadingDialogShown) {
            isLoadingDialogShown = false;
            Navigator.of(context, rootNavigator: true).pop();
          }
          final url = state.payment.authorizationUrl;
          final reference = state.payment.reference;
          if (!mounted) return;
          final finished = await Navigator.of(
            context,
            rootNavigator: true,
          ).push<bool>(
            MaterialPageRoute(
              builder:
                  (_) => PaystackWebViewPage(
                    authorizationUrl: url,
                    reference: reference,
                    callbackUrl: 'https://example.com/callback',
                  ),
            ),
          );

          log(finished.toString());

          if (!mounted) return;

          if (finished ?? false) {
            context.read<CustomerPaymentBloc>().add(
              CustomerVerifyWalletFundingEvent(reference),
            );
          } else {
            await showErrorSnackbar(context, 'Payment cancelled');
          }
        }

        if (state is WalletFundingVerifiedState) {
          if (isLoadingDialogShown) {
            isLoadingDialogShown = false;
            Navigator.of(context, rootNavigator: true).pop();
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }

          if (!mounted) return;

          await GeneralDialogs.showCustomDialog<void>(
            context,
            body: FundWalletCompleted(
              amount: state.verification.amount,
            ),
          );
          context.read<WalletBloc>().add(FetchWalletInfo());
          context.read<WalletTransactionsBloc>().add(FetchWalletTransactions());
        }

        if (state is WalletFundingFailureState) {
          await showErrorSnackbar(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: appColors.whiteColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appColors.whiteColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appColors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: UrbText(
            'My Wallet',
            color: appColors.black,
            size: 22,
            height: 28.5,
            weight: FontWeight.w700,
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<WalletBloc>().add(FetchWalletInfo());
            context.read<WalletTransactionsBloc>().add(
              FetchWalletTransactions(),
            );
          },
          color: appColors.primary,
          child: SingleChildScrollView(
            padding: pad(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    if (state is FetchWalletLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: appColors.primary.shade500,
                        ),
                      );
                    }
                    if (state is FetchingWalletInfoError) {
                      return Center(
                        child: ErrorMessageAndButton(
                          error: 'failed to fetch balance',
                          onPressed: () {
                            context.read<WalletBloc>().add(FetchWalletInfo());
                          },
                        ),
                      );
                    }

                    if (state is FetchedWalletInfo) {
                      final balance = state.wallet.balance;
                      return ProviderWalletBalanceCard(
                        balance: balance!.toInt(),
                        onAddFunds: () async {
                          await GeneralDialogs.showCustomDialog<void>(
                            context,
                            body: const FundWalletConfirmDialog(
                              // amount: 20000,
                            ),
                          );
                        },
                        onWithdraw: () async {
                          await pushScreen(
                            context,
                            ProviderWithdrawScreen(balance: balance.toString(),),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                30.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GenText(
                      'Transaction History',
                      size: 18,
                      weight: FontWeight.w700,
                      color: appColors.black,
                    ), 
                     GestureDetector(
                      onTap: () async {
                        await pushScreen(
                          context,
                          const AllTransactionsScreen(),
                        );
                      },
                   child: GenText(
                      'View All',
                      size: 12,
                      weight: FontWeight.w400,
                      color: appColors.primary.shade500,
                    ),
                    ),
                  ],
                ),
                16.verticalSpace,
                BlocBuilder<WalletTransactionsBloc, WalletTransactionsState>(
                  builder: (context, state) {
                    if (state is WalletTransactionsLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: appColors.primary.shade500,
                        ),
                      );
                    }

                    if (state is WalletTransactionsError) {
                      return ErrorMessageAndButton(
                        error: state.error,
                        onPressed: () {
                          context.read<WalletTransactionsBloc>().add(
                            FetchWalletTransactions(),
                          );
                        },
                      );
                    }

                    if (state is WalletTransactionsLoaded) {
                      final transactions = state.transactions;

                      if (transactions.isEmpty) {
                        return EmptyScreenWidget(
                          image:
                              AppAssets.ASSETS_IMAGES_EMPTY_WALLET_PNG
                                  .imageAsset(),
                          message: 'No Transactions Yet',
                          subMessage:
                              'Your wallet history will appear here after your first payment or credit',
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        separatorBuilder: (_, _) => 16.verticalSpace,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];

                          return WalletTransactionTile(
                            tx: tx,
                            onTap: () async {
                              await GeneralDialogs.showCustomBottomSheet(
                                context,
                                body: TransactionDetailModal(
                                  onRetry: () {},
                                  onSupport: () async {
                                    await pushScreen(
                                      context,
                                      const ContactAdminScreen(),
                                    );
                                  },
                                  tx: tx,
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    return ErrorMessageAndButton(
                        error: 'An error occured',
                        onPressed: () {
                          context.read<WalletTransactionsBloc>().add(
                            FetchWalletTransactions(),
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

class ProviderWalletBalanceCard extends StatelessWidget {
  const ProviderWalletBalanceCard({
    required this.balance,
    required this.onAddFunds,
    required this.onWithdraw,
    super.key,
  });

  final int balance;
  final VoidCallback onAddFunds;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      padding: pad(vertical: 24, horizontal: 18),
      decoration: BoxDecoration(
        color: appColors.primary.shade500,
        borderRadius: BorderRadius.circular(12.r),
        image: DecorationImage(
          image: const AssetImage(AppAssets.ASSETS_IMAGES_APPLE_PNG),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            appColors.primary.shade500,
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Column(
        children: [
          GenText(
            'Available Balance',
            size: 12,
            height: 18.5,
            color: appColors.whiteColor,
            weight: FontWeight.w500,
          ),
          4.verticalSpace,
          UrbText(
            '₦${AppTextUtil.formatAmount(balance.toStringAsFixed(0))}',
            color: appColors.whiteColor,
            size: 30,
            height: 32.5,
            weight: FontWeight.w700,
          ),
          16.verticalSpace,
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32.h,
                  child: ElevatedButton.icon(
                    onPressed: onAddFunds,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.whiteColor,
                      padding: pad(vertical: 10, horizontal: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(Icons.add, color: appColors.primary.shade500),
                    label: GenText(
                      'Add Funds',
                      height: 16.5,
                      color: appColors.primary.shade500,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: SizedBox(
                  height: 32.h,
                  child: ElevatedButton.icon(
                    onPressed: onWithdraw,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.whiteColor,
                      padding: pad(vertical: 10, horizontal: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(Icons.send, color: appColors.primary.shade500),
                    label: GenText(
                      'Withdraw',
                      height: 16.5,
                      color: appColors.primary.shade500,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
