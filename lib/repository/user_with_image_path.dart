// ignore_for_file: unused_element

import 'dart:io';
import 'dart:typed_data';
import "package:sqflite/sqflite.dart";
import 'package:path_provider/path_provider.dart';
class UserWithImagePath {
  final int? id;
  final String name;
  final String email;
  final String? avatarPath; // Store file path instead of BLOB
  final DateTime createdAt;

  UserWithImagePath({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_path': avatarPath,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserWithImagePath.fromMap(Map<String, dynamic> map) {
    return UserWithImagePath(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      avatarPath: map['avatar_path'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}

class ImagePathDatabaseHelper {
  // ... similar setup as above

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        avatar_path TEXT,  -- Store path instead of BLOB
        created_at INTEGER
      )
    ''');
  }

  // Save image to file system and return path
 // Save image to file system and return path
static Future<String?> saveImageToFile(Uint8List imageBytes, String fileName) async {
  try {
    // Get Documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Create /avatar folder inside documents
    final avatarDir = Directory('${directory.path}/avatar');

    // Create folder if it does not exist
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }

    // Full path: /Documents/avatar/filename
    final imagePath = '${avatarDir.path}/$fileName';

    final file = File(imagePath);
    await file.writeAsBytes(imageBytes);

    return imagePath;
  } catch (e) {
    print('Error saving image to file: $e');
    return null;
  }
}

  // Get image from file path
  static Future<Uint8List?> getImageFromPath(String? imagePath) async {
    if (imagePath == null) return null;
    
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      print('Error reading image from path: $e');
    }
    return null;
  }
}