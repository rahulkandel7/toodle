import 'package:hive/hive.dart';
import 'package:toddle/featurers/offline_storage/data/models/offline_exam.dart';

class OfflineDataSource {
  static Box<OfflineExam> getOfflineExam() =>
      Hive.box<OfflineExam>('offlineexam');
}
