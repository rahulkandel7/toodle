import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_error.dart';
import 'package:toddle/core/api/dio_exception.dart';
import 'package:toddle/featurers/notices/data/models/notice.dart';
import 'package:toddle/featurers/notices/data/sources/notice_data_source.dart';

abstract class NoticeRepository {
  Future<Either<ApiError, List<Notices>>> fetchNotice();
}

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepositoryImpl(ref.watch(noticeDataSourceProvider));
});

class NoticeRepositoryImpl extends NoticeRepository {
  final NoticeDataSource _noticeDataSource;

  NoticeRepositoryImpl(this._noticeDataSource);
  @override
  Future<Either<ApiError, List<Notices>>> fetchNotice() async {
    try {
      final result = await _noticeDataSource.fetchNotices();
      return right(result);
    } on DioException catch (e) {
      return left(ApiError(message: e.message!));
    }
  }
}
