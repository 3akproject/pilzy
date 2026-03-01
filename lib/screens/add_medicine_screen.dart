import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pilzy/models/medicine.dart';
import 'package:pilzy/services/database_helper.dart';
import 'package:pilzy/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  const AddMedicineScreen({super.key, this.medicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController doseController;
  late TextEditingController quantityController;

  String frequency = "Once a Day";
  String doseUnit = "Tablet";
  String alarmTone = "Default";
  List<TimeOfDay> times = [];

  final frequencyOptions = [
    "Once a Day",
    "Twice a Day",
    "Three Times a Day",
  ];

  final unitOptions = [
    "Tablet", "Capsule", "ml", "mg", "g", "Spoon", "Drops", "Puff", "Other"
  ];

  final alarmTones = ["Default", "Tone 1", "Tone 2", "Tone 3"];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    doseController = TextEditingController();
    quantityController = TextEditingController();

    if (widget.medicine != null) {
      final med = widget.medicine!;
      nameController.text = med.name;
      doseController.text = med.doseAmount.toString();
      quantityController.text = med.totalQuantity.toString();
      frequency = med.frequency;
      doseUnit = med.doseUnit;
      alarmTone = med.alarmTone;

      times = med.times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    doseController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  int getTimePickersCount() {
    switch (frequency) {
      case "Once a Day":
        return 1;
      case "Twice a Day":
        return 2;
      case "Three Times a Day":
        return 3;
      default:
        return 1;
    }
  }

  Future<void> pickTime(int index) async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      setState(() {
        if (times.length > index) {
          times[index] = picked;
        } else {
          times.add(picked);
        }
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    if (times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one time")),
      );
      return;
    }

    final med = Medicine(
      id: widget.medicine?.id,
      name: nameController.text.trim(),
      frequency: frequency,
      times: times
          .map((t) =>
              "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}")
          .toList(),
      doseAmount: double.tryParse(doseController.text) ?? 1,
      doseUnit: doseUnit,
      totalQuantity: double.tryParse(quantityController.text) ?? 1,
      alarmTone: alarmTone,
    );

    int medicineId;

    if (widget.medicine == null) {
      medicineId = await DatabaseHelper.instance.insertMedicine(med);
    } else {
      medicineId = widget.medicine!.id!;
      await DatabaseHelper.instance.updateMedicine(med);

      // Cancel old notifications when editing
      for (int i = 0; i < 5; i++) {
        await NotificationService.instance.cancelNotification(
            medicineId * 10 + i);
      }
    }

    // Schedule daily notifications
    for (int i = 0; i < times.length; i++) {
      final t = times[i];

      final now = DateTime.now();
      DateTime scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        t.hour,
        t.minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final tzScheduled =
          tz.TZDateTime.from(scheduled, tz.local);

      await NotificationService.instance.scheduleDailyReminder(
        id: medicineId * 10 + i,
        dateTime: tzScheduled,
        medicineName: med.name,
        doseAmount: med.doseAmount.toString(),
        doseUnit: med.doseUnit,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Medicine Saved Successfully")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medicine"),
        backgroundColor: const Color(0xFF6B9676),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: "Medicine Name"),
                validator: (val) =>
                    val == null || val.isEmpty
                        ? "Enter medicine name"
                        : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration:
                    const InputDecoration(labelText: "Frequency"),
                items: frequencyOptions
                    .map((f) =>
                        DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    frequency = val!;
                    times = [];
                  });
                },
              ),
              const SizedBox(height: 16),
              ...List.generate(getTimePickersCount(), (i) {
                final time = times.length > i ? times[i] : null;
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      time == null
                          ? "Pick Time"
                          : DateFormat.jm().format(
                              DateTime(0, 0, 0,
                                  time.hour, time.minute),
                            ),
                    ),
                    trailing:
                        const Icon(Icons.access_time),
                    tileColor:
                        const Color(0xFFC7E7CF),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8)),
                    onTap: () => pickTime(i),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: doseController,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                              labelText:
                                  "Dose Amount"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child:
                        DropdownButtonFormField<String>(
                      value: doseUnit,
                      decoration:
                          const InputDecoration(
                              labelText: "Unit"),
                      items: unitOptions
                          .map((u) =>
                              DropdownMenuItem(
                                  value: u,
                                  child: Text(u)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() =>
                              doseUnit = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                keyboardType:
                    TextInputType.number,
                decoration: const InputDecoration(
                    labelText:
                        "Total Quantity"),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF6B9676),
                  minimumSize:
                      const Size(double.infinity, 50),
                ),
                onPressed: _saveMedicine,
                child: const Text(
                    "Save Medicine"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}