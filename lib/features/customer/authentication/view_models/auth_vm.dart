import 'dart:async';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/navigation/navigator.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/location_service.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/auth_user.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/local_user.model.dart';
import 'package:resq360/features/customer/authentication/data/service/auth_remote.repo.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';

class CustomerAuthProvider extends BaseViewModel with LocationMixin {
  // Singleton setup
  CustomerAuthProvider._internal({required this.authRemoteRepo});
  static final CustomerAuthProvider instance =
      CustomerAuthProvider._internal(authRemoteRepo: AuthRemoteRepo.instance);

  final AuthRemoteRepo authRemoteRepo;

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
    isLoading = isBusy;
    notifyListeners();
  }

  AuthResponse? authInfo;

  Future<void> init() async {
    final authData = await AuthLocalRepo.instance.getAuthCredentials();

    if (authData != null) {
      log('Restored AuthResponse for customer');
      authInfo = authData;
    } else {
      log('No saved AuthResponse for customer — user not logged in');
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

  Future<void> logout() async {
    try {
      setBusy(isBusy: true);

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

      log('Customer logout successful');
    } on Exception catch (e, s) {
      log('Customer logout failed: $e');
      log(s);
      setBusy(isBusy: false);
    }
  }

  Future<LocalUser?> getLocalUserCred() async {
    final result = await AuthLocalRepo.instance.getLocalCredentials();
    notifyListeners();
    return result;
  }
}
