import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';

import 'package:resq360/core/services/wallet.dart';
import 'package:resq360/features/customer/dashboard/data/models/wallet_transaction.dart';

part 'wallet_transaction_event.dart';
part 'wallet_transaction_state.dart';


final WalletRepo walletRepo = WalletRepo.instance;

class WalletTransactionsBloc
    extends Bloc<WalletTransactionsEvent, WalletTransactionsState> {
  WalletTransactionsBloc() : super(WalletTransactionsInitial()) {
    on<FetchWalletTransactions>(_onFetchWalletTransactions);
    on<RefreshWalletTransactions>(_onRefreshWalletTransactions);
    on<LoadMoreWalletTransactions>(_onLoadMoreWalletTransactions);
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
    final result = await walletRepo.fetchAllWalletTransaction(page: _currentPage);

    if (result.isSuccess && result.data != null) {
      final data = result.data!;

      _transactions.addAll(data.transactions);
      _hasNextPage = data.pagination.hasNextPage;

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
}
