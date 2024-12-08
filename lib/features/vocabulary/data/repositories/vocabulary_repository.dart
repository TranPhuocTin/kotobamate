import 'package:kotobamate/core/database/app_database.dart';
import 'package:kotobamate/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:kotobamate/features/home/data/database_helper.dart';

class VocabularyRepository {
  final DatabaseHelper _databaseHelper;

  VocabularyRepository(this._databaseHelper);

  Future<void> insertVocabulary({
    required int folderId,
    required String japanese,
    required String meaning,
  }) async {
    await _databaseHelper.insert(
      'vocabularies',
      {
        'folder_id': folderId,
        'japanese': japanese,
        'meaning': meaning,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getVocabulariesByFolder(int folderId) async {
    return await _databaseHelper.query(
      'vocabularies',
      where: 'folder_id = ?',
      whereArgs: [folderId],
    );
  }

  Future<void> updateFolderWordCount({
    required int folderId, 
    required int increment,
  }) async {
    // Lấy word count hiện tại
    final result = await _databaseHelper.query(
      'folders',
      where: 'id = ?',
      whereArgs: [folderId.toString()],
    );
    
    if (result.isNotEmpty) {
      final currentWordCount = result.first['word_count'] as int;
      final newWordCount = currentWordCount + increment;
      
      print('Current word count: $currentWordCount');
      print('New word count: $newWordCount');
      
      // Cập nhật word count mới
      await _databaseHelper.update(
        'folders',
        {'word_count': newWordCount},
        where: 'id = ?',
        whereArgs: [folderId.toString()],
      );
    }
  }
} 