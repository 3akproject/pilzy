import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'widgets/pin_input.dart';

class PinVerifyScreen extends StatefulWidget {
  final String username;
  const PinVerifyScreen({super.key, required this.username});

  @override
  State<PinVerifyScreen> createState() => _PinVerifyScreenState();
}

class _PinVerifyScreenState extends State<PinVerifyScreen> {
  final pinController = TextEditingController();
  String error = '';

  Future<void> _verify() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('pin_${widget.username}');

    if (pinController.text == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(username: widget.username),
        ),
      );
    } else {
      setState(() => error = 'Wrong PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.username)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PinInput(
              controller: pinController,
              hint: 'Enter PIN',
            ),
            const SizedBox(height: 12),
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verify,
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
