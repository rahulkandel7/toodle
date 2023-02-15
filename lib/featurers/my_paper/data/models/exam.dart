class Exam {
  final int id;
  final String examDate;
  final String examType;

  Exam({
    required this.id,
    required this.examDate,
    required this.examType,
  });

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'] as int,
      examDate: map['exam_date'] as String,
      examType: map['examType'] == null ? '' : map['examType'] as String,
    );
  }
}
