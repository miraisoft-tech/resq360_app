import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/provider/authentication/view_models/auth_vm.dart';

class AuthSessionKiller {
  static bool _hasLoggedOut = false;

  static Future<void> kill() async {
    if (_hasLoggedOut) return;
    _hasLoggedOut = true;

    await AuthLocalRepo.instance.clearAuthCredentials();

    await CustomerAuthProvider.instance.logout();
    await ProviderAuthProvider.instance.logout();
  }

  static void reset() {
    _hasLoggedOut = false;
  }
}
