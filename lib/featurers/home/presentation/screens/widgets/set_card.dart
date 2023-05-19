import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/core/utils/toaster.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/offline_storage/data/sources/offline_data_source.dart';
import 'package:toddle/featurers/offline_storage/presentation/controllers/offline_storage_controller.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_screen.dart';

import '../../../../my_paper/presentation/controllers/my_paper_controller.dart';

class SetCard extends StatelessWidget {
  final int setNumber;
  final ExamType exam;
  final int length;
  const SetCard(
      {required this.setNumber,
      required this.exam,
      required this.length,
      super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final downloadedExam = OfflineDataSource.getOfflineExam()
        .get('${exam.examType}${length + setNumber}');
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
              exam.examType,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Model Question',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Set ${length + setNumber}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
              child: Row(
                children: [
                  const Icon(Icons.alarm),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${exam.time} minutes',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey.shade400,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Download Exam Button
                downloadedExam == null
                    ? Consumer(
                        builder: (context, ref, child) {
                          return FilledButton(
                            onPressed: () {
                              Future<bool> isComplete = ref
                                  .read(offlineStorageProvider)
                                  .storeInHive(
                                    setNumber: (length + setNumber).toString(),
                                    examType: exam.examType,
                                    id: exam.id,
                                  );

                              isComplete.then((value) {
                                if (value) {
                                  toast(
                                      context: context,
                                      label: 'Download Completed',
                                      color: Colors.indigo);
                                  ref.invalidate(myPaperControllerProvider);
                                } else {
                                  toast(
                                      context: context,
                                      label: 'Download failed',
                                      color: Colors.red);
                                }
                              });
                            },
                            child: const Text(
                              'Download Exam',
                            ),
                          );
                        },
                      )
                    :
                    // Start Exam Button
                    FilledButton(
                        onPressed: () {
                          Map args = {
                            'exam': exam,
                            'setId': setNumber,
                          };
                          Navigator.of(context).pushNamed(
                            QuizScreen.routeName,
                            arguments: args,
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
