import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'package:path/path.dart';

class SqliteDatabase implements AppDatabase {
  static Database? _database;
  
  @override
  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  @override
  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kotobamate.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
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
      CREATE TABLE vocabulary(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_id TEXT NOT NULL,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');
  }

  @override 
  Future<T> insert<T>(String table, Map<String, dynamic> data) async {
    final db = await database;
    final id = await db.insert(table, data);
    return data as T;
  }

  @override
  Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }

  @override
  Future<List<T>> query<T>(String table, {String? where, List<dynamic>? whereArgs}) async {
    print('SqliteDatabase - Executing query on table: $table');
    print('SqliteDatabase - Where clause: $where');
    print('SqliteDatabase - Where args: $whereArgs (types: ${whereArgs?.map((e) => e.runtimeType).toList()})');
    
    final db = await database;
    final result = await db.query(table, where: where, whereArgs: whereArgs);
    print('SqliteDatabase - Query result: $result');
    
    return result as List<T>;
  }

  @override
  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> deleteDatabase() async {
    print('SqliteDatabase - Deleting database...');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kotobamate.db');
    
    // Đóng kết nối hiện tại
    await closeDatabase();
    
    // Xóa file database
    if (await databaseExists(path)) {
      print('SqliteDatabase - Database exists, deleting...');
      await databaseFactory.deleteDatabase(path);
      print('SqliteDatabase - Database deleted successfully');
    }
  }

  // Implement other methods from AppDatabase...
} 