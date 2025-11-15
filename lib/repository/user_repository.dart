import 'database_repository.dart';
import '../models/user.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserRepository {
  // Generate numeric UUID (64-bit int)
  int generateIntUuid() {
    final uuid = const Uuid().v4();
    final bytes = utf8.encode(uuid);
    final digest = sha1.convert(bytes).bytes;

    int result = 0;
    for (int i = 0; i < 8; i++) {
      result = (result << 8) | digest[i];
    }
    return result;
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    return await DatabaseHelper.getUsers();
  }

  // Add a new user
  Future<void> addUser(String name, String email) async {
    final user = User(
      id: generateIntUuid(),  
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    await DatabaseHelper.insertUser(user);
  }

  // Usage in Flutter widget
  Future<void> loadUsers() async {
    final users = await DatabaseHelper.getUsers();
    print('Loaded ${users.length} users');

    for (final user in users) {
      print('User: ${user.name}, Email: ${user.email}');
    }
  }
}
