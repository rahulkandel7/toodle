import 'package:flutter/material.dart';

class ExamCard extends StatelessWidget {
  final String examType;
  const ExamCard({required this.examType, super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Card(
      elevation: 7,
      shadowColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.05,
        ),
        child: Text(
          examType,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
