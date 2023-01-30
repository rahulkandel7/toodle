import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_error.dart';
import 'package:toddle/core/api/dio_exception.dart';

import '../data_sources/auth_data_sources.dart';

abstract class AuthRepositories {
  Future<Either<ApiError, String>> login(var data);
  Future<Either<ApiError, String>> register(var data);
  Future<Either<ApiError, String>> sendPasswordResetLink(var data);
  Future<Either<ApiError, String>> codeCheck(var data);
  Future<Either<ApiError, String>> forgetChangePassword(var data);
}

final authRepositoriesProvider = Provider<AuthRepositories>((ref) {
  return AuthRepositoriesImpl(ref.watch(authDataSourceProvider));
});

class AuthRepositoriesImpl implements AuthRepositories {
  final AuthDataSource _authDataSource;

  AuthRepositoriesImpl(this._authDataSource);
  @override
  Future<Either<ApiError, String>> login(data) async {
    try {
      final result = await _authDataSource.login(data);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiError(
          message: e.message!,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, String>> register(data) async {
    try {
      final result = await _authDataSource.register(data);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiError(
          message: e.message!,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, String>> sendPasswordResetLink(var data) async {
    try {
      final result = await _authDataSource.sendPasswordResetLink(data);
      return right(result);
    } on DioException catch (e) {
      return Left(
        ApiError(
          message: e.message!,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, String>> codeCheck(data) async {
    try {
      final result = await _authDataSource.checkCode(data);
      return right(result);
    } on DioException catch (e) {
      return Left(
        ApiError(
          message: e.message!,
        ),
      );
    }
  }

  @override
  Future<Either<ApiError, String>> forgetChangePassword(data) async {
    try {
      final result = await _authDataSource.forgetChnagePassword(data);
      return right(result);
    } on DioException catch (e) {
      return left(ApiError(message: e.message!));
    }
  }
}
