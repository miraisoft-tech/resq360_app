import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/services/auth_session_killer.dart';

part 'auth_event.dart';
part 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc() : super(AuthInitial()) {
    on<ForceLogoutEvent>(_onForceLogout);
    on<AuthResetEvent>(_onAuthReset);
  }
  bool _isLoggingOut = false;

  Future<void> _onForceLogout(
    ForceLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    await AuthSessionKiller.kill();

    emit(AuthLoggedOut());
  }

  void _onAuthReset(
    AuthResetEvent event,
    Emitter<AuthState> emit,
  ) {
    _isLoggingOut = false;
    emit(AuthInitial());
  }
}
