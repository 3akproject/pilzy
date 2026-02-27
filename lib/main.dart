import 'package:flutter/material.dart';
import 'package:pilzy/entry_screen.dart';
import 'services/notification_service.dart';
import 'screens/alarm_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      home: const EntryScreen(),
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == '/alarm') {
          final data = settings.arguments as String;
          final parts = data.split('|');
          return MaterialPageRoute(
            builder: (_) => AlarmScreen(
              medicineName: parts[0],
              doseAmount: parts[1],
              doseUnit: parts[2],
              time: parts[3],
            ),
          );
        }
        return null;
      },
    );
  }
}