import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/notices/data/models/notice.dart';
import 'package:toddle/featurers/notices/data/repositories/notice_repositories.dart';

class NoticeController extends StateNotifier<AsyncValue<List<Notices>>> {
  final NoticeRepository _noticeRepository;
  NoticeController(this._noticeRepository) : super(const AsyncLoading()) {
    fetchNotice();
  }

  fetchNotice() async {
    final result = await _noticeRepository.fetchNotice();
    result.fold(
        (error) =>
            state = AsyncError(error, StackTrace.fromString(error.toString())),
        (success) => state = AsyncData(success));
  }
}

final noticeControllerProvider = StateNotifierProvider.autoDispose<
    NoticeController, AsyncValue<List<Notices>>>((ref) {
  return NoticeController(ref.watch(noticeRepositoryProvider));
});
