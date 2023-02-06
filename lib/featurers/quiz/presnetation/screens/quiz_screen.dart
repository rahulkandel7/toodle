import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  //For Total Question Showing
  bool isTotalQuestion = false;

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
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
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

    //Getting Timer Data
    CountDownTimer counter =
        CountDownTimer(time: Duration(minutes: examType.time));

    return ref.watch(questionControllerProvider(examType.id)).when(
          data: (data) {
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
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitUp,
                            ]);
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
                  automaticallyImplyLeading: false,
                  actions: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Toddle'),
                            Text('Total Question: ${data.length}'),
                            Text('Solved Question: ${userSelected.length}'),
                            Text(
                                'Unsolved Question: ${data.length - userSelected.length}'),
                            // CountDownTimer(time: Duration(minutes: examType.time)),
                            counter,
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                body: isTotalQuestion
                    ? totalQuestionsView(screenSize, examType)
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.04,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const Divider(),
                              SizedBox(
                                height: screenSize.height * 0.6,
                                child: GridView(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20.0,
                                  ),
                                  children: [
                                    Column(
                                      children: [
                                        //Showing Question
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: screenSize.height * 0.03,
                                            horizontal: 3.0,
                                          ),
                                          child: Text(
                                              '${i + 1}. ${data[i].question}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
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
                                                    height: screenSize.height *
                                                        0.17,
                                                    width:
                                                        screenSize.width * 0.4,
                                                    placeholder:
                                                        (context, url) =>
                                                            const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                      ],
                                    ),
                                    Column(
                                      children: [
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    i == 0
                                        ? const SizedBox.shrink()
                                        : previousButton(data, examType),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            side: const BorderSide(
                                              color:
                                                  AppConstants.optionBoxColor,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isTotalQuestion = true;
                                          });
                                        },
                                        child: const Text(
                                          'Total Questions',
                                        ),
                                      ),
                                    ),
                                    i == data.length - 1
                                        ? submitButton(data, examType)
                                        : nextButton(data, examType),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            );
          },
          error: (e, s) => Text(e.toString()),
          loading: () => const Center(
            child: CircularProgressIndicator(),
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
                'questionNumber': i + 1,
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
                  answer = userSelected.firstWhere(
                      (element) => element['question'] == selectedQuestion,
                      orElse: () => {})['userAnswer'];
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
                    'questionNumber': i + 1,
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
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                    ]);
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

  Padding totalQuestionsView(Size screenSize, ExamType examType) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
      ),
      child: Column(
        children: [
          SizedBox(
            height: screenSize.height * 0.68,
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
              ),
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.chrome_reader_mode_outlined,
                            color: AppConstants.optionBoxColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('(20 Questions)'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.6,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                isTotalQuestion = false;
                                i = index;
                              });
                            },
                            child: Card(
                              color: userSelected
                                      .firstWhere(
                                          (element) =>
                                              element['questionNumber'] ==
                                              index + 1,
                                          orElse: () => {})
                                      .isNotEmpty
                                  ? AppConstants.optionBoxColor
                                  : Colors.deepPurple.shade50,
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: userSelected
                                            .firstWhere(
                                                (element) =>
                                                    element['questionNumber'] ==
                                                    index + 1,
                                                orElse: () => {})
                                            .isNotEmpty
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: 20,
                      ),
                    ),
                  ],
                ),

                //Listening Questions Number
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.headphones,
                            color: AppConstants.optionBoxColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('(20 Questions)'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.6,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                isTotalQuestion = false;
                                i = index;
                              });
                            },
                            child: Card(
                              color: userSelected
                                      .firstWhere(
                                          (element) =>
                                              element['questionNumber'] ==
                                              index + 21,
                                          orElse: () => {})
                                      .isNotEmpty
                                  ? AppConstants.optionBoxColor
                                  : Colors.deepPurple.shade50,
                              child: Center(
                                child: Text(
                                  '${index + 21}',
                                  style: TextStyle(
                                    color: userSelected
                                            .firstWhere(
                                                (element) =>
                                                    element['questionNumber'] ==
                                                    index + 21,
                                                orElse: () => {})
                                            .isNotEmpty
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                  onPressed: () {
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
                        toast(
                            context: context,
                            label: value[1],
                            color: Colors.red);
                      } else {
                        List<String> msg = [value[1], value[2]];
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                        ]);
                        Navigator.of(context).pushReplacementNamed(
                            QuizResultScreen.routeName,
                            arguments: msg);
                      }
                    });
                  },
                  child: const Text('Submit Answer')),
            ),
          ),
        ],
      ),
    );
  }
}
