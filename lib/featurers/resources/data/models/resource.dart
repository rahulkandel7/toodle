// ignore_for_file: public_member_api_docs, sort_constructors_first

class Resource {
  final int id;
  final String topicId;
  final String title;
  final String filePath;
  final String type;

  Resource({
    required this.id,
    required this.topicId,
    required this.title,
    required this.filePath,
    required this.type,
  });

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'] as int,
      topicId: map['topic_id'] as String,
      title: map['title'] as String,
      filePath: map['filepath'] as String,
      type: map['type'] as String,
    );
  }
}
