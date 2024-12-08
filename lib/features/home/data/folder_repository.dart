import 'package:kotobamate/core/database/app_database.dart';
import 'package:kotobamate/features/home/domain/entities/folder.dart';

class FolderRepository {
  final AppDatabase _database;
  
  FolderRepository(this._database);
  
  Future<Folder> createFolder(Folder folder) async {
    final result = await _database.insert('folders', folder.toMap());
    return folder;
  }
  
  Future<List<Folder>> getAllFolders() async {
    final maps = await _database.query('folders');
    return maps.map((map) => Folder.fromMap(map)).toList();
  }
  // Other folder-specific operations
} 