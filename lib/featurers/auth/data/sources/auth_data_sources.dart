import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/core/api/api_services.dart';
import 'package:toddle/featurers/auth/data/models/group.dart';

import '../models/user.dart';

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

  //Get User Info
  Future<User> getUser();

  //Update user info
  Future<String> updateInfo(var data);

  // Fech Group
  Future<List<Group>> fetchGroup();
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
    prefs.setString('user', jsonEncode(result['user']));
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

  @override
  Future<User> getUser() async {
    final result = await _apiServices.getDataWithAuthorize(endpoint: 'user');
    return User.fromMap(result['data']);
  }

  @override
  Future<String> updateInfo(data) async {
    final result = await _apiServices.postDataWithAuthorize(
        endpoint: 'user/update', data: data);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(result['data']));
    return result['message'];
  }

  @override
  Future<List<Group>> fetchGroup() async {
    final result = await _apiServices.getData(endpoint: 'groups');
    final groups = result['data'] as List<dynamic>;
    return groups.map((group) => Group.fromMap(group)).toList();
  }
}
