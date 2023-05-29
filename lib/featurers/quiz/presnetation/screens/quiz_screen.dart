// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants/api_constants.dart';
import '../../../../constants/app_constants.dart';
import '../../../../core/utils/count_down_timer.dart';
import '../../../../core/utils/toaster.dart';
import '../../../../featurers/home/data/models/exam_type.dart';
import '../../../../featurers/quiz/data/models/questions.dart';
import '../../../../featurers/quiz/presnetation/controllers/question_controller.dart';
import '../../../../featurers/quiz/presnetation/screens/quiz_result_screen.dart';
import '../../../home/presentation/screens/set_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  static const routeName = '/start-quiz';
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends ConsumerState<QuizScreen> {
  //? Getting User Infos
  String username = "";
  String userImage = "";

  //? Getting username and user photo
  _getInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = jsonDecode(prefs.getString('user')!)['name'];
      userImage = jsonDecode(prefs.getString('user')!)['profile_photo'];
    });
  }

  //? For Chaning the question the i in initilized
  int i = 0;

  //? For selecting answers and finding selectedoptions
  String? answer;
  String? selectedOptions;

  //? Initilize audioplayer for playing audio
  final player = AudioPlayer();

  //? For saving user selected options
  List<Map<String, dynamic>> userSelected = [];

  //? For Total Question Showing
  bool isTotalQuestion = true;

  //? Audio bool for question
  bool isQusPlaying = false;

  // ? Audio playing option
  final option1Player = AudioPlayer();
  bool isOption1Playing = false;

  final option2Player = AudioPlayer();
  bool isOption2Playing = false;

  final option3Player = AudioPlayer();
  bool isOption3Playing = false;

  final option4Player = AudioPlayer();
  bool isOption4Playing = false;

  //? For Checking audio is played twice or not
  int q = 0; //* For Question
  int o1 = 0; //* For option 1
  int o2 = 0; //* For option 2
  int o3 = 0; //* For option 3
  int o4 = 0; //* For option 4

  bool isTimerStart = true;

  //? For Initilizating cache Manager
  late var imageCache = CacheManager(
    Config(
      'imageCache',
      stalePeriod: const Duration(days: 1),
    ),
  );

  // ? Option Box 1
  Widget optionBox1({
    required String option,
    required String isImage,
    required Size screenSize,
    required String selectedOption,
    required String isOptionAudio,
    required List<Questions> data,
    required String boxNumber,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: screenSize.height * 0.02),
      child: InkWell(
        onTap: () {
          //? For Selecting the options
          selectOption(option, selectedOption, data);
        },
        child: Container(
          width: isImage == 'Yes' ? screenSize.width * 0.2 : double.infinity,
          padding: const EdgeInsets.all(
            12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isImage == 'Yes'
                ? const Border()
                : Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
            color: Colors.white,
            boxShadow: [
              isImage == 'Yes'
                  ? const BoxShadow(
                      offset: Offset(2, 2),
                      color: Colors.black26,
                      blurRadius: 5,
                    )
                  : const BoxShadow(),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: screenSize.width * 0.04,
                height: isImage == 'Yes'
                    ? screenSize.height * 0.2
                    : screenSize.height * 0.09,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.3,
                    color: answer == option ? Colors.transparent : Colors.black,
                  ),
                  color: answer == option ? Colors.black : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    boxNumber,
                    style: TextStyle(
                      color: answer == option ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              data[i].isOptionAudio == 'Yes'
                  ? IconButton(
                      onPressed: () async {
                        if (data[i].option1Count >= 2) {
                          toast(
                              context: context,
                              label: 'You cannot play audio more than twice',
                              subTitle: '두 번 이상 플레이할 수 없습니다.',
                              color: Colors.red);
                        } else {
                          //? For Audio Playing
                          var filePath =
                              await imageCache.getFileFromCache(option);
                          await option1Player.setFilePath(filePath!.file.path);
                          final duration = option1Player.duration;
                          Timer(duration!, () {
                            setState(() {
                              isOption1Playing = false;
                            });
                          });
                          if (o1 < 2) {
                            option1Player.playing
                                ? option1Player.stop()
                                : option1Player.play();
                            if (option1Player.playing) {
                              data[i].option1Count++;
                            }
                            setState(() {
                              isOption1Playing = !isOption1Playing;
                              if (option1Player.playing) {
                                o1++;
                              }
                            });
                          } else {
                            setState(() {
                              isOption1Playing = false;
                            });
                            toast(
                                context: context,
                                label: 'You cannot play audio more than twice',
                                subTitle: '두 번 이상 플레이할 수 없습니다.',
                                color: Colors.red);
                            option1Player.stop();
                          }
                        }

                        //? For Selecting the options
                        selectOption(option, selectedOption, data);
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Icon(
                        isOption1Playing
                            ? Icons.pause_circle
                            : Icons.play_circle_outline,
                        size: 32,
                        color: data[i].option1Count < 2
                            ? Colors.black
                            : Colors.grey.shade500,
                      ),
                    )
                  : isImage == 'No'
                      ? AutoSizeText(
                          option,
                          maxLines: 2,
                        )
                      : InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: InteractiveViewer(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '${ApiConstants.answerImageUrl}$option',
                                            // cacheManager: imageCache,
                                            width: screenSize.width * 0.4,
                                            height: double.infinity,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            selectOption(option, selectedOption, data);
                          },
                          child: CachedNetworkImage(
                            imageUrl: '${ApiConstants.answerImageUrl}$option',
                            // cacheManager: imageCache,
                            height: screenSize.height * 0.13,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // ? Option Box 2
  Widget optionBox2({
    required String option,
    required String isImage,
    required Size screenSize,
    required String selectedOption,
    required String isOptionAudio,
    required List<Questions> data,
    required String boxNumber,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: screenSize.height * 0.02),
      child: InkWell(
        onTap: () {
          //? For Selecting the options
          selectOption(option, selectedOption, data);
        },
        child: Container(
          width: isImage == 'Yes' ? screenSize.width * 0.2 : double.infinity,
          padding: const EdgeInsets.all(
            12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isImage == 'Yes'
                ? const Border()
                : Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
            color: Colors.white,
            boxShadow: [
              isImage == 'Yes'
                  ? const BoxShadow(
                      offset: Offset(2, 2),
                      color: Colors.black26,
                      blurRadius: 5,
                    )
                  : const BoxShadow(),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: screenSize.width * 0.04,
                height: isImage == 'Yes'
                    ? screenSize.height * 0.2
                    : screenSize.height * 0.09,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.3,
                    color: answer == option ? Colors.transparent : Colors.black,
                  ),
                  color: answer == option ? Colors.black : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    boxNumber,
                    style: TextStyle(
                      color: answer == option ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              data[i].isOptionAudio == 'Yes'
                  ? IconButton(
                      onPressed: () async {
                        if (data[i].option2Count >= 2) {
                          toast(
                              context: context,
                              label: 'You cannot play audio more than twice',
                              subTitle: '두 번 이상 플레이할 수 없습니다.',
                              color: Colors.red);
                        } else {
                          //? For Audio Playing
                          var filePath =
                              await imageCache.getFileFromCache(option);
                          await option2Player.setFilePath(filePath!.file.path);
                          final duration = option2Player.duration;
                          Timer(duration!, () {
                            setState(() {
                              isOption2Playing = false;
                            });
                          });
                          if (o2 < 2) {
                            option2Player.playing
                                ? option2Player.stop()
                                : option2Player.play();
                            if (option2Player.playing) {
                              data[i].option2Count++;
                            }
                            setState(() {
                              isOption2Playing = !isOption2Playing;
                              if (option2Player.playing) {
                                o2++;
                              }
                            });
                          } else {
                            setState(() {
                              isOption2Playing = false;
                            });
                            toast(
                                context: context,
                                label: 'You cannot play audio more than twice',
                                subTitle: '두 번 이상 플레이할 수 없습니다.',
                                color: Colors.red);
                            option2Player.stop();
                          }
                        }

                        //? For Selecting the options
                        selectOption(option, selectedOption, data);
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Icon(
                        isOption2Playing
                            ? Icons.pause_circle
                            : Icons.play_circle_outline,
                        size: 32,
                        color: data[i].option2Count < 2
                            ? Colors.black
                            : Colors.grey.shade500,
                      ),
                    )
                  : isImage == 'No'
                      ? AutoSizeText(
                          option,
                          maxLines: 2,
                        )
                      : InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: InteractiveViewer(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '${ApiConstants.answerImageUrl}$option',
                                            // cacheManager: imageCache,
                                            width: screenSize.width * 0.4,
                                            height: double.infinity,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            selectOption(option, selectedOption, data);
                          },
                          child: CachedNetworkImage(
                            imageUrl: '${ApiConstants.answerImageUrl}$option',
                            // cacheManager: imageCache,
                            height: screenSize.height * 0.13,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // ? Option Box 3
  Widget optionBox3({
    required String option,
    required String isImage,
    required Size screenSize,
    required String selectedOption,
    required String isOptionAudio,
    required List<Questions> data,
    required String boxNumber,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: screenSize.height * 0.02),
      child: InkWell(
        onTap: () {
          //? For Selecting the options
          selectOption(option, selectedOption, data);
        },
        child: Container(
          width: isImage == 'Yes' ? screenSize.width * 0.2 : double.infinity,
          padding: const EdgeInsets.all(
            12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isImage == 'Yes'
                ? const Border()
                : Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
            color: Colors.white,
            boxShadow: [
              isImage == 'Yes'
                  ? const BoxShadow(
                      offset: Offset(2, 2),
                      color: Colors.black26,
                      blurRadius: 5,
                    )
                  : const BoxShadow(),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: screenSize.width * 0.04,
                height: isImage == 'Yes'
                    ? screenSize.height * 0.2
                    : screenSize.height * 0.09,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.3,
                    color: answer == option ? Colors.transparent : Colors.black,
                  ),
                  color: answer == option ? Colors.black : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    boxNumber,
                    style: TextStyle(
                      color: answer == option ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              data[i].isOptionAudio == 'Yes'
                  ? IconButton(
                      onPressed: () async {
                        if (data[i].option3Count >= 2) {
                          toast(
                              context: context,
                              label: 'You cannot play audio more than twice',
                              subTitle: '두 번 이상 플레이할 수 없습니다.',
                              color: Colors.red);
                        } else {
                          //? For Audio Playing
                          var filePath =
                              await imageCache.getFileFromCache(option);
                          await option3Player.setFilePath(filePath!.file.path);
                          final duration = option3Player.duration;
                          Timer(duration!, () {
                            setState(() {
                              isOption3Playing = false;
                            });
                          });
                          if (o3 < 2) {
                            option3Player.playing
                                ? option3Player.stop()
                                : option3Player.play();
                            if (option3Player.playing) {
                              data[i].option3Count++;
                            }
                            setState(() {
                              isOption3Playing = !isOption3Playing;
                              if (option3Player.playing) {
                                o3++;
                              }
                            });
                          } else {
                            setState(() {
                              isOption3Playing = false;
                            });
                            toast(
                                context: context,
                                label: 'You cannot play audio more than twice',
                                subTitle: '두 번 이상 플레이할 수 없습니다.',
                                color: Colors.red);
                            option3Player.stop();
                          }
                        }

                        //? For Selecting the options
                        selectOption(option, selectedOption, data);
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Icon(
                        isOption3Playing
                            ? Icons.pause_circle
                            : Icons.play_circle_outline,
                        size: 32,
                        color: data[i].option3Count < 2
                            ? Colors.black
                            : Colors.grey.shade500,
                      ),
                    )
                  : isImage == 'No'
                      ? AutoSizeText(
                          option,
                          maxLines: 2,
                        )
                      : InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: InteractiveViewer(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '${ApiConstants.answerImageUrl}$option',
                                            // cacheManager: imageCache,
                                            width: screenSize.width * 0.4,
                                            height: double.infinity,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            selectOption(option, selectedOption, data);
                          },
                          child: CachedNetworkImage(
                            imageUrl: '${ApiConstants.answerImageUrl}$option',
                            // cacheManager: imageCache,
                            height: screenSize.height * 0.13,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // ? Option Box 4
  Widget optionBox4({
    required String option,
    required String isImage,
    required Size screenSize,
    required String selectedOption,
    required String isOptionAudio,
    required List<Questions> data,
    required String boxNumber,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: screenSize.height * 0.02),
      child: InkWell(
        onTap: () {
          //? For Selecting the options
          selectOption(option, selectedOption, data);
        },
        child: Container(
          width: isImage == 'Yes' ? screenSize.width * 0.2 : double.infinity,
          padding: const EdgeInsets.all(
            12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isImage == 'Yes'
                ? const Border()
                : Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
            color: Colors.white,
            boxShadow: [
              isImage == 'Yes'
                  ? const BoxShadow(
                      offset: Offset(2, 2),
                      color: Colors.black26,
                      blurRadius: 5,
                    )
                  : const BoxShadow(),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: screenSize.width * 0.04,
                height: isImage == 'Yes'
                    ? screenSize.height * 0.2
                    : screenSize.height * 0.09,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.3,
                    color: answer == option ? Colors.transparent : Colors.black,
                  ),
                  color: answer == option ? Colors.black : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    boxNumber,
                    style: TextStyle(
                      color: answer == option ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              data[i].isOptionAudio == 'Yes'
                  ? IconButton(
                      onPressed: () async {
                        if (data[i].option4Count >= 2) {
                          toast(
                              context: context,
                              label: 'You cannot play audio more than twice',
                              subTitle: '두 번 이상 플레이할 수 없습니다.',
                              color: Colors.red);
                        } else {
                          //? For Audio Playing
                          var filePath =
                              await imageCache.getFileFromCache(option);
                          await option4Player.setFilePath(filePath!.file.path);
                          final duration = option4Player.duration;
                          Timer(duration!, () {
                            setState(() {
                              isOption4Playing = false;
                            });
                          });
                          if (o4 < 2) {
                            option4Player.playing
                                ? option4Player.stop()
                                : option4Player.play();
                            if (option4Player.playing) {
                              data[i].option4Count++;
                            }
                            setState(() {
                              isOption4Playing = !isOption4Playing;
                              if (option4Player.playing) {
                                o4++;
                              }
                            });
                          } else {
                            setState(() {
                              isOption4Playing = false;
                            });
                            toast(
                                context: context,
                                label: 'You cannot play audio more than twice',
                                subTitle: '두 번 이상 플레이할 수 없습니다.',
                                color: Colors.red);
                            option4Player.stop();
                          }
                        }

                        //? For Selecting the options
                        selectOption(option, selectedOption, data);
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Icon(
                        isOption4Playing
                            ? Icons.pause_circle
                            : Icons.play_circle_outline,
                        size: 32,
                        color: data[i].option4Count < 2
                            ? Colors.black
                            : Colors.grey.shade500,
                      ),
                    )
                  : isImage == 'No'
                      ? AutoSizeText(
                          option,
                          maxLines: 2,
                        )
                      : InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: InteractiveViewer(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '${ApiConstants.answerImageUrl}$option',
                                            // cacheManager: imageCache,
                                            width: screenSize.width * 0.4,
                                            height: double.infinity,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            selectOption(option, selectedOption, data);
                          },
                          child: CachedNetworkImage(
                            imageUrl: '${ApiConstants.answerImageUrl}$option',
                            // cacheManager: imageCache,
                            height: screenSize.height * 0.13,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  void selectOption(
      String option, String selectedOption, List<Questions> data) {
    setState(() {
      answer = option;
      selectedOptions = selectedOption;

      //? Storing Data in a MAP
      Map<String, dynamic> ua = {
        'questionNumber': i + 1,
        'question': data[i].id,
        'userAnswer': answer,
        'option': selectedOptions,
      };
      if (i <= data.length - 1) {
        userSelected
                .firstWhere((element) => element['question'] == data[i].id,
                    orElse: () => {})
                .isNotEmpty
            ? userSelected[userSelected.indexWhere(
                (element) => element['question'] == ua['question'])] = ua
            : userSelected.add(ua);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getInfo();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    super.dispose();
    player.stop();
  }

  @override
  Widget build(BuildContext context) {
    //? MeidaQuery Screen Size
    Size screenSize = MediaQuery.of(context).size;

    //? Taking Arguments
    Map args = ModalRoute.of(context)!.settings.arguments as Map;

    //? Geting ExamType
    ExamType examType = args['exam'];

    return ref.watch(questionControllerProvider(examType.id)).when(
          data: (data) {
            //? Getting Timer Data
            CountDownTimer counter = CountDownTimer(
              isStart: isTimerStart,
              time: Duration(minutes: examType.time),
              onSubmit: () {
                List<String> questionIds = [];
                List<String> selectedAnswers = [];

                setState(() {
                  isTimerStart = false;
                });

                for (var userAnswer in userSelected) {
                  questionIds.add(userAnswer['question'].toString());
                  selectedAnswers.add(userAnswer['option'].toString());
                }

                for (var qus in data) {
                  if (!questionIds.contains(qus.id.toString())) {
                    questionIds.add(qus.id.toString());
                  }
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
            );
            cachingDatas(data);
            return Theme(
              data: ThemeData.light(
                useMaterial3: true,
              ),
              child: WillPopScope(
                onWillPop: () async {
                  backPrompt(context, examType);
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    foregroundImage: NetworkImage(
                                        '${ApiConstants.userImage}$userImage'),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: screenSize.width * 0.1,
                                    child: Text(
                                      username,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
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
                      ? totalQuestionsView(
                          screenSize: screenSize,
                          examType: examType,
                          data: data,
                        )
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //? Showing Category
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: screenSize.height * 0.01,
                                              bottom: 8,
                                            ),
                                            child: Text(
                                              data[i].category,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                          ),

                                          //? Showing Question
                                          (i > 1 && i < 8) ||
                                                  (i >= 12 && i <= 19)
                                              ? QuestionWithBorder(
                                                  screenSize: screenSize,
                                                  i: i,
                                                  data: data)
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: Text(
                                                        '${i + 1}.',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                      ),
                                                    ),
                                                    data[i].question != null ||
                                                            data[i].isAudio ==
                                                                'Yes'
                                                        ? SizedBox(
                                                            width: screenSize
                                                                    .width *
                                                                0.4,
                                                            child: Text(
                                                              data[i].question!,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                            ),
                                                          )
                                                        : const SizedBox()
                                                  ],
                                                ),
                                          // ! For Displaying audio
                                          data[i].isAudio == 'Yes'
                                              ? audioQuestion(
                                                  screenSize, data, context)
                                              : data[i].filePath!.isNotEmpty
                                                  ? imageWithAudio(
                                                      context, data, screenSize)
                                                  : data[i].audioPath != null
                                                      ? audioQuestionWithOptionImage(
                                                          screenSize,
                                                          data,
                                                          context)
                                                      : const SizedBox(),
                                        ],
                                      ),
                                      //??? For answer
                                      data[i].isImage == 'Yes'
                                          ? Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: optionBox1(
                                                        option: data[i].option1,
                                                        isImage:
                                                            data[i].isImage,
                                                        screenSize: screenSize,
                                                        selectedOption:
                                                            'option1',
                                                        isOptionAudio: data[i]
                                                            .isOptionAudio,
                                                        data: data,
                                                        boxNumber: '1',
                                                        context: context,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: optionBox2(
                                                        option: data[i].option2,
                                                        isImage:
                                                            data[i].isImage,
                                                        screenSize: screenSize,
                                                        isOptionAudio: data[i]
                                                            .isOptionAudio,
                                                        selectedOption:
                                                            'option2',
                                                        data: data,
                                                        boxNumber: '2',
                                                        context: context,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: optionBox3(
                                                        option: data[i].option3,
                                                        isImage:
                                                            data[i].isImage,
                                                        screenSize: screenSize,
                                                        isOptionAudio: data[i]
                                                            .isOptionAudio,
                                                        selectedOption:
                                                            'option3',
                                                        data: data,
                                                        boxNumber: '3',
                                                        context: context,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: optionBox4(
                                                        option: data[i].option4,
                                                        isImage:
                                                            data[i].isImage,
                                                        screenSize: screenSize,
                                                        isOptionAudio: data[i]
                                                            .isOptionAudio,
                                                        selectedOption:
                                                            'option4',
                                                        data: data,
                                                        boxNumber: '4',
                                                        context: context,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                //Option Box
                                                optionBox1(
                                                  option: data[i].option1,
                                                  isImage: data[i].isImage,
                                                  screenSize: screenSize,
                                                  selectedOption: 'option1',
                                                  isOptionAudio:
                                                      data[i].isOptionAudio,
                                                  data: data,
                                                  boxNumber: '1',
                                                  context: context,
                                                ),
                                                optionBox2(
                                                  option: data[i].option2,
                                                  isImage: data[i].isImage,
                                                  screenSize: screenSize,
                                                  isOptionAudio:
                                                      data[i].isOptionAudio,
                                                  selectedOption: 'option2',
                                                  data: data,
                                                  boxNumber: '2',
                                                  context: context,
                                                ),
                                                optionBox3(
                                                  option: data[i].option3,
                                                  isImage: data[i].isImage,
                                                  screenSize: screenSize,
                                                  isOptionAudio:
                                                      data[i].isOptionAudio,
                                                  selectedOption: 'option3',
                                                  data: data,
                                                  boxNumber: '3',
                                                  context: context,
                                                ),
                                                optionBox4(
                                                  option: data[i].option4,
                                                  isImage: data[i].isImage,
                                                  screenSize: screenSize,
                                                  isOptionAudio:
                                                      data[i].isOptionAudio,
                                                  selectedOption: 'option4',
                                                  data: data,
                                                  boxNumber: '4',
                                                  context: context,
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                                // * For buttons
                                i == 0
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0),
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      9,
                                                    ),
                                                  ),
                                                  side: BorderSide(
                                                      color: AppConstants
                                                          .quizScreen),
                                                  backgroundColor:
                                                      Colors.transparent),
                                              onPressed: () {
                                                setState(() {
                                                  isTotalQuestion = true;
                                                });
                                              },
                                              child: Text(
                                                'Total Questions',
                                                style: TextStyle(
                                                    color: AppConstants
                                                        .quizScreen),
                                              ),
                                            ),
                                          ),
                                          i == data.length - 1
                                              ? const SizedBox()
                                              : nextButton(
                                                  data,
                                                  examType,
                                                ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          previousButton(
                                            data,
                                            examType,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0),
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      9,
                                                    ),
                                                  ),
                                                  side: BorderSide(
                                                      color: AppConstants
                                                          .quizScreen),
                                                  backgroundColor:
                                                      Colors.transparent),
                                              onPressed: () {
                                                setState(() {
                                                  isTotalQuestion = true;
                                                });
                                              },
                                              child: Text(
                                                'Total Questions',
                                                style: TextStyle(
                                                    color: AppConstants
                                                        .quizScreen),
                                              ),
                                            ),
                                          ),
                                          i == data.length - 1
                                              ? const SizedBox()
                                              : nextButton(
                                                  data,
                                                  examType,
                                                ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
          error: (e, s) => WillPopScope(
            onWillPop: () async {
              SystemChrome.setPreferredOrientations(
                  [DeviceOrientation.portraitUp]);
              ref.invalidate(questionControllerProvider);
              return true;
            },
            child: Scaffold(
              body: Center(child: Text(e.toString())),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  Container audioQuestionWithOptionImage(
      Size screenSize, List<Questions> data, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: screenSize.height * 0.25,
      margin: const EdgeInsets.all(
        15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
        ),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(offset: Offset(0, 5), blurRadius: 5, color: Colors.black26),
        ],
      ),
      child: IconButton(
        onPressed: () async {
          if (data[i].audioPathcount >= 2) {
            toast(
                context: context,
                label: 'You cannot play audio more than twice',
                subTitle: '두 번 이상 플레이할 수 없습니다.',
                color: Colors.red);
          } else {
            //? For Audio Playing
            var filePath =
                await imageCache.getFileFromCache(data[i].audioPath!);
            await player.setFilePath(filePath!.file.path);
            final duration = player.duration;
            Timer(duration!, () {
              setState(() {
                isQusPlaying = false;
              });
            });
            if (q < 2) {
              isQusPlaying ? player.stop() : player.play();
              data[i].audioPathcount++;
              setState(() {
                isQusPlaying = !isQusPlaying;
                if (isQusPlaying) {
                  q++;
                }
              });
            } else {
              player.stop();
              setState(() {
                isQusPlaying = false;
              });
              toast(
                  context: context,
                  label: 'You cannot play audio more than twice',
                  subTitle: '두 번 이상 플레이할 수 없습니다.',
                  color: Colors.red);
            }
          }
        },
        icon: Icon(
          isQusPlaying ? Icons.pause_circle_filled_rounded : Icons.volume_down,
          size: 32,
          color:
              data[i].audioPathcount < 2 ? Colors.black : Colors.grey.shade600,
        ),
      ),
    );
  }

  Container audioQuestion(
      Size screenSize, List<Questions> data, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: screenSize.height * 0.24,
      margin: const EdgeInsets.all(
        15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
        ),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(offset: Offset(0, 5), blurRadius: 5, color: Colors.black26),
        ],
      ),
      child: IconButton(
        onPressed: () async {
          if (data[i].questionCount >= 2) {
            toast(
                context: context,
                label: 'You cannot play audio more than twice',
                subTitle: '두 번 이상 플레이할 수 없습니다.',
                color: Colors.red);
          } else {
            data[i].questionCount++;
            //? For Audio Playing
            var filePath = await imageCache.getFileFromCache(data[i].filePath!);
            await player.setFilePath(filePath!.file.path);

            // Getting Timer
            final duration = player.duration;
            Timer(duration!, () {
              setState(() {
                isQusPlaying = false;
              });
            });
            if (q < 2) {
              isQusPlaying ? player.stop() : player.play();

              setState(() {
                isQusPlaying = !isQusPlaying;
                if (isQusPlaying) {
                  q++;
                }
              });
            } else {
              player.stop();
              setState(() {
                isQusPlaying = false;
              });
              toast(
                  context: context,
                  label: 'You cannot play audio more than twice',
                  subTitle: '두 번 이상 플레이할 수 없습니다.',
                  color: Colors.red);
            }
          }
        },
        icon: Icon(
          isQusPlaying ? Icons.pause_circle_filled_rounded : Icons.volume_down,
          size: 32,
          color:
              data[i].questionCount < 2 ? Colors.black : Colors.grey.shade600,
        ),
      ),
    );
  }

  InkWell imageWithAudio(
      BuildContext context, List<Questions> data, Size screenSize) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InteractiveViewer(
                      child: CachedNetworkImage(
                        imageUrl:
                            '${ApiConstants.questionFileUrl}${data[i].filePath}',
                        width: screenSize.width * 0.4,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        height: data[i].audioPath != null
            ? screenSize.height * 0.53
            : screenSize.height * 0.42,
        margin: const EdgeInsets.all(
          15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black,
          ),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 5), blurRadius: 5, color: Colors.black26),
          ],
        ),
        child: Column(
          children: [
            CachedNetworkImage(
              // cacheManager: imageCache,
              imageUrl: '${ApiConstants.questionFileUrl}${data[i].filePath}',
              width: double.infinity,
              height: screenSize.height * 0.3,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            const Divider(),
            data[i].audioPath != null
                ? IconButton(
                    onPressed: () async {
                      if (data[i].audioPathcount >= 2) {
                        toast(
                            context: context,
                            label: 'You cannot play audio more than twice',
                            subTitle: '두 번 이상 플레이할 수 없습니다.',
                            color: Colors.red);
                      } else {
                        //? For Audio Playing
                        var filePath = await imageCache
                            .getFileFromCache(data[i].audioPath!);
                        await player.setFilePath(filePath!.file.path);
                        final duration = player.duration;
                        Timer(duration!, () {
                          setState(() {
                            isQusPlaying = false;
                          });
                        });
                        if (q < 2) {
                          isQusPlaying ? player.stop() : player.play();
                          data[i].audioPathcount++;
                          setState(() {
                            isQusPlaying = !isQusPlaying;
                            if (isQusPlaying) {
                              q++;
                            }
                          });
                        } else {
                          player.stop();
                          setState(() {
                            isQusPlaying = false;
                          });
                          toast(
                              context: context,
                              label: 'You cannot play audio more than twice',
                              subTitle: '두 번 이상 플레이할 수 없습니다.',
                              color: Colors.red);
                        }
                      }
                    },
                    icon: Icon(
                      isQusPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.volume_down,
                      size: 32,
                      color: data[i].audioPathcount < 2
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  void backPrompt(BuildContext context, ExamType examType) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            'Are you sure want to exit ?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.quizScreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
                ref.invalidate(questionControllerProvider);
                Navigator.of(context).popUntil(
                  ModalRoute.withName(
                    SetScreen.routeName,
                  ),
                );
              },
              child: const Text(
                'Yes',
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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
  }

  void cachingDatas(List<Questions> data) {
    for (var qus in data) {
      if (qus.filePath != null) {
        CachedNetworkImage(
          cacheManager: imageCache,
          imageUrl: '${ApiConstants.questionFileUrl}${qus.filePath}',
        );
      }
      if (qus.isImage != "No") {
        CachedNetworkImage(
          imageUrl: '${ApiConstants.answerImageUrl}${qus.option1}',
          cacheManager: imageCache,
        );
        CachedNetworkImage(
          imageUrl: '${ApiConstants.answerImageUrl}${qus.option2}',
          cacheManager: imageCache,
        );
        CachedNetworkImage(
          imageUrl: '${ApiConstants.answerImageUrl}${qus.option3}',
          cacheManager: imageCache,
        );
        CachedNetworkImage(
          imageUrl: '${ApiConstants.answerImageUrl}${qus.option4}',
          cacheManager: imageCache,
        );
      }
      if (qus.isAudio == 'Yes' || qus.isOptionAudio == 'Yes') {
        imageCache.downloadFile(
          '${ApiConstants.questionFileUrl}${qus.filePath}',
          key: qus.filePath,
        );
      }
      if (qus.isOptionAudio == 'Yes') {
        imageCache.downloadFile(
          '${ApiConstants.answerImageUrl}${qus.option1}',
          key: qus.option1,
        );
        imageCache.downloadFile(
          '${ApiConstants.answerImageUrl}${qus.option2}',
          key: qus.option2,
        );
        imageCache.downloadFile(
          '${ApiConstants.answerImageUrl}${qus.option3}',
          key: qus.option3,
        );
        imageCache.downloadFile(
          '${ApiConstants.answerImageUrl}${qus.option4}',
          key: qus.option4,
        );
      }
      if (qus.audioPath != null) {
        imageCache.downloadFile(
          '${ApiConstants.questionFileUrl}${qus.audioPath}',
          key: qus.audioPath,
        );
      }
    }
  }

  Padding nextButton(
    List<Questions> data,
    ExamType examType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton(
          style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  9,
                ),
              ),
              backgroundColor: AppConstants.quizScreen,
              fixedSize: const Size(150, 10)),
          onPressed: () {
            setState(() {
              //Setting audio values to 0
              q = 0;
              o1 = 0;
              o2 = 0;
              o3 = 0;
              o4 = 0;
              isQusPlaying = false;
              isOption1Playing = false;
              isOption4Playing = false;
              isOption2Playing = false;
              isOption3Playing = false;

              player.stop();
              option1Player.stop();
              option2Player.stop();
              option3Player.stop();
              option4Player.stop();
              if (i < data.length - 1) {
                i++;
                int selectedQuestion = data[i].id;
                if (userSelected.length > 1) {
                  answer = userSelected.firstWhere(
                      (element) => element['question'] == selectedQuestion,
                      orElse: () => {})['userAnswer'];
                }
              }
            });
          },
          child: const Text(
            'Next',
          ),
        ),
      ),
    );
  }

  Padding previousButton(
    List<Questions> data,
    ExamType examType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppConstants.quizScreen,
            fixedSize: const Size(150, 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                9,
              ),
            ),
          ),
          onPressed: () {
            setState(() {
              //For setting audio vales to 0
              q = 0;
              o1 = 0;
              o2 = 0;
              o3 = 0;
              o4 = 0;
              isQusPlaying = false;
              player.stop();
              option1Player.stop();
              option2Player.stop();
              option3Player.stop();
              option4Player.stop();
              if (i > 0) {
                i--;
              }
              int selectedQuestion = data[i].id;
              if (userSelected.isNotEmpty) {
                answer = userSelected.firstWhere(
                    (element) => element['question'] == selectedQuestion,
                    orElse: () => {})['userAnswer'];
              }
            });
          },
          child: const Text(
            'Previous',
          ),
        ),
      ),
    );
  }

  Padding totalQuestionsView(
      {required Size screenSize,
      required ExamType examType,
      required List<Questions> data}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
      ),
      child: Column(
        children: [
          SizedBox(
            height: screenSize.height * 0.65,
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
              ),
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0, bottom: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chrome_reader_mode_outlined,
                            color: AppConstants.quizScreen,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text('(20 Questions)'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.55,
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

                                if (i < data.length - 1) {
                                  int selectedQuestion = data[i].id;
                                  if (userSelected.length > 1) {
                                    answer = userSelected.firstWhere(
                                        (element) =>
                                            element['question'] ==
                                            selectedQuestion,
                                        orElse: () => {})['userAnswer'];
                                  }
                                }
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
                                  ? AppConstants.quizScreen
                                  : Colors.grey.shade100,
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
                      padding: const EdgeInsets.only(top: 3.0, bottom: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.headphones,
                            color: AppConstants.quizScreen,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text('(20 Questions)'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.55,
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
                                i = 20 + index;
                                if (i < data.length - 1) {
                                  int selectedQuestion = data[i].id;
                                  if (userSelected.length > 1) {
                                    answer = userSelected.firstWhere(
                                        (element) =>
                                            element['question'] ==
                                            selectedQuestion,
                                        orElse: () => {})['userAnswer'];
                                  }
                                }
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
                                  ? AppConstants.quizScreen
                                  : Colors.grey.shade100,
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
            padding: const EdgeInsets.only(top: 2.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppConstants.quizScreen,
                  ),
                  onPressed: () {
                    //For empty submiting quiz
                    if (userSelected.length < 2) {
                      toast(
                          context: context,
                          label: 'At least 2 question should be solved',
                          color: Colors.red);
                    } else {
                      if (userSelected.length < 40) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                height: screenSize.height * 0.12,
                                child: Column(
                                  children: const [
                                    Text(
                                        'You have not answered all the questions.'),
                                    Text('Are you sure want to submit ?'),
                                  ],
                                ),
                              ),
                              title: Text(
                                'Warning !',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppConstants.quizScreen,
                                  ),
                                  onPressed: () {
                                    submitAnswers(
                                        examType: examType, data: data);
                                  },
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'No',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                height: screenSize.height * 0.12,
                                child: Column(
                                  children: const [
                                    Text('Are you sure to submit ?'),
                                  ],
                                ),
                              ),
                              title: Text(
                                'Warning !',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppConstants.quizScreen,
                                  ),
                                  onPressed: () {
                                    submitAnswers(
                                        examType: examType, data: data);
                                  },
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'No',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: const Text('Submit Answer')),
            ),
          ),
        ],
      ),
    );
  }

  void submitAnswers(
      {required ExamType examType, required List<Questions> data}) {
    List<String> questionIds = [];
    List<String> selectedAnswers = [];

    player.stop();
    option1Player.stop();
    option2Player.stop();
    option3Player.stop();
    option4Player.stop();

    setState(() {
      isTimerStart = false;
    });

    for (var userAnswer in userSelected) {
      questionIds.add(userAnswer['question'].toString());
      selectedAnswers.add(userAnswer['option'].toString());
    }

    for (var qus in data) {
      if (!questionIds.contains(qus.id.toString())) {
        questionIds.add(qus.id.toString());
      }
    }

    ref
        .read(questionControllerProvider(examType.id).notifier)
        .submitAnswer(questions: questionIds, answers: selectedAnswers)
        .then((value) {
      if (value[0] == 'false') {
        toast(context: context, label: value[1], color: Colors.red);
      } else {
        List<String> msg = [value[1], value[2], value[3]];
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        Navigator.of(context)
            .pushReplacementNamed(QuizResultScreen.routeName, arguments: msg);
      }
    });
  }
}

class QuestionWithBorder extends StatelessWidget {
  const QuestionWithBorder({
    super.key,
    required this.screenSize,
    required this.i,
    required this.data,
  });

  final Size screenSize;
  final int i;
  final List<Questions> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ? Showing Question number
        Padding(
          padding: EdgeInsets.only(
            bottom: screenSize.height * 0.03,
          ),
          child: Text(
            '${i + 1}.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 5),
                blurRadius: 7,
                color: Colors.black26,
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: i >= 2 && i <= 3
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenSize.height * 0.03,
                ),
                child: data[i].question != null
                    ? Text(
                        data[i].question!,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.black,
                            ),
                        textAlign: i >= 4 && i <= 8
                            ? TextAlign.left
                            : TextAlign.center,
                      )
                    : const SizedBox(),
              ),
              // Showing Sub Question
              data[i].subQuestion != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        bottom: screenSize.height * 0.03,
                      ),
                      child: Text(
                        '${data[i].subQuestion}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.black,
                            ),
                        textAlign: i >= 4 && i <= 8
                            ? TextAlign.left
                            : TextAlign.center,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
