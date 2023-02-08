import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/featurers/auth/data/models/user.dart';
import 'package:toddle/featurers/auth/data/repositories/auth_repositories.dart';

class AuthController extends StateNotifier<AsyncValue<User>> {
  AuthController(this._authRepositories) : super(const AsyncLoading()) {
    getUser();
  }

  final AuthRepositories _authRepositories;

//Login Method
  Future<List<String>> login({
    required String email,
    required String password,
  }) async {
    var data = {
      'email': email,
      'password': password,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final result = await _authRepositories.login(data);
    return result.fold((error) {
      List<String> msg = ['false', error.message];
      return msg;
    }, (success) {
      //Adding Data to Shared Prefs
      prefs.setString('email', email);
      prefs.setString('password', password);
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

  //For Changing Password
  Future<List<String>> changePassword(
      {required String oldPassword, required String newPassword}) async {
    var data = {'current_password': oldPassword, 'new_password': newPassword};
    final result = await _authRepositories.changePassword(data);
    return result.fold((error) {
      List<String> msg = ['false', error.message];
      return msg;
    }, (success) {
      List<String> msg = ['true', success];
      return msg;
    });
  }

  //Get Useser Info
  getUser() async {
    final result = await _authRepositories.getUser();
    result.fold(
        (error) => state = AsyncError(
              error.message,
              StackTrace.fromString(
                error.message,
              ),
            ),
        (success) => state = AsyncData(success));
  }

  //Update User Info
  Future<List<String>> updateInfo({required User user}) async {
    var data = {
      'name': user.name,
      'email': user.email,
      'phone': user.phoneNumber,
      'address': user.address
    };
    final result = await _authRepositories.updateInfo(data);
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
    StateNotifierProvider<AuthController, AsyncValue<User>>((ref) {
  return AuthController(ref.watch(authRepositoriesProvider));
});
