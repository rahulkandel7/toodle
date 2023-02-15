import 'package:flutter/material.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_view_paper.dart';

class ViewHistoryCard extends StatelessWidget {
  final int id;
  final String date;
  final String examType;
  const ViewHistoryCard(
      {required this.id,
      required this.date,
      required this.examType,
      super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: ListTile(
        tileColor: Colors.indigo.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            examType,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Text(
            date,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            onPressed: () {
              Map<String, dynamic> data = {
                'isHistory': true,
                'id': id,
              };
              Navigator.of(context).pushNamed(
                QuizViewPaper.routeName,
                arguments: data,
              );
            },
            child: const Text(
              'View Paper',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
