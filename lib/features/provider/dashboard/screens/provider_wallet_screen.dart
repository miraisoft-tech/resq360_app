
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/wallet_bloc/wallet_bloc.dart';
import 'package:resq360/core/bloc/wallet_transaction_bloc/wallet_transaction_bloc.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/customer/authentication/view_models/customer_auth_vm.dart';
import 'package:resq360/features/customer/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/customer/chat/screens/support_chat_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/wallet_transaction.dart';
import 'package:resq360/features/customer/dashboard/screens/transaction_detail.modal.dart';
import 'package:resq360/features/customer/dashboard/widgets/wallet_transaction_tile.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/authentication/view_models/provider_auth_vm.dart';
import 'package:resq360/features/provider/dashboard/screens/provider_withdraw_screen.dart';
import 'package:resq360/features/settings/data/models/admin_types.enums.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';
import 'package:resq360/features/widgets/dialogs/fund_method.dialog.dart';
import 'package:resq360/features/widgets/dialogs/fund_wallet_confirm.dialog.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';

class ProviderWalletScreen extends StatefulWidget {
  const ProviderWalletScreen({super.key});

  @override
  State<ProviderWalletScreen> createState() => _ProviderWalletScreenState();
}

class _ProviderWalletScreenState extends State<ProviderWalletScreen> {
    String? userType;
  dynamic currentUser;
  bool userReady = false;
  @override
  void initState() {
    super.initState();
 WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _setupUser();
       context.read<WalletBloc>().add(FetchWalletInfo());
    context.read<WalletTransactionsBloc>().add(FetchWalletTransactions());
    });
  }

     Future<void> _setupUser() async {
    final type = await AuthLocalRepo.instance.getUserType();
    if (type == null) return;

    userType = type;

    if (type == 'user') {
      currentUser = CustomerAuthProvider.instance.authInfo;
    } else if (type == UserType.provider.name) {
      currentUser = ProviderAuthProvider.instance.authInfo;
    }

    if (mounted) {
      setState(() {
        userReady = currentUser != null;
      });
    }
  }

      Future<void> _handleAppeal(BuildContext context, WalletTransaction walletTx) async {
    final shouldProceed = await GeneralDialogs.showCustomDialog<bool>(
      context,
      body: const PaymentAppealDialog(),
    );

    if (shouldProceed != true) return;

    final existingTicketId = await SupportRepo.instance.findExistingOpenAppealTicketId();

    if (!context.mounted) {
      return;
    }

    if (existingTicketId != null) {
      if (currentUser != null) {
        await pushScreen(
          context,
          SupportChatScreen(
            ticketId: existingTicketId,
          ),
        );
      }

      return;
    }

    final serviceName = walletTx.category;
    final contactEmail = currentUser.email;
    final contactPhone = currentUser.phoneNumber;

    final res = await SupportRepo.instance.createTicket(
      subject: 'Service Appeal',
      description: 'User opened an appeal for $serviceName service.',
      category: AdminIssueType.paymentIssue.value,
      priority: 'LOW',
      contactEmail: contactEmail.toString(),
      contactPhone: contactPhone.toString(),
      serviceCategory: walletTx.serviceRequestId,
      relatedServiceProviderId: walletTx.providerId,
    );

    if (!context.mounted) return;

    if (res.error != null) {
      await showErrorSnackbar(context, res.error!);
      return;
    }

    final ticketId = res.data!['data']['ticketId'].toString();

    await pushScreen(
      context,
      SupportChatScreen(
        ticketId: ticketId,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    // final transactions = [
    //   const WalletTransaction(
    //     title: 'QuickTow Emergency',
    //     date: 'Aug 15th, 5:16pm',
    //     amount: 7500,
    //     isCredit: true,
    //   ),
    //   const WalletTransaction(
    //     title: 'QuickTow Emergency',
    //     date: 'Aug 15th, 2:00pm',
    //     amount: -15000,
    //     isCredit: false,
    //   ),
    //   const WalletTransaction(
    //     title: 'QuickTow Emergency',
    //     date: 'Aug 15th, 2:00pm',
    //     amount: 7500,
    //     isCredit: true,
    //   ),
    //   const WalletTransaction(
    //     title: 'QuickTow Emergency',
    //     date: 'Aug 15th, 2:00pm',
    //     amount: -15000,
    //     isCredit: false,
    //   ),
    // ];

    return Scaffold(
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
      body: SingleChildScrollView(
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
                        body: FundMethodDialog(
                          onPaymentSelected: (PaymentMethod p1) async {
                            await GeneralDialogs.showCustomDialog<void>(
                              context,
                              body: const FundWalletConfirmDialog(
                                // amount: '₦20,000',
                              ),
                            );
                          },
                        ),
                      );
                    },
                    onWithdraw: () async {
                      await pushScreen(context, const ProviderWithdrawScreen());
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
                GenText(
                  'View All',
                  size: 12,
                  weight: FontWeight.w400,
                  color: appColors.primary.shade500,
                ),
              ],
            ),
            16.verticalSpace,
            BlocBuilder<WalletTransactionsBloc, WalletTransactionsState>(
              builder: (context, state) {
                if (state is WalletTransactionsLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                    return const EmptyScreenWidget(
                      imagePath: AppAssets.ASSETS_IMAGES_EMPTY_WALLET_PNG,
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
                              onSupport: () => _handleAppeal(context, tx),
                              tx: tx,
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            // if (transactions.isEmpty)
            //   const EmptyScreenWidget(
            //     imagePath: AppAssets.ASSETS_IMAGES_EMPTY_WALLET_PNG,
            //     message: 'No Transactions Yet',
            //     subMessage:
            //         'Your wallet history will appear here after yourfirst payment or credit',
            //   )
            // else
            //   ListView.separated(
            //     shrinkWrap: true,
            //     itemBuilder: (context, index) {
            //       final tx = transactions[index];
            //       return WalletTransactionTile(
            //         tx: tx,
            //         onTap: () async {
            //           await GeneralDialogs.showCustomBottomSheet(
            //             context,
            //             body: TransactionDetailModal(
            //               onRetry: () {},
            //               onSupport: () {},
            //             ),
            //           );
            //         },
            //       );
            //     },
            //     separatorBuilder: (context, index) => 16.verticalSpace,
            //     itemCount: transactions.length,
            //   ),
          ],
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
