// lib/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import "package:usermanager/services/user_services.dart";
import '../services/database_helper.dart';
import '../widgets/avatar_widget.dart';
import 'add_edit_user_screen.dart';
import 'package:usermanager/models/user.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await UserService.getUsers();
      setState(() => _users = users);
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteUser(User user) async {
    try {
      await UserService.deleteUser(user.id);
      _showMessage('User deleted');
      _loadUsers();
    } catch (e) {
      _showMessage('Delete failed: $e');
    }
  }

  void _addUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditUserScreen()),
    );
    if (result == true) _loadUsers();
  }

  void _editUser(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditUserScreen(user: user)),
    );
    if (result == true) _loadUsers();
  }

  void _exportData() async {
    try {
      final path = await DatabaseHelper.exportToJson();
      _showMessage('Exported to: $path');
    } catch (e) {
      _showMessage('Export failed: $e');
    }
  }

  void _importSample() async {
    const sampleData = '''
    [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "avatar_path": null,
        "created_at": 1700000000000
      }
    ]
    ''';
    
    try {
      await DatabaseHelper.importFromJsonString(sampleData);
      _showMessage('Sample data imported');
      _loadUsers();
    } catch (e) {
      _showMessage('Import failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportData,
            tooltip: 'Export',
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _importSample,
            tooltip: 'Import Sample',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No users yet'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: AvatarWidget(
                        avatarPath: user.avatarPath,
                        name: user.name,
                        size: 40,
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteUser(user),
                      ),
                      onTap: () => _editUser(user),
                    );
                  },
                ),
    );
  }
}