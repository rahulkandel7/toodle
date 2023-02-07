import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/core/api/api_services.dart';

abstract class AuthDataSource {
  //For Login user
  Future<String> login(var data);

  //FOr Register user
  Future<String> register(var data);

  //For Logout User
  Future<String> logout();

  //For Sending Code in gmail
  Future<String> sendPasswordResetLink(var data);

  //For Checking Code
  Future<String> checkCode(var data);

  //For Changeing Forget Password
  Future<String> forgetChnagePassword(var data);

  //For Changing Password through edit profile
  Future<String> changePassword(var data);
}

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSourceImpl(ref.watch(apiServiceProvider));
});

class AuthDataSourceImpl implements AuthDataSource {
  final ApiServices _apiServices;
  AuthDataSourceImpl(this._apiServices);

  @override
  Future<String> login(data) async {
    final result = await _apiServices.postData(endPoint: 'login', data: data);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', result['token']);
    return result['message'];
  }

  @override
  Future<String> register(data) async {
    final result =
        await _apiServices.postData(endPoint: 'register', data: data);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', result['token']);
    return result['message'];
  }

  @override
  Future<String> sendPasswordResetLink(var data) async {
    final result =
        await _apiServices.postData(endPoint: 'password/email', data: data);

    return result['message'];
  }

  @override
  Future<String> checkCode(data) async {
    final result = await _apiServices.postData(
        endPoint: 'password/code/check', data: data);
    return result['message'];
  }

  @override
  Future<String> forgetChnagePassword(data) async {
    final result =
        await _apiServices.postData(endPoint: 'password/reset', data: data);
    return result['message'];
  }

  @override
  Future<String> logout() async {
    final result = await _apiServices.postDataWithAuthorize(endpoint: 'logout');

    return result['message'];
  }

  @override
  Future<String> changePassword(data) async {
    final result = await _apiServices.postDataWithAuthorize(
        endpoint: 'change/password', data: data);
    return result['message'];
  }
}
