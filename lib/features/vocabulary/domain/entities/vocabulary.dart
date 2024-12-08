class Vocabulary {
  final int id;
  final String word;
  final String meaning;
  final int folderId;
  final DateTime createdAt;

  const Vocabulary({
    required this.id,
    required this.word,
    required this.meaning,
    required this.folderId,
    required this.createdAt,
  });

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'] as int,
      word: map['word'] as String,
      meaning: map['meaning'] as String,
      folderId: map['folder_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'folder_id': folderId,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 