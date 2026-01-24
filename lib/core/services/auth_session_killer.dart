import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/chat_socket_service.dart';

class AuthSessionKiller {
  static bool _hasKilled = false;

  static Future<void> kill() async {
    if (_hasKilled) return;
    _hasKilled = true;

    await AuthLocalRepo.instance.clearAuthCredentials();
    await AuthLocalRepo.instance.clearAccessToken();
    await AuthLocalRepo.instance.clearLocalCred();
    await AuthLocalRepo.instance.clearUserType();
    await ChatSocketService.instance.dispose();

    Future.delayed(const Duration(milliseconds: 300), () {
      _hasKilled = false;
    });
  }

  static void reset() {
    _hasKilled = false;
  }
}
