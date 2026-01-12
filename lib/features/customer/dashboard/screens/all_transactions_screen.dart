import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/wallet_transaction_bloc/wallet_transaction_bloc.dart';
import 'package:resq360/features/customer/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/customer/chat/screens/support_chat_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/wallet_transaction.dart';
import 'package:resq360/features/customer/dashboard/screens/transaction_detail.modal.dart';
import 'package:resq360/features/customer/dashboard/widgets/wallet_transaction_tile.dart';
import 'package:resq360/features/settings/data/models/admin_types.enums.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String? userType;
  dynamic currentUser;
  bool userReady = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<WalletTransactionsBloc>().add(FetchWalletTransactions());
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<WalletTransactionsBloc>().state;
      if (state is WalletTransactionsLoaded &&
          (state.pagination.hasNextPage ?? false)) {
        context.read<WalletTransactionsBloc>().add(
          LoadMoreWalletTransactions(),
        );
      }
    }
  }


  Future<void> _handleAppeal(
    BuildContext context,
    WalletTransaction walletTx,
  ) async {
    final shouldProceed = await GeneralDialogs.showCustomDialog<bool>(
      context,
      body: const PaymentAppealDialog(),
    );

    if (shouldProceed != true) return;

    final existingTicketId =
        await SupportRepo.instance.findExistingOpenAppealTicketId();

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
          'All Transactions',
          color: appColors.black,
          size: 22,
          height: 28.5,
          weight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WalletTransactionsBloc>().add(FetchWalletTransactions());
        },
        color: appColors.primary,
        child: BlocBuilder<WalletTransactionsBloc, WalletTransactionsState>(
          builder: (context, state) {
            if (state is WalletTransactionsLoading) {
              return  Center(child: CircularProgressIndicator(
            color: appColors.primary,

              ));
            }

            if (state is WalletTransactionsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ErrorMessageAndButton(
                    error: state.error,
                    onPressed: () {
                      context.read<WalletTransactionsBloc>().add(
                        FetchWalletTransactions(),
                      );
                    },
                  ),
                ),
              );
            }

            if (state is WalletTransactionsLoaded ||
                state is WalletTransactionsLoadingMore) {
              final transactions =
                  state is WalletTransactionsLoaded
                      ? state.transactions
                      : (state as WalletTransactionsLoadingMore).transactions;

              final isLoadingMore = state is WalletTransactionsLoadingMore;
              final hasMore =
                  state is! WalletTransactionsLoaded ||
                  (state.pagination.hasNextPage ?? false);

              if (transactions.isEmpty) {
                return const Center(
                  child: EmptyScreenWidget(
                    imagePath: AppAssets.ASSETS_IMAGES_EMPTY_WALLET_PNG,
                    message: 'No Transactions Yet',
                    subMessage:
                        'Your wallet history will appear here after your first payment or credit',
                  ),
                );
              }

              return ListView.separated(
                controller: _scrollController,
                padding: pad(horizontal: 20, vertical: 16),
                itemCount:
                    transactions.length + ((isLoadingMore || hasMore) ? 1 : 0),
                separatorBuilder: (_, _) => 16.verticalSpace,
                itemBuilder: (context, index) {
                  if (index >= transactions.length) {
                    return Center(
                      child: Padding(
                        padding: pad(both: 16),
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }

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
      ),
    );
  }
}
