import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_error.dart';
import 'package:toddle/core/api/dio_exception.dart';
import 'package:toddle/featurers/quiz/data/models/questions.dart';
import 'package:toddle/featurers/quiz/data/sources/question_data_sources.dart';

abstract class QuestionRepositories {
  Future<Either<ApiError, List<Questions>>> fetchQuestion(int id);
  Future<Either<ApiError, List<String>>> submitAnswer(var data);
  Future<Either<ApiError, List<Questions>>> viewPaper(String id);
}

final questionRepositoriesProvider = Provider<QuestionRepositories>((ref) {
  return QuestionRepositoriesImpl(ref.watch(questionDataSourceProvider));
});

class QuestionRepositoriesImpl implements QuestionRepositories {
  final QuestionDataSource _questionDataSource;
  QuestionRepositoriesImpl(this._questionDataSource);

  @override
  Future<Either<ApiError, List<Questions>>> fetchQuestion(int id) async {
    try {
      final result = await _questionDataSource.fetchQuestion(id);
      return right(result);
    } on DioException catch (e) {
      return left(ApiError(message: e.message!));
    }
  }

  @override
  Future<Either<ApiError, List<String>>> submitAnswer(data) async {
    try {
      final result = await _questionDataSource.submitAnswer(data);
      return right(result);
    } on DioException catch (e) {
      return left(ApiError(message: e.message!));
    }
  }

  @override
  Future<Either<ApiError, List<Questions>>> viewPaper(String id) async {
    try {
      final result = await _questionDataSource.viewPaper(id);
      return right(result);
    } on DioException catch (e) {
      return left(ApiError(message: e.message!));
    }
  }
}
