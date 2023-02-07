import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_error.dart';
import 'package:toddle/core/api/dio_exception.dart';
import 'package:toddle/featurers/my_paper/data/models/exam.dart';
import 'package:toddle/featurers/my_paper/data/sources/my_paper_data_source.dart';

abstract class MyPaperRepositories {
  Future<Either<ApiError, List<Exam>>> fetchExam();
}

final myPaperRepositoryProvider = Provider<MyPaperRepositories>((ref) {
  return MyPaperRepositoryImpl(ref.watch(myPaperDataSourceProvider));
});

class MyPaperRepositoryImpl implements MyPaperRepositories {
  final MyPaperDataSource _myPaperDataSource;
  MyPaperRepositoryImpl(this._myPaperDataSource);

  @override
  Future<Either<ApiError, List<Exam>>> fetchExam() async {
    try {
      final result = await _myPaperDataSource.getExam();
      return right(result);
    } on DioException catch (e) {
      return left(ApiError(message: e.message!));
    }
  }
}
