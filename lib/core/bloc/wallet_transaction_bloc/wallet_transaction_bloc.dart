import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/request_payout_response.dart';

import 'package:resq360/core/services/wallet.dart';
import 'package:resq360/features/customer/dashboard/data/models/wallet_transaction.dart';
import 'package:resq360/features/customer/dashboard/data/service/payment_repo.dart';

part 'wallet_transaction_event.dart';
part 'wallet_transaction_state.dart';

final WalletRepo walletRepo = WalletRepo.instance;
final PaymentRepo paymentRepo = PaymentRepo();

class WalletTransactionsBloc
    extends Bloc<WalletTransactionsEvent, WalletTransactionsState> {
  WalletTransactionsBloc() : super(WalletTransactionsInitial()) {
    on<FetchWalletTransactions>(_onFetchWalletTransactions);
    on<RefreshWalletTransactions>(_onRefreshWalletTransactions);
    on<LoadMoreWalletTransactions>(_onLoadMoreWalletTransactions);
    on<RequestWithdrawal>(_onRequestWithdrawal);
  }

  int _currentPage = 1;
  bool _hasNextPage = true;
  final List<WalletTransaction> _transactions = [];

  Future<void> _onFetchWalletTransactions(
    FetchWalletTransactions event,
    Emitter<WalletTransactionsState> emit,
  ) async {
    emit(WalletTransactionsLoading());

    _currentPage = 1;
    _transactions.clear();

    await _fetch(emit);
  }

  Future<void> _onRefreshWalletTransactions(
    RefreshWalletTransactions event,
    Emitter<WalletTransactionsState> emit,
  ) async {
    _currentPage = 1;
    _transactions.clear();

    await _fetch(emit, isRefresh: true);
  }

  Future<void> _onLoadMoreWalletTransactions(
    LoadMoreWalletTransactions event,
    Emitter<WalletTransactionsState> emit,
  ) async {
    if (!_hasNextPage || state is WalletTransactionsLoadingMore) return;

    emit(WalletTransactionsLoadingMore(transactions: List.of(_transactions)));

    _currentPage++;

    await _fetch(emit, isLoadMore: true);
  }

  Future<void> _fetch(
    Emitter<WalletTransactionsState> emit, {
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    final result = await walletRepo.fetchAllWalletTransaction(
      page: _currentPage,
    );

    if (result.isSuccess && result.data != null) {
      final data = result.data!;

      _transactions.addAll(data.transactions);
      _hasNextPage = data.pagination.hasNextPage ?? false;

      emit(
        WalletTransactionsLoaded(
          transactions: List.of(_transactions),
          pagination: data.pagination,
          isRefresh: isRefresh,
        ),
      );
    } else {
      emit(
        WalletTransactionsError(
          error: result.error ?? 'Failed to fetch transactions',
        ),
      );
    }
  }

  Future<void> _onRequestWithdrawal(
    RequestWithdrawal event,
    Emitter<WalletTransactionsState> emit,
  ) async {
    emit(WithdrawalProcessing());

    final result = await paymentRepo.requestPayout(
      amount: event.amount,
      reason: event.reason,
    );

    if (result.isSuccess && result.data != null) {
      emit(WithdrawalSuccess(result.data!));
      add(FetchWalletTransactions());
    } else {
      emit(WithdrawalFailure(result.error ?? 'Withdrawal failed'));
    }
  }
}
