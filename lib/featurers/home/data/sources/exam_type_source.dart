import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_services.dart';
import 'package:toddle/featurers/home/data/models/ExamType.dart';

abstract class ExamTypeDataSource {
  Future<List<ExamType>> fetchExamType();
}

final examTypeDataSourceProvider = Provider<ExamTypeDataSource>((ref) {
  return ExamTypeDataSourceImpl(ref.watch(apiServiceProvider));
});

class ExamTypeDataSourceImpl implements ExamTypeDataSource {
  final ApiServices _apiServices;
  ExamTypeDataSourceImpl(this._apiServices);

  @override
  Future<List<ExamType>> fetchExamType() async {
    final result =
        await _apiServices.getDataWithAuthorize(endpoint: 'exam-types');
    final examTypes = result['data'] as List<dynamic>;
    return examTypes.map((examType) => ExamType.fromMap(examType)).toList();
  }
}
