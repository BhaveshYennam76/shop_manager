import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shop_manager/core/constants/app_constants.dart';
import 'package:shop_manager/data/models/shop_model.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  // get db (init if needed)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // setup db
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // create table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableShops} (
        ${AppConstants.colId}          INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppConstants.colName}        TEXT    NOT NULL,
        ${AppConstants.colAddress}     TEXT    NOT NULL,
        ${AppConstants.colMobile}      TEXT    NOT NULL,
        ${AppConstants.colEmail}       TEXT    NOT NULL,
        ${AppConstants.colDescription} TEXT    NOT NULL
      )
    ''');
  }

  // future upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // handle schema changes later
  }

  // insert
  Future<int> insertShop(Shop shop) async {
    final db = await database;
    return db.insert(
      AppConstants.tableShops,
      shop.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // fetch all
  Future<List<Shop>> fetchAllShops() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableShops,
      orderBy: '${AppConstants.colId} DESC',
    );
    return maps.map(Shop.fromMap).toList();
  }

  // update
  Future<int> updateShop(Shop shop) async {
    final db = await database;
    return db.update(
      AppConstants.tableShops,
      shop.toMap(),
      where: '${AppConstants.colId} = ?',
      whereArgs: [shop.id],
    );
  }

  // delete
  Future<int> deleteShop(int id) async {
    final db = await database;
    return db.delete(
      AppConstants.tableShops,
      where: '${AppConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  // close db
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}