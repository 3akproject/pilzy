import 'package:flutter/material.dart';
import 'pin_verify_screen.dart';
import 'services/database_helper.dart';
import 'new_user_screen.dart';

class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  Future<List<String>> _loadUsers() async {
    final users = await DatabaseHelper.instance.getAllUsers();
    return users.map((u) => u['username'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Switch User')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _loadUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(users[index]),
                      trailing: const Icon(Icons.lock_outline),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PinVerifyScreen(username: users[index]),
                          ),
                        );
                      },
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