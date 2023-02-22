class Group {
  final int id;
  final String groupName;

  Group({
    required this.id,
    required this.groupName,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as int,
      groupName: map['name'] as String,
    );
  }
}
