import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/entities/folder.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kotobamate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

 Future<void> _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE folders(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      word_count INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await db.execute('''
    CREATE TABLE vocabularies(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      folder_id TEXT NOT NULL,
      japanese TEXT NOT NULL,
      meaning TEXT NOT NULL,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
      FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
    )
  ''');

  await db.execute(
    'CREATE INDEX idx_vocabularies_folder_id ON vocabularies(folder_id)'
  );
}

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE folders ADD COLUMN word_count INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<Folder> createFolder(Folder folder) async {
    try {
      print('DatabaseHelper: Creating folder in database');
      final db = await database;
      print('DatabaseHelper: Database connection established');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final result = await db.insert(
        'folders',
        {
          'id': folder.id,
          'name': folder.name,
          'created_at': folder.createdAt.millisecondsSinceEpoch,
          'updated_at': timestamp,
          'word_count': folder.wordCount,
        },
      );
      print('DatabaseHelper: Insert result: $result');
      return folder;
    } catch (e) {
      print('DatabaseHelper Error: $e');
      throw e;
    }
  }

  Future<List<Folder>> getAllFolders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('folders');

    return maps
        .map((map) => Folder(
              id: map['id'],
              name: map['name'],
              createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
              wordCount: map['word_count'],
            ))
        .toList();
  }

  Future<int> deleteFolder(String id) async {
    try {
      print('DatabaseHelper: Deleting folder with id: $id');
      final db = await database;
      final result = await db.delete(
        'folders',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result;
    } catch (e) {
      print('DatabaseHelper Error: $e');
      if (e.toString().contains('database_closed')) {
        _database = null;
        final db = await database;
        return await db.delete(
          'folders',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      throw e;
    }
  }

  Future<int> updateFolder(String id, String newName) async {
    try {
      print('DatabaseHelper: Updating folder $id with new name: $newName');
      final db = await database;
      return await db.update(
        'folders',
        {'name': newName},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('DatabaseHelper Error: $e');
      throw e;
    }
  }

  Future<void> deleteDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'kotobamate.db');
      
      // Đóng kết nối database hiện tại nếu có
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      // Xóa file database
      await databaseFactory.deleteDatabase(path);
      print('Database deleted successfully');
    } catch (e) {
      print('Error deleting database: $e');
      throw e;
    }
  }

  Future<void> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    await db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> rawUpdate(String sql, List<dynamic> arguments) async {
    final db = await database;
    await db.rawUpdate(sql, arguments);
  }

  Future<void> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    await db.update(table, values, where: where, whereArgs: whereArgs);
  }
}
