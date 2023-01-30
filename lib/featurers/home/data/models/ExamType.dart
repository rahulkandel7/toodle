// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ExamType {
  final String examType;
  final int time;
  final String maxModelSet;

  ExamType({
    required this.examType,
    required this.maxModelSet,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'examType': examType,
      'time': time,
      'maxModelSet': maxModelSet,
    };
  }

  factory ExamType.fromMap(Map<String, dynamic> map) {
    return ExamType(
      examType: map['exam_type'] as String,
      time: map['time'] as int,
      maxModelSet: map['maxmodelset'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExamType.fromJson(String source) =>
      ExamType.fromMap(json.decode(source) as Map<String, dynamic>);
}
