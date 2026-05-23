import 'dart:async';

import 'package:flutter/material.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/local_user.model.dart';

class CustomerAuthProvider extends ChangeNotifier {
  CustomerAuthProvider._internal();
  static final CustomerAuthProvider instance = CustomerAuthProvider._internal();

  LocalUser? localCred;
  bool useBiometrics = false;


  Future<void> init() async {
    localCred = await AuthLocalRepo.instance.getLocalCredentials();
    useBiometrics = await AuthLocalRepo.instance.getAccountBiometricsLogin();
    notifyListeners();
  }

  bool get isLocalCredStored => localCred != null;

  Future<void> clearLocalAuth() async {
    await AuthLocalRepo.instance.clearLocalCred();
    localCred = null;
    notifyListeners();
  }

}
