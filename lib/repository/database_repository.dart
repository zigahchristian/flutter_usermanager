import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseHelper {
  static const String _databaseName = 'shop.db';
  static const int _databaseVersion = 1;

  static Database? _database; // global DB

  // ---- GLOBAL OPEN DATABASE ---- //
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ---- INIT DB ---- //
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // ---- CREATE TABLE ---- //
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE
      )
    ''');

    await db.insert('users', {
      'name': 'Christian Zigah',
      'email': 'manchristiano@gmail.com'
    });
  }

  // ---- CRUD OPERATIONS ---- //

  static Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((json) => User.fromMap(json)).toList();
  }

  static Future<User?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  static Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  static Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
