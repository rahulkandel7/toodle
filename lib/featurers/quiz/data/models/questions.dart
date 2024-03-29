class Questions {
  final int id;
  final String? question;
  final String? subQuestion;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final String correctOption;
  final String? filePath;
  final String questionSetsId;
  final String isImage;
  final String isAudio;
  final String isOptionAudio;
  final String? selectedOption;
  final String? audioPath;
  final String category;
  int questionCount;
  int audioPathcount;
  int option1Count;
  int option2Count;
  int option3Count;
  int option4Count;

  Questions({
    required this.id,
    required this.question,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctOption,
    required this.filePath,
    required this.questionSetsId,
    required this.isImage,
    required this.isAudio,
    required this.selectedOption,
    required this.isOptionAudio,
    required this.category,
    required this.subQuestion,
    required this.audioPath,
    this.audioPathcount = 0,
    this.option1Count = 0,
    this.option2Count = 0,
    this.option3Count = 0,
    this.option4Count = 0,
    this.questionCount = 0,
  });

  factory Questions.fromMap(Map<String, dynamic> map) {
    return Questions(
      id: map['id'] as int,
      question: map['question'] != null ? map['question'] as String : '',
      option1: map['option1'] as String,
      option2: map['option2'] as String,
      option3: map['option3'] as String,
      option4: map['option4'] as String,
      category: map['category'] as String,
      correctOption: map['correct_option'].toString(),
      filePath: map['filepath'] != null ? map['filepath'] as String : '',
      subQuestion:
          map['sub_question'] != null ? map['sub_question'] as String : null,
      questionSetsId: map['question_sets_id'].toString(),
      isImage: map['isImage'] as String,
      isAudio: map['isAudio'] as String,
      isOptionAudio: map['isOptionAudio'] as String,
      selectedOption: map['selected_option'] != null
          ? map['selected_option'] as String
          : null,
      audioPath: map['audiopath'] != null ? map['audiopath'] as String : null,
    );
  }
}
