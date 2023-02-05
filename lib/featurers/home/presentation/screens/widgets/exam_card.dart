import 'package:flutter/material.dart';
import 'package:toddle/featurers/home/data/models/exam_type.dart';
import 'package:toddle/featurers/home/presentation/screens/set_screen.dart';

class ExamCard extends StatelessWidget {
  final ExamType examType;
  const ExamCard({required this.examType, super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(SetScreen.routeName, arguments: examType);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
        child: ListTile(
          tileColor: Colors.indigo.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.indigo,
            child: Icon(
              Icons.text_snippet_outlined,
              size: Theme.of(context).textTheme.headlineSmall!.fontSize,
              color: Colors.white,
            ),
          ),
          title: Text(
            examType.examType,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          trailing: const Icon(
            Icons.arrow_circle_right_outlined,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }
}
