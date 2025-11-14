import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/services/wallet.dart';
import 'package:resq360/features/customer/dashboard/data/models/wallet/wallet.model.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

final WalletRepo walletRepo = WalletRepo.instance;
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<FetchWalletInfo> (_onFetchWalletInfo);
  }
}

Future<void> _onFetchWalletInfo(
  FetchWalletInfo event,
  Emitter<WalletState> emit,
)async{
emit(FetchWalletLoading());
try {
  final result = await walletRepo.getWalletInfo();
  if (result.isSuccess) {
    emit(FetchedWalletInfo(wallet: result.data!));
  } else {
    emit(FetchingWalletInfoError(error: result.error));
  }
} on Exception catch (e) {
  emit(FetchingWalletInfoError(error: '$e'));
}
}
