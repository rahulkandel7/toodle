import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/home/presentation/screens/widgets/set_card.dart';

class SetScreen extends ConsumerStatefulWidget {
  static const routeName = '/set';
  const SetScreen({super.key});

  @override
  SetScreenState createState() => SetScreenState();
}

class SetScreenState extends ConsumerState<SetScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ExamType exam = ModalRoute.of(context)!.settings.arguments as ExamType;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          exam.examType,
          style: Theme.of(context).textTheme.displaySmall,
        ),
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
                'Select Exam Set',
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
    );
  }
}
