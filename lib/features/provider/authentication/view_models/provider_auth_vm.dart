import 'dart:async';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/local_user.model.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/provider/authentication/data/service/provider_auth_remote.repo.dart';

class ProviderAuthProvider extends ChangeNotifier {
    ProviderAuthProvider._internal({required this.authRemoteRepo});
  static final ProviderAuthProvider instance = ProviderAuthProvider._internal(
    authRemoteRepo: ProviderAuthRemoteRepo.instance,
  );
  final ProviderAuthRemoteRepo authRemoteRepo;
  LocalUser? localCred;
  bool useBiometrics = false;

  Future<void> init() async {
    localCred = await AuthLocalRepo.instance.getLocalCredentials();
    useBiometrics = await AuthLocalRepo.instance.getAccountBiometricsLogin();
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await AuthLocalRepo.instance.clearAuthCredentials();
    await AuthLocalRepo.instance.clearAccessToken();
    await AuthLocalRepo.instance.clearLocalCred();
    await AuthLocalRepo.instance.clearUserType();
    await ChatSocketService.instance.dispose();


  await replaceScreen(context, const SelectAccountTypeScreen());
  }

  bool get isLocalCredStored => localCred != null;
}
