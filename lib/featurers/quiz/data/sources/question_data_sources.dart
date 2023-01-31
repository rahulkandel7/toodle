import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_services.dart';
import 'package:toddle/featurers/quiz/data/models/questions.dart';

abstract class QuestionDataSource {
  Future<List<Questions>> fetchQuestion(int id);
}

final questionDataSourceProvider = Provider<QuestionDataSource>((ref) {
  return QuestionDataSourceImpl(ref.watch(apiServiceProvider));
});

class QuestionDataSourceImpl implements QuestionDataSource {
  final ApiServices _apiServices;
  QuestionDataSourceImpl(this._apiServices);

  @override
  Future<List<Questions>> fetchQuestion(int id) async {
    final result =
        await _apiServices.getDataWithAuthorize(endpoint: '/startexam/$id');
    final questions = result['data'] as List<dynamic>;
    return questions.map((question) => Questions.fromMap(question)).toList();
  }
}
