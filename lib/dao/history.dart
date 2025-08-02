import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/history_model.dart';  // Importando o modelo

class HistoryDAO {
  static const String _dbName = 'game_history.db';
  static const String _tableName = 'gameHistory';

  static Database? _database;

  // Inicializa o banco de dados
  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }
    // Se o banco não existir, cria
    _database = await _initDB();
    return _database!;
  }

  // Método para inicializar o banco de dados
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            round INTEGER,
            timestamp TEXT,
            action TEXT,
            player TEXT,
            game TEXT,
            amount INTEGER,
            details TEXT,
            potAfter INTEGER,
            leftValueAfter INTEGER,
            rightValueAfter INTEGER
          )
        ''');
      },
    );
  }

  // Função para inserir um novo histórico
  Future<void> insertHistory(HistoryModel history) async {
    final db = await _db;
    await db.insert(
      _tableName,
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Substitui se já existir
    );
  }

  // Função para pegar todos os históricos
  Future<List<HistoryModel>> getHistory() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return HistoryModel.fromMap(maps[i]);
    });
  }

  // Função para deletar um histórico
  Future<void> deleteHistory(int id) async {
    final db = await _db;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Função para limpar todos os registros
  Future<void> deleteAllHistory() async {
    final db = await _db;
    await db.delete(_tableName);
  }
}
