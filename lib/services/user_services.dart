// lib/services/user_service.dart
import 'dart:typed_data';
import '../models/user.dart';
import 'database_helper.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserService {
  
  
  /// Create a new user
  static Future<User> createUser({
    required String name,
    required String email,
    Uint8List? avatarBytes,
  }) async {
    try {
      // Basic validation
      if (name.isEmpty) throw Exception('Name is required');
      if (email.isEmpty) throw Exception('Email is required');

      String? avatarPath;
      
      // Save avatar if provided
      if (avatarBytes != null) {
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        avatarPath = await DatabaseHelper.saveImageToFile(avatarBytes, fileName);
      }

      // Generate numeric UUID (64-bit int)
 int generateIntUuid() {
  // Generate UUID and remove all dashes
  final raw = const Uuid().v4().replaceAll('-', '');

  // Convert to bytes
  final bytes = utf8.encode(raw);
  final digest = sha1.convert(bytes).bytes;

  // Convert first 8 bytes to a 64-bit integer
  int result = 0;
  for (int i = 0; i < 8; i++) {
    result = (result << 8) | digest[i];
  }

  return result;
}

      final user = User(
        id: generateIntUuid(),
        name: name,
        email: email,
        avatarPath: avatarPath,
        createdAt: DateTime.now(),
      );

      final userId = await DatabaseHelper.insertUser(user);
      return user.copyWith(id: userId);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Get all users
  static Future<List<User>> getUsers() async {
    try {
      return await DatabaseHelper.getUsers();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Get user by ID
  static Future<User?> getUser(int id) async {
    try {
      // Note: You'll need to add getUserById to DatabaseHelper
      // For now, we'll filter from all users
      final users = await DatabaseHelper.getUsers();
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Update user
  static Future<User> updateUser({
    required User user,
    String? name,
    String? email,
    Uint8List? avatarBytes,
  }) async {
    try {
      String? newAvatarPath = user.avatarPath;
      
      // Handle new avatar
      if (avatarBytes != null) {
        // Delete old avatar
        if (user.avatarPath != null) {
          await DatabaseHelper.deleteImageFile(user.avatarPath);
        }
        
        // Save new avatar
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        newAvatarPath = await DatabaseHelper.saveImageToFile(avatarBytes, fileName);
      }

      final updatedUser = user.copyWith(
        name: name ?? user.name,
        email: email ?? user.email,
        avatarPath: newAvatarPath,
      );

      await DatabaseHelper.updateUser(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete user
  static Future<void> deleteUser(int id) async {
    try {
      // Get user first to delete avatar
      final users = await DatabaseHelper.getUsers();
      final user = users.firstWhere((user) => user.id == id);
      
      // Delete avatar file
      if (user.avatarPath != null) {
        await DatabaseHelper.deleteImageFile(user.avatarPath);
      }
      
      // Delete user from database
      await DatabaseHelper.deleteUser(id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Search users by name or email
  static Future<List<User>> searchUsers(String query) async {
    try {
      final users = await DatabaseHelper.getUsers();
      final lowercaseQuery = query.toLowerCase();
      
      return users.where((user) {
        return user.name.toLowerCase().contains(lowercaseQuery) ||
               user.email.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get user count
  static Future<int> getUserCount() async {
    try {
      final users = await DatabaseHelper.getUsers();
      return users.length;
    } catch (e) {
      throw Exception('Failed to get user count: $e');
    }
  }

  /// Check if email exists
  static Future<bool> emailExists(String email) async {
    try {
      final users = await DatabaseHelper.getUsers();
      return users.any((user) => user.email == email);
    } catch (e) {
      throw Exception('Failed to check email: $e');
    }
  }

  /// Update only user's avatar
  static Future<User> updateUserAvatar(int userId, Uint8List avatarBytes) async {
    try {
      final users = await DatabaseHelper.getUsers();
      final user = users.firstWhere((user) => user.id == userId);
      return await updateUser(user: user, avatarBytes: avatarBytes);
    } catch (e) {
      throw Exception('Failed to update avatar: $e');
    }
  }

  /// Remove user's avatar
  static Future<User> removeUserAvatar(int userId) async {
    try {
      final users = await DatabaseHelper.getUsers();
      final user = users.firstWhere((user) => user.id == userId);
      
      // Delete avatar file
      if (user.avatarPath != null) {
        await DatabaseHelper.deleteImageFile(user.avatarPath);
      }
      
      final updatedUser = user.copyWith(avatarPath: null);
      await DatabaseHelper.updateUser(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Failed to remove avatar: $e');
    }
  }
}