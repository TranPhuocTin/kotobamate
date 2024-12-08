class Folder {
  final String id;
  final String name;
  final DateTime createdAt;
  final int wordCount;

  const Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.wordCount,
  });

  Map<String, dynamic> toMap() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': timestamp,
      'word_count': wordCount,
    };
  }

  static Folder fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      wordCount: map['word_count'] as int,
    );
  }
}
