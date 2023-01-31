import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:toddle/constants/api_constants.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/quiz/data/models/questions.dart';
import 'package:toddle/featurers/quiz/presnetation/controllers/question_controller.dart';

class QuizScreen extends ConsumerStatefulWidget {
  static const routeName = '/start-quiz';
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends ConsumerState<QuizScreen> {
  int i = 0;

  String? answer;

  final player = AudioPlayer();

  List<Map<String, dynamic>> userSelected = [];

  List<dynamic> option1Images = [];
  List<dynamic> option2Images = [];
  List<dynamic> option3Images = [];
  List<dynamic> option4Images = [];
  List<dynamic> questionImage = [];

  //Widget For Option Box
  Widget optionBox({
    required String option,
    required String isImage,
    required Size screenSize,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: screenSize.height * 0.02),
      child: InkWell(
        onTap: () {
          setState(() {
            answer = option;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Toddle',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.person_2_outlined,
            ),
          ),
        ],
      ),
      body: ref.watch(questionControllerProvider(examType.id)).when(
            data: (data) {
              data.map((ques) => option1Images.add(
                    CachedNetworkImage(
                      imageUrl: '${ApiConstants.answerImageUrl}${ques.option1}',
                      height: screenSize.height * 0.1,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ));
              data.map((ques) => option2Images.add(
                    CachedNetworkImage(
                      imageUrl: '${ApiConstants.answerImageUrl}${ques.option2}',
                      height: screenSize.height * 0.1,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ));
              data.map((ques) => option3Images.add(
                    CachedNetworkImage(
                      imageUrl: '${ApiConstants.answerImageUrl}${ques.option3}',
                      height: screenSize.height * 0.1,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ));
              data.map((ques) => option4Images.add(
                    CachedNetworkImage(
                      imageUrl: '${ApiConstants.answerImageUrl}${ques.option4}',
                      height: screenSize.height * 0.1,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ));
              data.map((ques) => questionImage.add(CachedNetworkImage(
                    imageUrl:
                        '${ApiConstants.questionFileUrl}${data[i].filePath}',
                    height: screenSize.height * 0.17,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )));
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
                      Text(
                        '${examType.examType} Set $setId',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const Divider(),
                      //Remaning Timer
                      // CountDownTimer(time: Duration(minutes: examType.time)),

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
                          screenSize: screenSize),
                      optionBox(
                          option: data[i].option2,
                          isImage: data[i].isImage,
                          screenSize: screenSize),
                      optionBox(
                          option: data[i].option3,
                          isImage: data[i].isImage,
                          screenSize: screenSize),
                      optionBox(
                          option: data[i].option4,
                          isImage: data[i].isImage,
                          screenSize: screenSize),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          i == 0
                              ? const Spacer()
                              : previousButton(data, examType),
                          i == data.length - 1
                              ? submitButton()
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
              if (i < data.length - 1) {
                i++;
              }
              Map<String, dynamic> ua = {
                'question': data[i].id,
                'userAnswer': answer,
              };

              userSelected.length > 1
                  ? userSelected
                          .firstWhere((element) =>
                              element['question'] == ua['question'])
                          .isNotEmpty
                      ? userSelected[userSelected.indexWhere((element) =>
                          element['question'] == ua['question'])] = ua
                      : userSelected.add(ua)
                  : userSelected.add(ua);
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

  Padding submitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.tonalIcon(
          onPressed: () {},
          icon: const Icon(Icons.check_box),
          label: const Text(
            'Submit',
          ),
        ),
      ),
    );
  }
}
