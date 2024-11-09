import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'wattsync.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Aqui você pode criar suas tabelas, se ainda não existirem.
      },
    );
  }

  Future<List<Map<String, dynamic>>> getLast24HoursData() async {
    final db = await database;
    return await db.query('last_24_hours');
  }
}

Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
      CREATE TABLE IF NOT EXISTS alarmes (
        alarme_id INTEGER PRIMARY KEY AUTOINCREMENT,
        status_boolean INTEGER,
        hora_inicio TEXT NOT NULL,
        hora_fim TEXT NOT NULL,
        seg_semana INTEGER,
        ter_semana INTEGER,
        qua_semana INTEGER,
        qui_semana INTEGER,
        sex_semana INTEGER,
        sab_semana INTEGER,
        dom_semana INTEGER
      )
    ''');
}

// Funções para alarmes
Future<int> insertAlarm(Map<String, dynamic> alarm, dynamic database) async {
  final db = await database;
  return await db.insert('alarmes', alarm);
}

Future<List<Map<String, dynamic>>> getAllAlarms(dynamic database) async {
  final db = await database;
  return await db.query('alarmes');
}

Future<int> deleteAlarm(int id, dynamic database) async {
  final db = await database;
  return await db.delete('alarmes', where: 'alarme_id = ?', whereArgs: [id]);
}

Future<int> updateAlarm(
    int id, Map<String, dynamic> alarm, dynamic database) async {
  final db = await database;
  return await db
      .update('alarmes', alarm, where: 'alarme_id = ?', whereArgs: [id]);
}

// Funções para histórico (exemplo)
Future<int> insertHistorico(
    Map<String, dynamic> historico, dynamic database) async {
  final db = await database;
  return await db.insert('historico', historico);
}

Future<List<Map<String, dynamic>>> getAllHistorico(dynamic database) async {
  final db = await database;
  return await db.query('historico');
}
