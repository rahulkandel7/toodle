import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  static Future<bool> authenticateWithBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    bool isAuthenticate = false;
    if (canAuthenticate) {
      try {
        isAuthenticate = await auth.authenticate(
          localizedReason: 'Complete Authorization for Login',
          options: const AuthenticationOptions(
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );
      } on PlatformException catch (e) {
        print(e);
      }
    }
    return isAuthenticate;
  }
}
