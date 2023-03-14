import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:toddle/core/darkmode_notifier.dart';
import 'package:toddle/featurers/quiz/data/models/questions.dart';

import '../../../../../constants/api_constants.dart';
import '../../../../../constants/app_constants.dart';

class ViewPaperWidget extends StatefulWidget {
  final Questions questions;
  final int i;
  const ViewPaperWidget({required this.questions, required this.i, super.key});

  @override
  State<ViewPaperWidget> createState() => _ViewPaperWidgetState();
}

class _ViewPaperWidgetState extends State<ViewPaperWidget> {
  final player = AudioPlayer();

  @override
  void dispose() {
    super.dispose();
    player.stop();
  }

  // Audio bool for question
  bool isQusPlaying = false;

  //Widget For Option Box
  Widget optionBox({
    required String isImage,
    required Size screenSize,
    required String option,
    required String options,
    required String isOptionAudio,
    required String userSelected,
    required String correctOption,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        bool darkmode = ref.watch(darkmodeNotifierProvider);
        return Padding(
          padding: EdgeInsets.only(top: screenSize.height * 0.02),
          child: ListTile(
            title: isOptionAudio == 'Yes'
                ? IconButton(
                    onPressed: () async {
                      //For Audio Playing
                      await player.setUrl(
                        '${ApiConstants.answerImageUrl}$option',
                      );
                      player.playing ? player.stop() : player.play();
                    },
                    icon: const Icon(
                      Icons.play_circle_outline,
                      size: 32,
                    ),
                  )
                : isImage == 'No'
                    ? Text(option)
                    : InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: InteractiveViewer(
                                  child: Image.network(
                                    '${ApiConstants.answerImageUrl}$option',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: '${ApiConstants.answerImageUrl}$option',
                          height: screenSize.height * 0.1,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
            textColor: options == correctOption
                ? Colors.white
                : options == userSelected
                    ? Colors.white
                    : darkmode
                        ? Colors.white
                        : Colors.black,
            tileColor: options == correctOption
                ? Colors.green
                : options == userSelected
                    ? Colors.red
                    : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
              side: BorderSide(
                color: options == correctOption
                    ? Colors.transparent
                    : options == userSelected
                        ? Colors.transparent
                        : darkmode
                            ? Colors.white
                            : AppConstants.optionBoxColor,
              ),
            ),
            enableFeedback: true,
            selectedTileColor: AppConstants.optionBoxColor,
            minLeadingWidth: double.infinity,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Showing Category
        Padding(
          padding: EdgeInsets.only(top: screenSize.height * 0.03),
          child: Text(
            widget.questions.category,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        //? Showing Question
        (widget.i > 1 && widget.i < 8) || (widget.i >= 12 && widget.i <= 19)
            ? QuestionWithBorder(
                screenSize: screenSize, i: widget.i, data: widget.questions)
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${widget.i + 1}.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.black,
                          ),
                    ),
                  ),
                  widget.questions.question != null ||
                          widget.questions.isAudio == 'Yes'
                      ? SizedBox(
                          width: screenSize.width * 0.4,
                          child: Text(
                            widget.questions.question!,
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.black,
                                    ),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
        // ! For Displaying audio
        widget.questions.isAudio == 'Yes'
            ? audioQuestion(screenSize, widget.questions, context)
            : widget.questions.filePath!.isNotEmpty
                ? imageWithAudio(context, widget.questions, screenSize)
                : widget.questions.audioPath != null
                    ? audioQuestionWithOptionImage(
                        screenSize, widget.questions, context)
                    : const SizedBox(),

        //Showing Question
        // Padding(
        //   padding: EdgeInsets.only(bottom: screenSize.height * 0.01),
        //   child: Center(
        //     child: Text(
        //       widget.questions.question!,
        //       style: Theme.of(context).textTheme.headlineSmall!.copyWith(
        //             fontWeight: FontWeight.bold,
        //           ),
        //     ),
        //   ),
        // ),

        // widget.questions.isAudio == 'Yes' ||
        //         widget.questions.isOptionAudio == 'Yes'
        //     ? IconButton(
        //         onPressed: () async {
        //           //For Audio Playing
        //           await player.setUrl(
        //             '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
        //           );
        //           isQusPlaying ? player.stop() : player.play();
        //           setState(() {
        //             isQusPlaying = !isQusPlaying;
        //           });
        //         },
        //         icon: const Icon(
        //           Icons.play_circle_outline,
        //           size: 32,
        //         ),
        //       )
        //     : widget.questions.filePath!.isNotEmpty
        //         ? InkWell(
        //             onTap: () {
        //               showDialog(
        //                 context: context,
        //                 builder: (context) {
        //                   return AlertDialog(
        //                     content: InteractiveViewer(
        //                       child: Image.network(
        //                         '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
        //                         fit: BoxFit.fill,
        //                       ),
        //                     ),
        //                   );
        //                 },
        //               );
        //             },
        //             child: Container(
        //               width: double.infinity,
        //               padding: const EdgeInsets.all(8.0),
        //               decoration: BoxDecoration(
        //                 border: Border.all(color: Colors.grey.shade400),
        //               ),
        //               child: CachedNetworkImage(
        //                 imageUrl:
        //                     '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
        //                 height: screenSize.height * 0.17,
        //                 placeholder: (context, url) => const Center(
        //                   child: CircularProgressIndicator(),
        //                 ),
        //               ),
        //             ),
        //           )
        //         : const SizedBox(),
        //Option Box
        optionBox(
          isImage: widget.questions.isImage,
          screenSize: screenSize,
          option: widget.questions.option1,
          options: 'option1',
          correctOption: widget.questions.correctOption,
          userSelected: widget.questions.selectedOption!,
          isOptionAudio: widget.questions.isOptionAudio,
        ),
        optionBox(
          isImage: widget.questions.isImage,
          screenSize: screenSize,
          option: widget.questions.option2,
          options: 'option2',
          userSelected: widget.questions.selectedOption!,
          isOptionAudio: widget.questions.isOptionAudio,
          correctOption: widget.questions.correctOption,
        ),
        optionBox(
          isImage: widget.questions.isImage,
          screenSize: screenSize,
          option: widget.questions.option3,
          options: 'option3',
          userSelected: widget.questions.selectedOption!,
          correctOption: widget.questions.correctOption,
          isOptionAudio: widget.questions.isOptionAudio,
        ),
        optionBox(
          isImage: widget.questions.isImage,
          screenSize: screenSize,
          option: widget.questions.option4,
          options: 'option4',
          userSelected: widget.questions.selectedOption!,
          isOptionAudio: widget.questions.isOptionAudio,
          correctOption: widget.questions.correctOption,
        ),
      ],
    );
  }

  Container audioQuestionWithOptionImage(
      Size screenSize, Questions data, BuildContext context) {
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
          //? For Audio Playing
          await player.setUrl(
            '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
          );
          isQusPlaying ? player.stop() : player.play();
          setState(() {
            isQusPlaying = !isQusPlaying;
          });
        },
        icon: Icon(
          isQusPlaying ? Icons.pause_circle_filled_rounded : Icons.volume_down,
          size: 32,
          color: Colors.black,
        ),
      ),
    );
  }

  Container audioQuestion(
      Size screenSize, Questions data, BuildContext context) {
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
          //? For Audio Playing
          await player.setUrl(
            '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
          );
          isQusPlaying ? player.stop() : player.play();
          setState(() {
            isQusPlaying = !isQusPlaying;
          });
        },
        icon: Icon(
          isQusPlaying ? Icons.pause_circle_filled_rounded : Icons.volume_down,
          size: 32,
          color: Colors.black,
        ),
      ),
    );
  }

  InkWell imageWithAudio(
      BuildContext context, Questions data, Size screenSize) {
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
                            '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
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
        height: widget.questions.audioPath != null
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
              imageUrl:
                  '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
              width: double.infinity,
              height: screenSize.height * 0.3,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            const Divider(),
            widget.questions.audioPath != null
                ? IconButton(
                    onPressed: () async {
                      //? For Audio Playing

                      //? For Audio Playing
                      await player.setUrl(
                        '${ApiConstants.questionFileUrl}${widget.questions.audioPath}',
                      );
                      isQusPlaying ? player.stop() : player.play();
                      setState(() {
                        isQusPlaying = !isQusPlaying;
                      });
                    },
                    icon: Icon(
                      isQusPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.volume_down,
                      size: 32,
                      color: Colors.black,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
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
  final Questions data;

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
                child: data.question != null
                    ? Text(
                        data.question!,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.black,
                            ),
                      )
                    : const SizedBox(),
              ),
              // Showing Sub Question
              data.subQuestion != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        bottom: screenSize.height * 0.03,
                      ),
                      child: Text(
                        '${data.subQuestion}',
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
