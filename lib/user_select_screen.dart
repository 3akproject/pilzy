import 'package:flutter/material.dart';
import 'package:pilzy/pin_verify_screen.dart';
import 'services/database_helper.dart';

class UserSelectScreen extends StatelessWidget {
  const UserSelectScreen({super.key});

  Future<List<String>> _loadUsers() async {
    final users = await DatabaseHelper.instance.getAllUsers();
    return users.map((u) => u['username'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select User')),
      body: FutureBuilder<List<String>>(
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
                title: Text(users[index]),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PinVerifyScreen(username: users[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
