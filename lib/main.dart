import 'package:flutter/material.dart';
import 'package:pilzy/entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedicineReminderApp());
}

class MedicineReminderApp extends StatelessWidget {
  const MedicineReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const EntryScreen(),
    );
  }
}
