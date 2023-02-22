class Notices {
  final int id;
  final String date;
  final String notice;

  Notices({
    required this.id,
    required this.date,
    required this.notice,
  });

  factory Notices.fromMap(Map<String, dynamic> map) {
    return Notices(
      id: map['id'] as int,
      date: map['date'] as String,
      notice: map['notice'] as String,
    );
  }
}
