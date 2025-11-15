// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/user_list_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // no SQLite on web
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {

    // --- DESKTOP ---
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

  } else {
    // --- MOBILE (Android / iOS) ---
    // sqflite initializes automatically; no setup needed
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const UserListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}