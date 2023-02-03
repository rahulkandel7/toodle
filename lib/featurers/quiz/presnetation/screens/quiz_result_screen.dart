import 'package:flutter/material.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_view_paper.dart';

class QuizResultScreen extends StatelessWidget {
  static const String routeName = '/quiz-submit';
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> message =
        ModalRoute.of(context)!.settings.arguments as List<String>;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Toddle',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message[0],
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(QuizViewPaper.routeName, arguments: message[1]);
              },
              child: const Text(
                'View paper',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
