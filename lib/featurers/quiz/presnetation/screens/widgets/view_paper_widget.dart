import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:toddle/featurers/quiz/data/models/questions.dart';

import '../../../../../constants/api_constants.dart';
import '../../../../../constants/app_constants.dart';

class ViewPaperWidget extends StatefulWidget {
  final Questions questions;
  const ViewPaperWidget({required this.questions, super.key});

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
                    : AppConstants.optionBoxColor,
          ),
        ),
        enableFeedback: true,
        selectedTileColor: AppConstants.optionBoxColor,
        minLeadingWidth: double.infinity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        //Showing Question
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.03),
          child: Center(
            child: Text(
              widget.questions.question,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),

        widget.questions.isAudio == 'Yes' ||
                widget.questions.isOptionAudio == 'Yes'
            ? IconButton(
                onPressed: () async {
                  //For Audio Playing
                  await player.setUrl(
                    '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
                  );
                  isQusPlaying ? player.stop() : player.play();
                  setState(() {
                    isQusPlaying = !isQusPlaying;
                  });
                },
                icon: const Icon(
                  Icons.play_circle_outline,
                  size: 32,
                ),
              )
            : widget.questions.filePath != null
                ? InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: InteractiveViewer(
                              child: Image.network(
                                '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
                                fit: BoxFit.fill,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl:
                          '${ApiConstants.questionFileUrl}${widget.questions.filePath}',
                      height: screenSize.height * 0.17,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : const SizedBox(),
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
}
