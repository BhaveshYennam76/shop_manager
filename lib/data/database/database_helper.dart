import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shop_manager/core/constants/app_constants.dart';
import 'package:shop_manager/data/models/shop_model.dart';

/// Singleton helper for all SQLite database operations.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  /// Returns the existing database or initializes a new one.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ── Initialization ────────────────────────────────────────────────────────

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

  /// Creates the shops table on first run.
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

  /// Handles future schema migrations.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here.
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Inserts a [Shop] and returns its auto-generated id.
  Future<int> insertShop(Shop shop) async {
    final db = await database;
    return db.insert(
      AppConstants.tableShops,
      shop.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetches all shops ordered by id descending (newest first).
  Future<List<Shop>> fetchAllShops() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableShops,
      orderBy: '${AppConstants.colId} DESC',
    );
    return maps.map(Shop.fromMap).toList();
  }

  /// Updates an existing [Shop] by its id.
  Future<int> updateShop(Shop shop) async {
    final db = await database;
    return db.update(
      AppConstants.tableShops,
      shop.toMap(),
      where: '${AppConstants.colId} = ?',
      whereArgs: [shop.id],
    );
  }

  /// Deletes a shop by its [id].
  Future<int> deleteShop(int id) async {
    final db = await database;
    return db.delete(
      AppConstants.tableShops,
      where: '${AppConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
