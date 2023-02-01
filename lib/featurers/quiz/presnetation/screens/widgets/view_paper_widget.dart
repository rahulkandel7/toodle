import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:toddle/featurers/quiz/data/models/questions.dart';

import '../../../../../constants/api_constants.dart';
import '../../../../../constants/app_constants.dart';

class ViewPaperWidget extends StatelessWidget {
  Questions questions;
  ViewPaperWidget({required this.questions, super.key});

  //Widget For Option Box
  Widget optionBox({
    required String isImage,
    required Size screenSize,
    required String option,
    required String options,
    required String userSelected,
    required String correctOption,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: screenSize.height * 0.02),
      child: InkWell(
        onTap: () {},
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
              questions.question,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),

        questions.isAudio == 'Yes'
            ? IconButton(
                onPressed: () async {
                  //For Audio Playing
                },
                icon: const Icon(
                  Icons.play_circle_outline,
                  size: 32,
                ),
              )
            : questions.filePath != null
                ? CachedNetworkImage(
                    imageUrl:
                        '${ApiConstants.questionFileUrl}${questions.filePath}',
                    height: screenSize.height * 0.17,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox(),
        //Option Box
        optionBox(
          isImage: questions.isImage,
          screenSize: screenSize,
          option: questions.option1,
          options: 'option1',
          correctOption: questions.correctOption,
          userSelected: questions.selectedOption!,
        ),
        optionBox(
          isImage: questions.isImage,
          screenSize: screenSize,
          option: questions.option2,
          options: 'option2',
          userSelected: questions.selectedOption!,
          correctOption: questions.correctOption,
        ),
        optionBox(
          isImage: questions.isImage,
          screenSize: screenSize,
          option: questions.option3,
          options: 'option3',
          userSelected: questions.selectedOption!,
          correctOption: questions.correctOption,
        ),
        optionBox(
          isImage: questions.isImage,
          screenSize: screenSize,
          option: questions.option4,
          options: 'option4',
          userSelected: questions.selectedOption!,
          correctOption: questions.correctOption,
        ),
      ],
    );
  }
}
