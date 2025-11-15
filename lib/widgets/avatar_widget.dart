// lib/widgets/avatar_widget.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarPath;
  final String name;
  final double size;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.avatarPath,
    required this.name,
    this.size = 50.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<Uint8List?>(
        future: DatabaseHelper.getImageFromPath(avatarPath),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return CircleAvatar(
              radius: size / 2,
              backgroundImage: MemoryImage(snapshot.data!),
            );
          } else {
            return CircleAvatar(
              radius: size / 2,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: size / 2.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}