import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/my_paper/data/models/exam.dart';
import 'package:toddle/featurers/my_paper/data/repositories/my_paper_repositories.dart';

class MyPaperController extends StateNotifier<AsyncValue<List<Exam>>> {
  final MyPaperRepositories _myPaperRepositories;
  MyPaperController(this._myPaperRepositories) : super(const AsyncLoading()) {
    fetchMyPaper();
  }

  fetchMyPaper() async {
    final result = await _myPaperRepositories.fetchExam();
    result.fold(
        (error) => state =
            AsyncError(error.message, StackTrace.fromString(error.message)),
        (success) => state = AsyncData(success));
  }
}

final myPaperControllerProvider =
    StateNotifierProvider<MyPaperController, AsyncValue<List<Exam>>>((ref) {
  return MyPaperController(ref.watch(myPaperRepositoryProvider));
});
