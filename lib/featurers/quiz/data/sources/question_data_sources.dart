import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_services.dart';
import 'package:toddle/featurers/quiz/data/models/questions.dart';

abstract class QuestionDataSource {
  Future<List<Questions>> fetchQuestion(int id);
  Future<List<String>> submitAnswer(var data);
  Future<List<Questions>> viewPaper(String id);
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
        await _apiServices.getDataWithAuthorize(endpoint: '/start-exam/$id');

    final questions = result['data'] as List<dynamic>;
    final allQuestions = questions.where((element) => element != null);
    return allQuestions.map((question) => Questions.fromMap(question)).toList();
  }

  @override
  Future<List<String>> submitAnswer(var data) async {
    final result = await _apiServices.postDataWithAuthorize(
        endpoint: 'submitexam', data: data);
    List<String> message = [
      result['totalmarks'].toString(),
      result['obtainedmarks'].toString(),
      result['id'].toString()
    ];
    return message;
  }

  @override
  Future<List<Questions>> viewPaper(String id) async {
    final result =
        await _apiServices.getDataWithAuthorize(endpoint: 'viewpaper/$id');
    final questions = result['data'] as List<dynamic>;
    return questions.map((question) => Questions.fromMap(question)).toList();
  }
}
