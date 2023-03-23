import 'package:flutter/material.dart';
import 'package:toddle/core/utils/toaster.dart';
import 'package:toddle/featurers/offline_storage/data/models/offline_question.dart';
import 'package:toddle/featurers/offline_storage/data/sources/offline_data_source.dart';
import 'package:toddle/featurers/offline_storage/presentation/screens/start_offline_exam.dart';

class DownloadedExamCard extends StatelessWidget {
  final String setNumber;
  final String examType;
  final String id;
  final List<OfflineQuestions> questions;

  const DownloadedExamCard({
    super.key,
    required this.examType,
    required this.id,
    required this.setNumber,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Card(
      elevation: 7,
      shadowColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EPS-TOPIK',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              examType,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Model Question',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Set $setNumber',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Divider(
              color: Colors.grey.shade400,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Delete Button
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    final boxes = OfflineDataSource.getOfflineExam();
                    boxes.delete('$examType$setNumber').then(
                      (value) {
                        toast(
                            context: context,
                            label: 'Exam deleted successfully',
                            color: Colors.green);
                      },
                    ).onError((error, stackTrace) {
                      toast(
                          context: context,
                          label: 'Error while deleting exam',
                          color: Colors.red);
                    });
                  },
                  child: const Text(
                    'Delete Exam',
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                // Start Exam Button
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      StartOfflineExam.routeName,
                      arguments: questions,
                    );
                  },
                  child: const Text(
                    'Start Exam',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
