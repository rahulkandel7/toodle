import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/core/darkmode_notifier.dart';
import 'package:toddle/featurers/home/presentation/screens/first_screen.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_view_paper.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  static const String routeName = '/quiz-submit';
  const QuizResultScreen({super.key});

  @override
  QuizResultScreenState createState() => QuizResultScreenState();
}

class QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  String username = "";
  _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = jsonDecode(prefs.getString('user')!)['name'];
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Widget textWithValue({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> message =
        ModalRoute.of(context)!.settings.arguments as List<String>;
    bool isDarkMode = ref.watch(darkmodeNotifierProvider);
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //* For Name
              textWithValue(title: 'Name : ', value: username),

              // * For Exam Date
              textWithValue(
                  title: 'Exam Date : ',
                  value:
                      '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}'),
              const Divider(),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade500
                      : AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(2, 3),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    textWithValue(
                      title: 'Total Questions : ',
                      value: message[0],
                    ),
                    textWithValue(
                      title: 'Total Score : ',
                      value: message[1],
                    ),
                    textWithValue(
                      title: 'Percentage : ',
                      value:
                          '${((int.parse(message[1]) / int.parse(message[0])) * 100).toStringAsFixed(2)} %',
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> data = {
                      'isHistory': false,
                      'id': message[2],
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
      ),
    );
  }
}
