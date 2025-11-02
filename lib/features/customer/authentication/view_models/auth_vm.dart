import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/navigation/navigator.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/location_service.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/auth_user.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/local_user.model.dart';
import 'package:resq360/features/customer/authentication/data/service/auth_remote.repo.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>(
  (ref) => AuthProvider(authRemoteRepo: AuthRemoteRepo.instance, ref: ref),
);

class AuthProvider extends BaseViewModel with LocationMixin {
  AuthProvider({required this.authRemoteRepo, required this.ref});

  final AuthRemoteRepo authRemoteRepo;
  Ref ref;

  BuildContext get context => AppNavigator.navKey.currentContext!;

  ////======================LOCATION=========================////

  @override
  void onLocationUpdated() {
    log(
      'Lat: ${currentPosition?.latitude}, Lng: ${currentPosition?.longitude}',
    );
  }

  LocalUser? localCred;
  bool get isLocalCredStored => localCred != null;
  bool useBiometics = false;

  bool isLoading = false;
  void setBusy({required bool isBusy}) {
    //UPDATE LOADING
    isLoading = isBusy;
    notifyListeners();
  }

  AuthResponse? authInfo;

  Future<void> init() async {
    final authData = await AuthLocalRepo.instance.getAuthCredentials();
    if (authData != null) {
      log('Restored AuthResponse from local storage');
      authInfo = authData;
    } else {
      log('No saved AuthResponse found — user not logged in');
    }
    await initLocalRepo();

    notifyListeners();
  }

  Future<void> initLocalRepo() async {
    localCred = await getLocalUserCred();
    useBiometics = await AuthLocalRepo.instance.getAccountBiometricsLogin();
    notifyListeners();
  }

  Future<void> clearAuthData() async {
    authInfo = null;

    await AuthLocalRepo.instance.clearAuthCredentials();

    notifyListeners();
  }

  Future<dynamic> saveUserCredLocally({
    required String username,
    required String password,
  }) async {
    log('saveUserCredLocally');

    return AuthLocalRepo.instance.storeLocalCredentials(
      email: username,
      password: password,
    );
  }

  Future<LocalUser?> getLocalUserCred() async {
    final result = await AuthLocalRepo.instance.getLocalCredentials();
    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    try {
      setBusy(isBusy: true);

      // Clear all local data related to auth
      await AuthLocalRepo.instance.clearAuthCredentials();
      await AuthLocalRepo.instance.clearAccessToken();
      await AuthLocalRepo.instance.clearLocalCred();
      await AuthLocalRepo.instance.clearUserType();

      authInfo = null;
      localCred = null;
      useBiometics = false;

      setBusy(isBusy: false);
      notifyListeners();

      if (context.mounted) {
        await replaceScreen(context, const SelectAccountTypeScreen());
      }

      log('Logout successful');
    } on Exception catch (e, s) {
      log('Logout failed: $e');
      log(s);
      setBusy(isBusy: false);
    }
  }
}
