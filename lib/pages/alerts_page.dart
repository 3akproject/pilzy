import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  TimeOfDay? selectedTime;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    final data = await DatabaseHelper.instance.getAlertTime();
    if (data != null) {
      selectedTime = TimeOfDay(
        hour: data['hour'],
        minute: data['minute'],
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      await DatabaseHelper.instance.saveAlertTime(
        picked.hour,
        picked.minute,
      );

      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleAlert() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select time first")),
      );
      return;
    }

    final now = DateTime.now();
    DateTime scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await NotificationService.instance.scheduleDailyGeneralAlert(
      id: 8000,
      dateTime: scheduled,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Daily Alert Scheduled")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active,
                size: 80, color: const Color(0xFF6B9676)),

            const SizedBox(height: 20),

            Text(
              selectedTime == null
                  ? "No Alert Time Selected"
                  : "Alert Time: ${selectedTime!.format(context)}",
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF415F49),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9676),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _pickTime,
              child: const Text("Select Alert Time"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _scheduleAlert,
              child: const Text("Schedule Daily Alert"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () =>
                  NotificationService.instance.instantTest(),
              child: const Text("Test Notification"),
            ),
          ],
        ),
      ),
    );
  }
}