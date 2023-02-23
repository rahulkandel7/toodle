import 'package:flutter/material.dart';
import 'package:toddle/featurers/home/presentation/screens/first_screen.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_view_paper.dart';

class QuizResultScreen extends StatelessWidget {
  static const String routeName = '/quiz-submit';
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> message =
        ModalRoute.of(context)!.settings.arguments as List<String>;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .popUntil(ModalRoute.withName(FirstScreen.routeName));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Toddle',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(FirstScreen.routeName);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
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
                  Map<String, dynamic> data = {
                    'isHistory': false,
                    'id': message[1],
                  };
                  Navigator.of(context)
                      .pushNamed(QuizViewPaper.routeName, arguments: data);
                },
                child: const Text(
                  'View paper',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
