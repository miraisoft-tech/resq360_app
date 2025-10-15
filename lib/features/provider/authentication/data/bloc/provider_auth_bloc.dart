import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/authentication/data/models/auth_user.model.dart';

part 'provider_auth_event.dart';
part 'provider_auth_state.dart';

class ProviderAuthBloc extends Bloc<ProviderAuthEvent, ProviderAuthState> {
  ProviderAuthBloc() : super(ProviderAuthInitial()) {
    on<ProviderAuthEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
