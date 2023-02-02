import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:toddle/constants/api_constants.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/core/utils/toaster.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/quiz/data/models/questions.dart';
import 'package:toddle/featurers/quiz/presnetation/controllers/question_controller.dart';
import 'package:toddle/featurers/quiz/presnetation/screens/quiz_result_screen.dart';

import '../../../../core/utils/count_down_timer.dart';
import '../../../home/presentation/screens/set_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  static const routeName = '/start-quiz';
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends ConsumerState<QuizScreen> {
  int i = 0;

  String? answer;
  String? selectedOptions;

  final player = AudioPlayer();

  List<Map<String, dynamic>> userSelected = [];

  //Widget For Option Box
  Widget optionBox({
    required String option,
    required String isImage,
    required Size screenSize,
    required String selectedOption,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: screenSize.height * 0.02),
      child: InkWell(
        onTap: () {
          setState(() {
            answer = option;
            selectedOptions = selectedOption;
          });
        },
        child: ListTile(
          title: isImage == 'No'
              ? Text(option)
              : CachedNetworkImage(
                  imageUrl: '${ApiConstants.answerImageUrl}$option',
                  height: screenSize.height * 0.1,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
          selected: answer == option ? true : false,
          selectedColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10,
            ),
            side: const BorderSide(
              color: AppConstants.optionBoxColor,
            ),
          ),
          enableFeedback: true,
          selectedTileColor: AppConstants.optionBoxColor,
          minLeadingWidth: double.infinity,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.stop();
  }

  @override
  Widget build(BuildContext context) {
    //MeidaQuery Screen Size
    Size screenSize = MediaQuery.of(context).size;

    //Taking Arguments
    Map args = ModalRoute.of(context)!.settings.arguments as Map;

    //Geting ExamType
    ExamType examType = args['exam'];
    //Getting set id
    int setId = args['setId'];

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                'Are you sure want to exit ?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                        SetScreen.routeName,
                        arguments: examType);
                  },
                  child: const Text(
                    'Yes',
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'No',
                  ),
                ),
              ],
            );
          },
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Toddle',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          centerTitle: true,
        ),
        body: ref.watch(questionControllerProvider(examType.id)).when(
              data: (data) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: screenSize.height * 0.02,
                        horizontal: screenSize.width * 0.04),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Showing for Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${examType.examType} Set $setId',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Text(
                              '${i + 1}/${data.length}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        const Divider(),
                        //Remaning Timer
                        CountDownTimer(time: Duration(minutes: examType.time)),

                        //Showing Question
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenSize.height * 0.03),
                          child: Center(
                            child: Text(
                              data[i].question,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),

                        data[i].isAudio == 'Yes'
                            ? IconButton(
                                onPressed: () async {
                                  //For Audio Playing
                                  await player.setUrl(
                                    '${ApiConstants.questionFileUrl}${data[i].filePath}',
                                  );
                                  player.play();
                                },
                                icon: const Icon(
                                  Icons.play_circle_outline,
                                  size: 32,
                                ),
                              )
                            : data[i].filePath != null
                                ? CachedNetworkImage(
                                    imageUrl:
                                        '${ApiConstants.questionFileUrl}${data[i].filePath}',
                                    height: screenSize.height * 0.17,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox(),
                        //Option Box
                        optionBox(
                          option: data[i].option1,
                          isImage: data[i].isImage,
                          screenSize: screenSize,
                          selectedOption: 'option1',
                        ),
                        optionBox(
                          option: data[i].option2,
                          isImage: data[i].isImage,
                          screenSize: screenSize,
                          selectedOption: 'option2',
                        ),
                        optionBox(
                          option: data[i].option3,
                          isImage: data[i].isImage,
                          screenSize: screenSize,
                          selectedOption: 'option3',
                        ),
                        optionBox(
                          option: data[i].option4,
                          isImage: data[i].isImage,
                          screenSize: screenSize,
                          selectedOption: 'option4',
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            i == 0
                                ? const Spacer()
                                : previousButton(data, examType),
                            i == data.length - 1
                                ? submitButton(data, examType)
                                : nextButton(data, examType),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              error: (e, s) => Text(e.toString()),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
      ),
    );
  }

  Padding nextButton(List<Questions> data, ExamType examType) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.tonalIcon(
          onPressed: () {
            setState(() {
              Map<String, dynamic> ua = {
                'question': data[i].id,
                'userAnswer': answer,
                'option': selectedOptions,
              };
              if (i < data.length - 1) {
                i++;

                int selectedQuestion = data[i].id;

                userSelected.length > 1
                    ? userSelected
                            .firstWhere(
                                (element) =>
                                    element['question'] == selectedQuestion,
                                orElse: () => {})
                            .isNotEmpty
                        ? userSelected[userSelected.indexWhere((element) =>
                            element['question'] == ua['question'])] = ua
                        : userSelected.add(ua)
                    : userSelected.add(ua);

                if (userSelected.length > 1) {
                  for (var users in userSelected) {
                    answer = userSelected.firstWhere((element) =>
                        element['question'] == users['question'])['userAnswer'];
                  }
                }
              }
            });
          },
          icon: const Icon(Icons.next_plan_outlined),
          label: const Text(
            'Next',
          ),
        ),
      ),
    );
  }

  Padding previousButton(List<Questions> data, ExamType examType) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.tonalIcon(
          onPressed: () {
            setState(() {
              if (i > 0) {
                i--;
              }
              if (userSelected.isNotEmpty) {
                answer = userSelected[i]['userAnswer'];
              }
            });
          },
          icon: const Icon(Icons.skip_previous_outlined),
          label: const Text(
            'Previous',
          ),
        ),
      ),
    );
  }

  Padding submitButton(List<Questions> data, ExamType examType) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Consumer(
          builder: (context, ref, child) {
            return FilledButton.tonal(
              onPressed: () {
                setState(() {
                  Map<String, dynamic> ua = {
                    'question': data[i].id,
                    'userAnswer': answer,
                    'option': selectedOptions,
                  };

                  userSelected.length > 1
                      ? userSelected
                              .firstWhere(
                                  (element) =>
                                      element['question'] == ua['question'],
                                  orElse: () => {})
                              .isNotEmpty
                          ? userSelected[userSelected.indexWhere((element) =>
                              element['question'] == ua['question'])] = ua
                          : userSelected.add(ua)
                      : userSelected.add(ua);

                  if (userSelected.length > 1) {
                    for (var users in userSelected) {
                      answer = userSelected.firstWhere((element) =>
                          element['question'] ==
                          users['question'])['userAnswer'];
                    }
                  }
                });
                List<String> questionIds = [];
                List<String> selectedAnswers = [];

                for (var userAnswer in userSelected) {
                  questionIds.add(userAnswer['question'].toString());
                  selectedAnswers.add(userAnswer['option'].toString());
                }

                ref
                    .read(questionControllerProvider(examType.id).notifier)
                    .submitAnswer(
                        questions: questionIds, answers: selectedAnswers)
                    .then((value) {
                  if (value[0] == 'false') {
                    toast(context: context, label: value[1], color: Colors.red);
                  } else {
                    List<String> msg = [value[1], value[2]];
                    Navigator.of(context).pushReplacementNamed(
                        QuizResultScreen.routeName,
                        arguments: msg);
                  }
                });
              },
              child: const Text(
                'Submit',
              ),
            );
          },
        ),
      ),
    );
  }
}
