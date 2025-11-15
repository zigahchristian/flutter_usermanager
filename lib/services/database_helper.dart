// lib/services/database_helper.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class DatabaseHelper {
  static const String _databaseName = 'shop.db';
  static const int _databaseVersion = 1;
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        avatar_path TEXT,
        created_at INTEGER
      )
    ''');
  }

  // ---- CRUD OPERATIONS ---- //

  static Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'created_at DESC');
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

  // ---- SIMPLE IMPORT/EXPORT ---- //

  static Future<String> exportToJson() async {
    try {
      final users = await getUsers();
      final usersJson = users.map((user) => user.toMap()).toList();
      final jsonString = jsonEncode(usersJson);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/users_backup.json');
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  static Future<String> exportToJsonString() async {
    final users = await getUsers();
    final usersJson = users.map((user) => user.toMap()).toList();
    return jsonEncode(usersJson);
  }

  static Future<void> importFromJson(File jsonFile) async {
    try {
      final jsonString = await jsonFile.readAsString();
      final List<dynamic> usersJson = jsonDecode(jsonString);
      
      for (final userJson in usersJson) {
        final user = User.fromMap(userJson);
        await insertUser(user);
      }
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  static Future<void> importFromJsonString(String jsonString) async {
    try {
      final List<dynamic> usersJson = jsonDecode(jsonString);
      
      for (final userJson in usersJson) {
        final user = User.fromMap(userJson);
        await insertUser(user);
      }
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  // ---- IMAGE HANDLING ---- //

  static Future<String?> saveImageToFile(Uint8List imageBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/$fileName';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);
      return imagePath;
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> getImageFromPath(String? imagePath) async {
    if (imagePath == null) return null;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath == null) return;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors when deleting files
    }
  }
}