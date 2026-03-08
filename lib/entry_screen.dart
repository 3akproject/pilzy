import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'services/session_manager.dart';
import 'home_screen.dart';
import 'new_user_screen.dart';
import 'user_select_screen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  @override
  void initState() {
    super.initState();
    _decideFlow();
  }

  Future<void> _decideFlow() async {
    final savedUserId = await SessionManager.getUserId();
    final savedUsername = await SessionManager.getUsername();

    if (!mounted) return;

    // ✅ If session exists → go directly to Home
    if (savedUserId != null && savedUsername != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(username: savedUsername),
        ),
      );
      return;
    }

    // 🧠 Otherwise normal flow
    final users = await DatabaseHelper.instance.getAllUsers();

    if (!mounted) return;

    if (users.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NewUserScreen()),
      );
    } else if (users.length == 1) {
      final user = users.first;
      final userId = user['id'] as int;
      final username = user['username'] as String;

      await SessionManager.saveUserSession(userId, username);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(username: username),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserSelectScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}