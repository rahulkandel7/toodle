import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddle/constants/app_constants.dart';
import 'package:toddle/core/darkmode_notifier.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/home/presentation/screens/set_screen.dart';

class ExamCard extends StatelessWidget {
  final ExamType examType;
  const ExamCard({required this.examType, super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: Card(
        // color: Colors.pink.shade100,
        elevation: 5,
        shadowColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.02,
            horizontal: screenSize.width * 0.05,
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppConstants.primaryColor,
                      child: Icon(
                        Icons.text_snippet_outlined,
                        size:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      examType.examType,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        var darkmode = ref.read(darkmodeNotifierProvider);
                        return Icon(
                          Icons.arrow_circle_right_outlined,
                          color: darkmode
                              ? Colors.white
                              : AppConstants.primaryColor,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey.shade400,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(SetScreen.routeName, arguments: examType);
                    },
                    child: const Text(
                      'View Set',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
