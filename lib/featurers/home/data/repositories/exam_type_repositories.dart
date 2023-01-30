import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_error.dart';
import 'package:toddle/core/api/dio_exception.dart';
import 'package:toddle/featurers/home/data/models/ExamType.dart';
import 'package:toddle/featurers/home/data/sources/exam_type_source.dart';

abstract class ExamTypeRepositories {
  Future<Either<ApiError, List<ExamType>>> getExamType();
}

final examTypeRepositoriesProvider = Provider<ExamTypeRepositories>((ref) {
  return ExamTypeRepositoriesImpl(ref.watch(examTypeDataSourceProvider));
});

class ExamTypeRepositoriesImpl implements ExamTypeRepositories {
  final ExamTypeDataSource _examTypeDataSource;
  ExamTypeRepositoriesImpl(this._examTypeDataSource);
  @override
  Future<Either<ApiError, List<ExamType>>> getExamType() async {
    try {
      final result = await _examTypeDataSource.fetchExamType();
      return right(result);
    } on DioException catch (e) {
      return left(
        ApiError(
          message: e.message!,
        ),
      );
    }
  }
}
