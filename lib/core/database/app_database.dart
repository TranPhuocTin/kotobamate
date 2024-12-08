import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

abstract class AppDatabase {
  // Database connection methods
  Future<Database> get database;
  Future<void> initDatabase();
  Future<void> closeDatabase();
  
  // Generic CRUD operations
  Future<T> insert<T>(String table, Map<String, dynamic> data);
  Future<List<T>> query<T>(String table, {String? where, List<dynamic>? whereArgs});
  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs});
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs});
}
