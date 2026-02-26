import 'package:flutter/material.dart';
import 'package:pilzy/services/database_helper.dart';
import '../models/medicine.dart';
import 'package:intl/intl.dart';
import 'package:pilzy/services/notification_service.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;

  const AddMedicineScreen({super.key, this.medicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

late TextEditingController nameController;
late TextEditingController doseController;
late TextEditingController quantityController;

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  String frequency = "Once a Day";
  List<TimeOfDay> times = [];
  String doseUnit = "Tablet";
  String alarmTone = "Default";

  List<String> frequencyOptions = [
    "Once a Day",
    "Twice a Day",
    "Three Times a Day",
    "Custom Interval"
  ];

  List<String> unitOptions = [
    "Tablet",
    "Capsule",
    "ml",
    "mg",
    "g",
    "Spoon",
    "Drops",
    "Puff",
    "Other"
  ];

  List<String> alarmTones = [
    "Default",
    "Tone 1",
    "Tone 2",
    "Tone 3",
  ];

  // Show Time Picker
  Future<void> pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medicine"),
        backgroundColor: const Color(0xFF6B9676),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Medicine Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Please enter medicine name" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Frequency"),
                initialValue: frequency,
                items: frequencyOptions
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    frequency = val!;
                    times = [];
                  });
                },
              ),
              const SizedBox(height: 16),
              // Dynamic time pickers
              ...List.generate(getTimePickersCount(), (index) {
                final time = times.length > index ? times[index] : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(time == null
                        ? "Pick Time"
                        : DateFormat.jm().format(DateTime(
                            0, 0, 0, time.hour, time.minute))),
                    trailing: const Icon(Icons.access_time),
                    tileColor: const Color(0xFFC7E7CF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    onTap: () => pickTime(index),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: doseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Dose Amount"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Unit"),
                      initialValue: doseUnit,
                      items: unitOptions
                          .map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => doseUnit = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Total Quantity"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Alarm Tone"),
                initialValue: alarmTone,
                items: alarmTones
                    .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => alarmTone = val!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9676),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Save Medicine"),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

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

                    if (widget.medicine == null) {
                      await DatabaseHelper.instance.insertMedicine(med);
                    } else {
                      await DatabaseHelper.instance.updateMedicine(med);
                    }

                    Navigator.pop(context, true);
                  }
                  for (var time in times) {
                    final now = DateTime.now();
                    final scheduled = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      time.hour,
                      time.minute,
                    );

                    await NotificationService.instance.scheduleMedicineReminder(
                      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                      title: "Medicine Reminder",
                      body:
                          "${nameController.text} - ${doseController.text} $doseUnit",
                      scheduledTime: scheduled,
                    );
                  }
                },
              ),

              // 👇 SHOW DELETE BUTTON ONLY WHEN EDITING
              if (widget.medicine != null)
                TextButton(
                  onPressed: () async {
                    await DatabaseHelper.instance
                        .deleteMedicine(widget.medicine!.id!);
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    "Remove this medicine reminder",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    doseController = TextEditingController();
    quantityController = TextEditingController();

    if (widget.medicine != null) {
      nameController.text = widget.medicine!.name;
      frequency = widget.medicine!.frequency;

      times = widget.medicine!.times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();

      doseController.text = widget.medicine!.doseAmount.toString();
      doseUnit = widget.medicine!.doseUnit;
      quantityController.text =
          widget.medicine!.totalQuantity.toString();
      alarmTone = widget.medicine!.alarmTone;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    doseController.dispose();
    quantityController.dispose();
    super.dispose();
  }
}
