import 'dart:async';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/navigation/navigator.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/core/services/location_service.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/customer_user_model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/local_user.model.dart';
import 'package:resq360/features/customer/authentication/data/service/auth_remote.repo.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';

class CustomerAuthProvider extends BaseViewModel with LocationMixin {
  CustomerAuthProvider._internal({required this.authRemoteRepo});
  static final CustomerAuthProvider instance = CustomerAuthProvider._internal(
    authRemoteRepo: AuthRemoteRepo.instance,
  );

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

  CustomerUserModel? authInfo;

  ////======================AUTH INITIALIZATION=========================////

  Future<void> init() async {
    final authData = await AuthLocalRepo.instance.getCustomerAuthCredentials();

    await initLocalRepo();

    if (authData != null) {
      await afterLogIn(authData);
    }
  }

  Future<void> initLocalRepo() async {
    localCred = await getLocalUserCred();
    useBiometics = await AuthLocalRepo.instance.getAccountBiometricsLogin();
    notifyListeners();
  }

  Future<void> afterLogIn(CustomerUserModel auth) async {
    authInfo = auth;
    await AuthLocalRepo.instance.storeUserDetails(
      isProvider: false,
      customerProfileResponse: auth,
    );

    notifyListeners();

    unawaited(loadCustomerProfile());
  }

  Future<void> loadCustomerProfile() async {
    if (authInfo == null) return;

    try {
      setBusy(isBusy: true);

      final profile = await authRemoteRepo.getUserProfile();
      authInfo = profile.data;

      notifyListeners();
    } on Exception catch (e, s) {
      log('Failed to load customer profile: $e');
      log(s);
    } finally {
      setBusy(isBusy: false);
    }
  }

  Future<void> clearAuthData() async {
    authInfo = null;
    await AuthLocalRepo.instance.clearAuthCredentials();
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      setBusy(isBusy: true);

      await ChatSocketService.instance.reset();

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
