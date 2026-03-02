import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../models/medicine_history.dart';
import '../services/database_helper.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  List<_ScheduleItem> _scheduleList = [];
  Map<String, bool> _takenMap = {};

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final medicines = await DatabaseHelper.instance.getAllMedicines();
    final todayHistory =
        await DatabaseHelper.instance.getTodayMedicineHistory();

    List<_ScheduleItem> tempList = [];
    Map<String, bool> tempTakenMap = {};

    for (var med in medicines) {
      for (var timeString in med.times) {
        final scheduleTime = _parseTimeToday(timeString);

        bool alreadyTaken = todayHistory.any((history) {
          return history.medicineId == med.id &&
              history.takenTime.hour == scheduleTime.hour &&
              history.takenTime.minute == scheduleTime.minute;
        });

        final key = "${med.id}_$timeString";

        tempTakenMap[key] = alreadyTaken;

        tempList.add(
          _ScheduleItem(
            medicine: med,
            time: scheduleTime,
            timeString: timeString,
          ),
        );
      }
    }

    tempList.sort((a, b) => a.time.compareTo(b.time));

    setState(() {
      _scheduleList = tempList;
      _takenMap = tempTakenMap;
    });
  }

  DateTime _parseTimeToday(String timeString) {
    final parts = timeString.split(":");

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Future<void> _toggleTaken(_ScheduleItem item) async {
    final key = "${item.medicine.id}_${item.timeString}";
    final isTaken = _takenMap[key] ?? false;

    if (isTaken) return; // prevent double insert

    // Insert history
    final history = MedicineHistory(
      medicineId: item.medicine.id!,
      takenTime: DateTime.now(),
      doseAmount: item.medicine.doseAmount,
      doseUnit: item.medicine.doseUnit,
    );

    await DatabaseHelper.instance.insertMedicineHistory(history);

    // Reduce quantity
    final updatedMedicine = Medicine(
      id: item.medicine.id,
      name: item.medicine.name,
      frequency: item.medicine.frequency,
      times: item.medicine.times,
      doseAmount: item.medicine.doseAmount,
      doseUnit: item.medicine.doseUnit,
      totalQuantity:
          item.medicine.totalQuantity - item.medicine.doseAmount,
      alarmTone: item.medicine.alarmTone,
    );

    await DatabaseHelper.instance.updateMedicine(updatedMedicine);

    await _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Medicines"),
      ),
      body: _scheduleList.isEmpty
          ? const Center(
              child: Text("No medicines scheduled for today"),
            )
          : ListView.builder(
              itemCount: _scheduleList.length,
              itemBuilder: (context, index) {
                final item = _scheduleList[index];
                final key = "${item.medicine.id}_${item.timeString}";
                final isTaken = _takenMap[key] ?? false;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Checkbox(
                      value: isTaken,
                      onChanged: (_) => _toggleTaken(item),
                    ),
                    title: Text(item.medicine.name),
                    subtitle: Text(
                        "${item.medicine.doseAmount} ${item.medicine.doseUnit} • ${item.timeString}"),
                    trailing: Text(
                        "Left: ${item.medicine.totalQuantity.toStringAsFixed(1)}"),
                  ),
                );
              },
            ),
    );
  }
}

class _ScheduleItem {
  final Medicine medicine;
  final DateTime time;
  final String timeString;

  _ScheduleItem({
    required this.medicine,
    required this.time,
    required this.timeString,
  });
}