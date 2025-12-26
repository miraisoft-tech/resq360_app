import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/provider/authentication/view_models/auth_vm.dart';

class AuthSessionKiller extends ChangeNotifier{
  static bool _hasKilled = false;

  static Future<void> kill() async {
    if (_hasKilled) return;
    _hasKilled = true;

    await AuthLocalRepo.instance.clearAuthCredentials();
    await AuthLocalRepo.instance.clearAccessToken();
    await AuthLocalRepo.instance.clearLocalCred();
    await AuthLocalRepo.instance.clearUserType();

    CustomerAuthProvider.instance
      ..authInfo = null
      ..localCred = null
      ..useBiometics = false
      ..notifyListeners();

    ProviderAuthProvider.instance
      ..authInfo = null
      ..localCred = null
      ..useBiometics = false
      ..notifyListeners();
  }

  static void reset() {
    _hasKilled = false;
  }
}
