import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_services.dart';
import 'package:toddle/featurers/resources/data/models/resource.dart';

abstract class ResourceDataSource {
  Future<List<Resource>> getResource();
}

final resourceDataSourceProvider = Provider<ResourceDataSource>((ref) {
  return ResourceDataSourceImpl(ref.watch(apiServiceProvider));
});

class ResourceDataSourceImpl extends ResourceDataSource {
  final ApiServices _apiServices;
  ResourceDataSourceImpl(this._apiServices);

  @override
  Future<List<Resource>> getResource() async {
    final result =
        await _apiServices.getDataWithAuthorize(endpoint: 'resource');
    final resources = result['data'] as List<dynamic>;
    return resources.map((resource) => Resource.fromMap(resource)).toList();
  }
}
