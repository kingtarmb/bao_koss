// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._();
  LocalDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      join(dir, 'bao_koss.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE missions(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            village TEXT,
            date TEXT,
            time TEXT,
            status TEXT,
            budget INTEGER,
            synced INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE sync_queue(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entity TEXT NOT NULL,
            action TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE attendance(
            id TEXT PRIMARY KEY,
            mission_id TEXT,
            type TEXT,
            latitude REAL,
            longitude REAL,
            accuracy REAL,
            created_at TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> queueSync(String entity, String action, String payload) async {
    final db = await database;
    await db.insert('sync_queue', {
      'entity': entity,
      'action': action,
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> pendingSync() async {
    final db = await database;
    return db.query('sync_queue', orderBy: 'id ASC');
  }

  Future<void> deleteSync(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveAttendance(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('attendance', data,
      conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
