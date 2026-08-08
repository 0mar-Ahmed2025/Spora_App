import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static String? _databasePathOverride;

  DatabaseHelper._init();

  /// Points the singleton at a custom database file for tests.
  ///
  /// Pass [inMemoryDatabasePath] to use a fresh in-memory database, or a
  /// custom file path to verify persistence across reopens.
  @visibleForTesting
  static Future<void> resetForTesting({String? databasePath}) async {
    final db = _database;
    _database = null;
    _databasePathOverride = databasePath;
    if (db != null) {
      try {
        await db.close();
      } catch (_) {}
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath =
        _databasePathOverride ??
        join(await getDatabasesPath(), 'reports_queue.db');

    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports (
        local_id TEXT PRIMARY KEY,
        server_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category_id TEXT NOT NULL,
        priority TEXT NOT NULL,
        image_path TEXT,
        latitude REAL,
        longitude REAL,
        status TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
