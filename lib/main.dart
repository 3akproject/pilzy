import 'package:flutter/material.dart';
import 'package:pilzy/entry_screen.dart';
import 'services/notification_service.dart';
import 'screens/alarm_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MedicineReminderApp());
}

class MedicineReminderApp extends StatelessWidget {
  const MedicineReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pilzy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6B9676),
      ),
      navigatorKey: NotificationService.instance.navigatorKey,
      home: const EntryScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/alarm') {
          final data = settings.arguments as String?;

          if (data == null || !data.contains('|')) {
            return null; // ignore invalid payload
          }

          final parts = data.split('|');

          if (parts.length < 5) {
            return null; // prevent RangeError
          }

          return MaterialPageRoute(
            builder: (_) => AlarmScreen(
              notificationId: int.parse(parts[0]),
              medicineName: parts[1],
              doseAmount: parts[2],
              doseUnit: parts[3],
              time: parts[4],
            ),
          );
        }
        return null;
      },
    );
  }
}