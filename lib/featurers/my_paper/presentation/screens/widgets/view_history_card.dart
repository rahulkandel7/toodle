import 'package:flutter/material.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_view_paper.dart';

class ViewHistoryCard extends StatelessWidget {
  final int id;
  final String date;
  final String examType;
  final String obtainedMark;
  final bool show;
  final bool darkMode;
  const ViewHistoryCard(
      {required this.id,
      required this.date,
      required this.examType,
      required this.obtainedMark,
      required this.show,
      required this.darkMode,
      super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: ListTile(
        tileColor: darkMode ? Colors.grey.shade800 : Colors.indigo.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examType,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: darkMode ? Colors.white : Colors.black,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(
                      'You Have Got $obtainedMark out of 40',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: darkMode
                              ? Colors.grey.shade200
                              : Colors.grey.shade700),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0, top: 8.0),
                    child: Text(
                      date,
                      style: TextStyle(
                        color: darkMode
                            ? Colors.grey.shade200
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              show
                  ? OutlinedButton(
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
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
