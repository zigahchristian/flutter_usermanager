// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? avatarPath;
  final DateTime createdAt;

  User({
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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      avatarPath: map['avatar_path'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarPath,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}