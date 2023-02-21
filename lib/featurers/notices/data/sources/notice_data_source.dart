import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/api/api_services.dart';
import 'package:toddle/featurers/notices/data/models/notice.dart';

abstract class NoticeDataSource {
  Future<List<Notices>> fetchNotices();
}

final noticeDataSourceProvider = Provider<NoticeDataSource>((ref) {
  return NoticeDataSourceImpl(ref.watch(apiServiceProvider));
});

class NoticeDataSourceImpl extends NoticeDataSource {
  final ApiServices _apiServices;

  NoticeDataSourceImpl(this._apiServices);
  @override
  Future<List<Notices>> fetchNotices() async {
    final result = await _apiServices.getDataWithAuthorize(endpoint: 'notices');
    final notices = result['data'] as List<dynamic>;
    return notices.map((notice) => Notices.fromMap(notice)).toList();
  }
}
