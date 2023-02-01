import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/questions.dart';
import '../../data/repositories/question_repositories.dart';

class ViewPaperController extends StateNotifier<AsyncValue<List<Questions>>> {
  final QuestionRepositories _questionRepositories;
  final String id;
  ViewPaperController(this._questionRepositories, this.id)
      : super(const AsyncLoading()) {
    viewPaper(id);
  }

  viewPaper(String id) async {
    final result = await _questionRepositories.viewPaper(id);
    result.fold(
      (error) =>
          state = AsyncError(error, StackTrace.fromString(error.message)),
      (success) => state = AsyncData(success),
    );
  }
}

final viewPaperControllerProvider = StateNotifierProvider.family
    .autoDispose<ViewPaperController, AsyncValue<List<Questions>>, String>(
        (ref, id) {
  return ViewPaperController(ref.watch(questionRepositoriesProvider), id);
});
