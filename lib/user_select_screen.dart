import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'pin_verify_screen.dart';
import 'services/database_helper.dart';
import 'new_user_screen.dart';

class UserSelectScreen extends StatefulWidget {
  const UserSelectScreen({super.key});

  @override
  State<UserSelectScreen> createState() => _UserSelectScreenState();
}

class _UserSelectScreenState extends State<UserSelectScreen> {
  List<Map<String, dynamic>> users = [];
  Map<int, File?> images = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    users = await DatabaseHelper.instance.getAllUsers();
    await _loadImages();
    if (mounted) setState(() {});
  }

  Future<void> _loadImages() async {
    final dir = await getApplicationDocumentsDirectory();

    for (var u in users) {
      final id = u['id'] as int;
      final file = File('${dir.path}/profile_$id.png');
      images[id] = await file.exists() ? file : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Switch User')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final id = user['id'] as int;
                final username = user['username'] as String;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        images[id] != null ? FileImage(images[id]!) : null,
                    child: images[id] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(username),
                  trailing: const Icon(Icons.lock_outline),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PinVerifyScreen(username: username),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Create New User"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NewUserScreen()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}