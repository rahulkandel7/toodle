import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toddle/featurers/offline_storage/data/models/offline_exam.dart';
import 'package:toddle/featurers/offline_storage/data/sources/offline_data_source.dart';
import 'package:toddle/featurers/offline_storage/presentation/screens/widgets/downloaded_exam_card.dart';

class DownloadedExamScreens extends StatelessWidget {
  static const routeName = '/downloaded-exam';

  const DownloadedExamScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Offline Exam'),
          elevation: 0,
        ),
        body: ValueListenableBuilder<Box<OfflineExam>>(
          valueListenable: OfflineDataSource.getOfflineExam().listenable(),
          builder: ((context, box, _) {
            final downloadedExams = box.values.toList().cast<OfflineExam>();
            return downloadedExams.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemBuilder: (ctx, i) {
                        return DownloadedExamCard(
                          id: '${downloadedExams[i].examType}${downloadedExams[i].setNumber}',
                          examType: downloadedExams[i].examType,
                          setNumber: downloadedExams[i].setNumber,
                          questions: downloadedExams[i].questions,
                        );
                      },
                      itemCount: downloadedExams.length,
                    ),
                  )
                : const Center(
                    child: Text('No Downloaded Exams yet'),
                  );
          }),
        ));
  }
}
