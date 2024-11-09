import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _database;

  DBHelper._();

  factory DBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'wattsync.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Aqui você cria as tabelas, se necessário, mas como já temos o esquema, você pode omitir essa parte.
  }

  // Método para pegar dados da tabela 'seconds'
  Future<List<Map<String, dynamic>>> getSecondsData(String selection) async {
    Database db =
        await database; // Sua lógica para obter a instância do banco de dados
    List<Map<String, dynamic>> results = [];

    if (selection == 'Últimas 24h') {
      results = await db.query('last_24_hours'); // Obtém todos os dados
    } else if (selection == 'Últimos 30 dias') {
      results = await db.query('last_30_days');
    } else if (selection == 'Últimos 12 meses') {
      results = await db.query('last_12_months');
    }
    // Adicione outros casos conforme necessário
    return results;
  }
}
