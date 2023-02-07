import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_services.dart';
import 'package:toddle/featurers/my_paper/data/models/exam.dart';

abstract class MyPaperDataSource {
  Future<List<Exam>> getExam();
}

final myPaperDataSourceProvider = Provider<MyPaperDataSource>((ref) {
  return MyPaperDataSourcesImpl(ref.watch(apiServiceProvider));
});

class MyPaperDataSourcesImpl extends MyPaperDataSource {
  final ApiServices _apiServices;

  MyPaperDataSourcesImpl(this._apiServices);
  @override
  Future<List<Exam>> getExam() async {
    final result =
        await _apiServices.getDataWithAuthorize(endpoint: 'all/exams');
    var exams = result['data'] as List<dynamic>;
    return exams.map((exam) => Exam.fromMap(exam)).toList();
  }
}
