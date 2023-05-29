// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddle/featurers/offline_storage/data/models/offline_question.dart';
import 'package:toddle/featurers/offline_storage/presentation/controllers/offline_storage_controller.dart';
import 'package:toddle/featurers/offline_storage/presentation/screens/downloaded_exam_screen.dart';

import '../../../../constants/api_constants.dart';
import '../../../../constants/app_constants.dart';
import '../../../../core/utils/count_down_timer.dart';
import '../../../../core/utils/toaster.dart';
import '../../../../featurers/quiz/presnetation/controllers/question_controller.dart';
import 'offline_score_card.dart';

class StartOfflineExam extends ConsumerStatefulWidget {
  static const routeName = '/start-offline-exam';
  const StartOfflineExam({super.key});

  @override
  StartOfflineExamState createState() => StartOfflineExamState();
}

class StartOfflineExamState extends ConsumerState<StartOfflineExam> {
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

  bool isTimerStart = true;

  // ? Option Box 1
  Widget optionBox1({
    required String option,
    required String isImage,
    required Size screenSize,
    required String selectedOption,
    required String isOptionAudio,
    required List<OfflineQuestions> data,
    required String boxNumber,
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
                          var tempDir = await getApplicationSupportDirectory();
                          String filePath =
                              '${tempDir.path}/${data[i].option1}';
                          await option1Player.setFilePath(filePath);
                          final duration = option1Player.duration;
                          Timer(duration!, () {
                            setState(() {
                              isOption1Playing = false;
                            });
                          });
                          if (data[i].option1Count < 2) {
                            option1Player.playing
                                ? option1Player.stop()
                                : option1Player.play();
                            setState(() {
                              isOption1Playing = !isOption1Playing;
                              if (option1Player.playing) {
                                data[i].option1Count++;
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
                                          child: FutureBuilder(
                                              future: _getLocalFile(
                                                  data[i].option1.toString()),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<File>
                                                      snapshot) {
                                                return snapshot.hasData
                                                    ? Image.file(
                                                        File(snapshot
                                                            .data!.path),
                                                        width:
                                                            screenSize.width *
                                                                0.4,
                                                        height: double.infinity,
                                                      )
                                                    : Container();
                                              }),
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
                          child: FutureBuilder(
                              future: _getLocalFile(data[i].option1.toString()),
                              builder: (BuildContext context,
                                  AsyncSnapshot<File> snapshot) {
                                return snapshot.hasData
                                    ? Image.file(
                                        File(snapshot.data!.path),
                                        height: screenSize.height * 0.13,
                                      )
                                    : Container();
                              }),
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
    required List<OfflineQuestions> data,
    required String boxNumber,
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
                          var tempDir = await getApplicationSupportDirectory();
                          String filePath =
                              '${tempDir.path}/${data[i].option2}';
                          await option2Player.setFilePath(filePath);
                          final duration = option2Player.duration;
                          Timer(duration!, () {
                            setState(() {
                              isOption2Playing = false;
                            });
                          });
                          if (data[i].option2Count < 2) {
                            option2Player.playing
                                ? option2Player.stop()
                                : option2Player.play();
                            setState(() {
                              isOption2Playing = !isOption2Playing;
                              if (option2Player.playing) {
                                data[i].option2Count++;
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
                                          child: FutureBuilder(
                                              future: _getLocalFile(
                                                  data[i].option2.toString()),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<File>
                                                      snapshot) {
                                                return snapshot.hasData
                                                    ? Image.file(
                                                        File(snapshot
                                                            .data!.path),
                                                        width:
                                                            screenSize.width *
                                                                0.4,
                                                        height: double.infinity,
                                                      )
                                                    : Container();
                                              }),
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
                          child: FutureBuilder(
                              future: _getLocalFile(data[i].option2.toString()),
                              builder: (BuildContext context,
                                  AsyncSnapshot<File> snapshot) {
                                return snapshot.hasData
                                    ? Image.file(
                                        File(snapshot.data!.path),
                                        height: screenSize.height * 0.13,
                                      )
                                    : Container();
                              }),
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
    required List<OfflineQuestions> data,
    required String boxNumber,
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
                        log(data[i].option3Count.toString());
                        if (data[i].option3Count >= 2) {
                          toast(
                              context: context,
                              label: 'You cannot play audio more than twice',
                              subTitle: '두 번 이상 플레이할 수 없습니다.',
                              color: Colors.red);
                        } else {
                          //? For Audio Playing
                          var tempDir = await getApplicationSupportDirectory();
                          String filePath =
                              '${tempDir.path}/${data[i].option3}';

                          await option3Player.setFilePath(filePath);
                          final duration = option3Player.duration;
                          Timer(duration!, () {
                            setState(() {
                              isOption3Playing = false;
                            });
                          });
                          if (data[i].option3Count < 2) {
                            option3Player.playing
                                ? option3Player.stop()
                                : option3Player.play();
                            setState(() {
                              isOption3Playing = !isOption3Playing;
                              if (option3Player.playing) {
                                data[i].option3Count++;
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
                                          child: FutureBuilder(
                                              future: _getLocalFile(
                                                  data[i].option3.toString()),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<File>
                                                      snapshot) {
                                                return snapshot.hasData
                                                    ? Image.file(
                                                        File(snapshot
                                                            .data!.path),
                                                        width:
                                                            screenSize.width *
                                                                0.4,
                                                        height: double.infinity,
                                                      )
                                                    : Container();
                                              }),
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
                          child: FutureBuilder(
                              future: _getLocalFile(data[i].option3.toString()),
                              builder: (BuildContext context,
                                  AsyncSnapshot<File> snapshot) {
                                return snapshot.hasData
                                    ? Image.file(
                                        File(snapshot.data!.path),
                                        height: screenSize.height * 0.13,
                                      )
                                    : Container();
                              }),
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
    required List<OfflineQuestions> data,
    required String boxNumber,
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
                          var tempDir = await getApplicationSupportDirectory();
                          String filePath =
                              '${tempDir.path}/${data[i].option4}';
                          await option4Player.setFilePath(filePath);
                          final duration = option4Player.duration;
                          Timer(duration!, () {
                            setState(() {
                              isOption4Playing = false;
                            });
                          });
                          if (data[i].option4Count < 2) {
                            option4Player.playing
                                ? option4Player.stop()
                                : option4Player.play();
                            setState(() {
                              isOption4Playing = !isOption4Playing;
                            });
                            if (option4Player.playing) {
                              data[i].option4Count++;
                            }
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
                                          child: FutureBuilder(
                                              future: _getLocalFile(
                                                  data[i].option4.toString()),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<File>
                                                      snapshot) {
                                                return snapshot.hasData
                                                    ? Image.file(
                                                        File(snapshot
                                                            .data!.path),
                                                        width:
                                                            screenSize.width *
                                                                0.4,
                                                        height: double.infinity,
                                                      )
                                                    : Container();
                                              }),
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
                          child: FutureBuilder(
                              future: _getLocalFile(data[i].option4.toString()),
                              builder: (BuildContext context,
                                  AsyncSnapshot<File> snapshot) {
                                return snapshot.hasData
                                    ? Image.file(
                                        File(snapshot.data!.path),
                                        height: screenSize.height * 0.13,
                                      )
                                    : Container();
                              }),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  void selectOption(
      String option, String selectedOption, List<OfflineQuestions> data) {
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
    List previousData = ModalRoute.of(context)!.settings.arguments as List;
    List<OfflineQuestions> data = previousData[0];

    //? Geting ExamType
    // ExamType examType = args['exam'];

    CountDownTimer counter = CountDownTimer(
      isStart: isTimerStart,
      time: const Duration(minutes: 40),
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

        // ref
        //     .read(questionControllerProvider(examType.id).notifier)
        //     .submitAnswer(questions: questionIds, answers: selectedAnswers)
        //     .then((value) {
        //   if (value[0] == 'false') {
        //     toast(context: context, label: value[1], color: Colors.red);
        //   } else {
        //     List<String> msg = [value[1], value[2]];
        //     SystemChrome.setPreferredOrientations([
        //       DeviceOrientation.portraitUp,
        //     ]);
        //     Navigator.of(context).pushReplacementNamed(
        //         QuizResultScreen.routeName,
        //         arguments: msg);
        //   }
        // });
      },
    );

    return Theme(
      data: ThemeData.light(
        useMaterial3: true,
      ),
      child: WillPopScope(
        onWillPop: () async {
          backPrompt(context);
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
                  data: data,
                  id: previousData[1],
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  (i > 1 && i < 8) || (i >= 12 && i <= 19)
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
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Text(
                                                '${i + 1}.',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      color: Colors.black,
                                                    ),
                                              ),
                                            ),
                                            data[i].question != null ||
                                                    data[i].isAudio == 'Yes'
                                                ? SizedBox(
                                                    width:
                                                        screenSize.width * 0.4,
                                                    child: Text(
                                                      data[i].question!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                          ),
                                                    ),
                                                  )
                                                : const SizedBox()
                                          ],
                                        ),
                                  // ! For Displaying audio
                                  data[i].isAudio == 'Yes'
                                      ? audioQuestion(screenSize, data, context)
                                      : data[i].filePath!.isNotEmpty
                                          ? imageWithAudio(
                                              context, data, screenSize)
                                          : data[i].audioPath != null
                                              ? audioQuestionWithOptionImage(
                                                  screenSize, data, context)
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
                                                  const EdgeInsets.all(8.0),
                                              child: optionBox1(
                                                option: data[i].option1,
                                                isImage: data[i].isImage,
                                                screenSize: screenSize,
                                                selectedOption: 'option1',
                                                isOptionAudio:
                                                    data[i].isOptionAudio,
                                                data: data,
                                                boxNumber: '1',
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: optionBox2(
                                                option: data[i].option2,
                                                isImage: data[i].isImage,
                                                screenSize: screenSize,
                                                isOptionAudio:
                                                    data[i].isOptionAudio,
                                                selectedOption: 'option2',
                                                data: data,
                                                boxNumber: '2',
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: optionBox3(
                                                option: data[i].option3,
                                                isImage: data[i].isImage,
                                                screenSize: screenSize,
                                                isOptionAudio:
                                                    data[i].isOptionAudio,
                                                selectedOption: 'option3',
                                                data: data,
                                                boxNumber: '3',
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: optionBox4(
                                                option: data[i].option4,
                                                isImage: data[i].isImage,
                                                screenSize: screenSize,
                                                isOptionAudio:
                                                    data[i].isOptionAudio,
                                                selectedOption: 'option4',
                                                data: data,
                                                boxNumber: '4',
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
                                          isOptionAudio: data[i].isOptionAudio,
                                          data: data,
                                          boxNumber: '1',
                                        ),
                                        optionBox2(
                                          option: data[i].option2,
                                          isImage: data[i].isImage,
                                          screenSize: screenSize,
                                          isOptionAudio: data[i].isOptionAudio,
                                          selectedOption: 'option2',
                                          data: data,
                                          boxNumber: '2',
                                        ),
                                        optionBox3(
                                          option: data[i].option3,
                                          isImage: data[i].isImage,
                                          screenSize: screenSize,
                                          isOptionAudio: data[i].isOptionAudio,
                                          selectedOption: 'option3',
                                          data: data,
                                          boxNumber: '3',
                                        ),
                                        optionBox4(
                                          option: data[i].option4,
                                          isImage: data[i].isImage,
                                          screenSize: screenSize,
                                          isOptionAudio: data[i].isOptionAudio,
                                          selectedOption: 'option4',
                                          data: data,
                                          boxNumber: '4',
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
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                          side: BorderSide(
                                              color: AppConstants.quizScreen),
                                          backgroundColor: Colors.transparent),
                                      onPressed: () {
                                        setState(() {
                                          isTotalQuestion = true;
                                        });
                                      },
                                      child: Text(
                                        'Total Questions',
                                        style: TextStyle(
                                            color: AppConstants.quizScreen),
                                      ),
                                    ),
                                  ),
                                  i == data.length - 1
                                      ? const SizedBox()
                                      : nextButton(
                                          data,
                                        ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  previousButton(
                                    data,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                          side: BorderSide(
                                              color: AppConstants.quizScreen),
                                          backgroundColor: Colors.transparent),
                                      onPressed: () {
                                        setState(() {
                                          isTotalQuestion = true;
                                        });
                                      },
                                      child: Text(
                                        'Total Questions',
                                        style: TextStyle(
                                            color: AppConstants.quizScreen),
                                      ),
                                    ),
                                  ),
                                  i == data.length - 1
                                      ? const SizedBox()
                                      : nextButton(
                                          data,
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
  }

  Container audioQuestionWithOptionImage(
      Size screenSize, List<OfflineQuestions> data, BuildContext context) {
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
            var tempDir = await getApplicationSupportDirectory();
            String filePath = tempDir.path + data[i].audioPath!;
            await player.setFilePath(filePath);
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
      Size screenSize, List<OfflineQuestions> data, BuildContext context) {
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
            log(data[i].questionCount.toString());
            //? For Audio Playing
            var tempDir = await getApplicationSupportDirectory();
            String filePath = '${tempDir.path}/${data[i].filePath!}';
            await player.setFilePath(filePath);

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

  Future<File> _getLocalFile(String filename) async {
    String dir = (await getApplicationSupportDirectory()).path;
    File f = File('$dir/$filename');
    return f;
  }

  InkWell imageWithAudio(
      BuildContext context, List<OfflineQuestions> data, Size screenSize) {
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
                    child: FutureBuilder(
                        future: _getLocalFile(data[i].filePath.toString()),
                        builder: (BuildContext context,
                            AsyncSnapshot<File> snapshot) {
                          return snapshot.data != null
                              ? Image.file(
                                  File(snapshot.data!.path),
                                  // width: double.infinity,
                                  height: screenSize.height * 0.3,
                                  fit: BoxFit.contain,
                                )
                              : Container();
                        }),
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
            FutureBuilder(
                future: _getLocalFile(data[i].filePath.toString()),
                builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                  return snapshot.data != null
                      ? Image.file(
                          File(snapshot.data!.path),
                          width: double.infinity,
                          height: screenSize.height * 0.3,
                          fit: BoxFit.contain,
                        )
                      : Container();
                }),
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
                        var tempDir = await getApplicationSupportDirectory();
                        String filePath =
                            '${tempDir.path}/${data[i].audioPath!}';
                        await player.setFilePath(filePath);
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

  void backPrompt(BuildContext context) {
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
                    DownloadedExamScreens.routeName,
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

  Padding nextButton(
    List<OfflineQuestions> data,
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
    List<OfflineQuestions> data,
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
      required List<OfflineQuestions> data,
      required String id}) {
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
                                    submitAnswers(data: data, id: id);
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
                                    // submitAnswers(
                                    //     examType: examType, data: data);
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
      {required List<OfflineQuestions> data, required String id}) {
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

    List<String> message = ref.read(offlineStorageProvider).calculateScore(
          answers: selectedAnswers,
          questions: questionIds,
          data: data,
          id: id,
        );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    Navigator.of(context).pop();
    Navigator.of(context)
        .pushReplacementNamed(OfflineScoreCard.routeName, arguments: message);
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
  final List<OfflineQuestions> data;

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
            crossAxisAlignment: i >= 2 && i <= 7
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
