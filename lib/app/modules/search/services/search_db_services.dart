
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ustahub/app/modules/search/model_class/seach_model.dart';

class SearchDBService {
  static final SearchDBService _instance = SearchDBService._();
  factory SearchDBService() => _instance;
  SearchDBService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return await _initDB();
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'searches.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE searches (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          keyword TEXT
        )
      ''');
    });
  }

  Future<void> insertSearch(String keyword) async {
    final db = await database;
    await db.insert('searches', {'keyword': keyword});
  }

  Future<List<SearchModel>> getAllSearches() async {
    final db = await database;
    final maps = await db.query('searches', orderBy: 'id DESC');

    return maps.map((e) => SearchModel.fromMap(e)).toList();
  }

  Future<void> deleteSearch(int id) async {
    final db = await database;
    await db.delete('searches', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('searches');
  }
}
