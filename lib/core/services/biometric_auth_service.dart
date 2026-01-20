import 'package:local_auth/local_auth.dart';
import 'package:resq360/__lib.dart';

class BiometricAuthService {
  BiometricAuthService._internal();
  static final BiometricAuthService instance = BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && canAuthenticate;
    } on Exception catch (e) {
      log('Error checking biometric availability: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on Exception catch (e) {
      log('Error getting available biometrics: $e');
      return [];
    }
  }

  Future<bool> isFaceIdAvailable() async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.face);
  }

  Future<bool> isFingerprintAvailable() async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.fingerprint);
  }

  Future<bool> authenticate({
    String reason = 'Please authenticate to login',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
      );
    } on Exception catch (e) {
      log('Error during biometric authentication: $e');
      return false;
    }
  }

  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on Exception catch (e) {
      log('Error canceling authentication: $e');
    }
  }
}
