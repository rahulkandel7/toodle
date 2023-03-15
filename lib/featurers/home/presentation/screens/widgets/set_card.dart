import 'package:flutter/material.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_screen.dart';

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
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
