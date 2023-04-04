import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/resources/data/models/resource.dart';
import 'package:toddle/featurers/resources/data/repositories/resource_repositories.dart';

class ResourceController extends StateNotifier<AsyncValue<List<Resource>>> {
  final ResourceRepository _resourceRepository;

  ResourceController(this._resourceRepository) : super(const AsyncLoading()) {
    fetchResource();
  }

  fetchResource() async {
    final result = await _resourceRepository.getResource();
    result.fold(
        (l) =>
            state = AsyncError(l.message, StackTrace.fromString(l.toString())),
        (r) => state = AsyncData(r));
  }
}

final resourceControllerProvider =
    StateNotifierProvider<ResourceController, AsyncValue<List<Resource>>>(
        (ref) {
  return ResourceController(ref.watch(resourceRepositoryProvider));
});
