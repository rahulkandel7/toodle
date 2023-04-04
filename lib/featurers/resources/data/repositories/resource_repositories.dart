import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_error.dart';
import 'package:toddle/core/api/dio_exception.dart';
import 'package:toddle/featurers/resources/data/sources/resource_data_source.dart';

import '../models/resource.dart';

abstract class ResourceRepository {
  Future<Either<ApiError, List<Resource>>> getResource();
}

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return ResourceRespositoryImpl(ref.watch(resourceDataSourceProvider));
});

class ResourceRespositoryImpl extends ResourceRepository {
  final ResourceDataSource _resourceDataSource;

  ResourceRespositoryImpl(this._resourceDataSource);

  @override
  Future<Either<ApiError, List<Resource>>> getResource() async {
    try {
      final result = await _resourceDataSource.getResource();
      return right(result);
    } on DioException catch (e) {
      return left(ApiError(message: e.message!));
    }
  }
}
