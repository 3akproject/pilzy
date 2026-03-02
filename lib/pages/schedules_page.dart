import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class SchedulesPage extends StatelessWidget {
  const SchedulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedules"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Test Notification Counters",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ValueListenableBuilder<int>(
              valueListenable: NotificationService.counterA,
              builder: (context, value, _) {
                return Text(
                  "Counter A: $value",
                  style: const TextStyle(fontSize: 20),
                );
              },
            ),

            const SizedBox(height: 10),

            ValueListenableBuilder<int>(
              valueListenable: NotificationService.counterB,
              builder: (context, value, _) {
                return Text(
                  "Counter B: $value",
                  style: const TextStyle(fontSize: 20),
                );
              },
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                NotificationService.instance
                    .showCounterTestNotification();
              },
              child: const Text("Trigger Test Notification"),
            ),
          ],
        ),
      ),
    );
  }
}