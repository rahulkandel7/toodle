import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/home/presentation/screens/home_screen.dart';
import 'package:toddle/featurers/home/presentation/screens/widgets/set_card.dart';

class SetScreen extends ConsumerWidget {
  static const routeName = '/set';
  const SetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size screenSize = MediaQuery.of(context).size;
    ExamType exam = ModalRoute.of(context)!.settings.arguments as ExamType;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamed(HomeScreen.routeName);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Toddle',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.02,
              horizontal: screenSize.width * 0.04,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select ${exam.examType} Set',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                const Divider(),
                for (var i = 0; i < int.parse(exam.maxModelSet); i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
                    child: SetCard(
                      setNumber: i + 1,
                      exam: exam,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
