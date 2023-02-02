import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/core/api/api_services.dart';

abstract class AuthDataSource {
  Future<String> login(var data);
  Future<String> register(var data);
  Future<String> logout();
  Future<String> sendPasswordResetLink(var data);
  Future<String> checkCode(var data);
  Future<String> forgetChnagePassword(var data);
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
}
