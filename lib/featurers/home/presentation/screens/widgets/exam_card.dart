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
      child: Card(
        elevation: 7,
        shadowColor: Colors.grey.shade100,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.02,
            horizontal: screenSize.width * 0.05,
          ),
          child: Text(
            examType.examType,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
