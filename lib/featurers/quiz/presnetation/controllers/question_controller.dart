import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/quiz/data/models/questions.dart';
import 'package:toddle/featurers/quiz/data/repositories/question_repositories.dart';

class QuestionController extends StateNotifier<AsyncValue<List<Questions>>> {
  final QuestionRepositories _questionRepositories;
  final int id;
  QuestionController(this._questionRepositories, this.id)
      : super(const AsyncLoading()) {
    fetchQUestions(id);
  }

  fetchQUestions(int id) async {
    final result = await _questionRepositories.fetchQuestion(id);
    result.fold(
      (error) =>
          state = AsyncError(error, StackTrace.fromString(error.message)),
      (success) => state = AsyncData(success),
    );
  }

  Future<List<String>> submitAnswer(
      {required List<String> questions, required List<String> answers}) async {
    var data = {'questions': questions.toString(), 'answers': answers};

    final result = await _questionRepositories.submitAnswer(data);
    return result.fold((error) {
      List<String> msg = ['false', error.message];
      return msg;
    }, (success) {
      List<String> msg = ['true', success[0], success[1]];
      return msg;
    });
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

final questionControllerProvider = StateNotifierProvider.family
    .autoDispose<QuestionController, AsyncValue<List<Questions>>, int>(
        (ref, id) {
  return QuestionController(ref.watch(questionRepositoriesProvider), id);
});
