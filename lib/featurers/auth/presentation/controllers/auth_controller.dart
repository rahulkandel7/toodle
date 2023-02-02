import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/auth/data/repositories/auth_repositories.dart';

class AuthController extends StateNotifier<AsyncValue> {
  AuthController(this._authRepositories) : super(const AsyncData<void>(null));

  final AuthRepositories _authRepositories;

//Login Method
  Future<List<String>> login(String email, String password) async {
    var data = {
      'email': email,
      'password': password,
    };
    final result = await _authRepositories.login(data);
    return result.fold((error) {
      List<String> msg = ['false', error.message];
      return msg;
    }, (success) {
      List<String> msg = ['true', success];
      return msg;
    });
  }

//Register Method
  Future<List<String>> register(var data) async {
    final result = await _authRepositories.register(data);
    return result.fold((error) {
      List<String> msg = ['false', error.message];
      return msg;
    }, (success) {
      List<String> msg = ['true', success];
      return msg;
    });
  }

  //Logout Method
  Future<List<String>> logout() async {
    final result = await _authRepositories.logout();
    return result.fold((error) {
      List<String> msg = ['false', error.message];
      return msg;
    }, (success) {
      List<String> msg = ['true', success];
      return msg;
    });
  }

  //Send Forget Password Link
  Future<List<String>> sendPasswordResetLink(String email) async {
    var data = {'email': email};
    final result = await _authRepositories.sendPasswordResetLink(data);
    return result.fold((error) {
      List<String> msg = ['false', error.message];
      return msg;
    }, (success) {
      List<String> msg = ['true', success];
      return msg;
    });
  }

  //Check Code OTP
  Future<List<String>> codeCheck(String code) async {
    var data = {'code': code};
    final result = await _authRepositories.codeCheck(data);
    return result.fold((error) {
      List<String> msg = ['false', error.message];
      return msg;
    }, (success) {
      List<String> msg = ['true', success];
      return msg;
    });
  }

  //Forget Chnage Password
  Future<List<String>> forgetChnagePassword(
      {required String password,
      required String confirmPassword,
      required String code}) async {
    var data = {
      'password': password,
      'code': code,
      'confirm_password': confirmPassword,
    };

    final result = await _authRepositories.forgetChangePassword(data);
    return result.fold((error) {
      List<String> msg = ['false', error.message];
      return msg;
    }, (success) {
      List<String> msg = ['true', success];
      return msg;
    });
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoriesProvider));
});
