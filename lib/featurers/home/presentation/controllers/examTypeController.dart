import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/home/data/models/ExamType.dart';
import 'package:toddle/featurers/home/data/repositories/exam_type_repositories.dart';

class ExamTypeController extends StateNotifier<AsyncValue<List<ExamType>>> {
  final ExamTypeRepositories _examTypeRepositories;
  ExamTypeController(this._examTypeRepositories) : super(const AsyncLoading()) {
    fetchExamType();
  }

  fetchExamType() async {
    final result = await _examTypeRepositories.getExamType();
    result.fold(
      (l) => state = AsyncError(
        l.message,
        StackTrace.fromString(
          l.message,
        ),
      ),
      (r) => state = AsyncData(r),
    );
  }
}

final examTypeControllerProvider =
    StateNotifierProvider<ExamTypeController, AsyncValue<List<ExamType>>>(
        (ref) {
  return ExamTypeController(
    ref.watch(examTypeRepositoriesProvider),
  );
});
