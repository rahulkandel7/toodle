import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/home/presentation/screens/widgets/set_card.dart';
import 'package:toddle/featurers/my_paper/data/models/exam.dart';

import '../../../my_paper/presentation/controllers/my_paper_controller.dart';

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
    ref.read(myPaperControllerProvider.notifier).fetchMyPaper();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ExamType exam = ModalRoute.of(context)!.settings.arguments as ExamType;
    List<Exam>? exams =
        ref.watch(myPaperControllerProvider.notifier).state.value;
    int length =
        exams!.where((ele) => ele.examType == exam.examType).toList().length;

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
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'This ${exam.examType} exam system generate 40 questions randomly from the set of more than 11000 questions',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Divider(),
              SizedBox(
                height: screenSize.height * 0.8,
                child: ListView.builder(
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
                    child: SetCard(
                      setNumber: i + 1,
                      exam: exam,
                      length: length,
                    ),
                  ),
                  itemCount: int.parse(exam.maxModelSet),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
