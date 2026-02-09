import 'package:flutter/material.dart';
import '../models/medicine.dart';
import 'package:intl/intl.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String frequency = "Once a Day";
  List<TimeOfDay> times = [];
  double doseAmount = 1;
  String doseUnit = "Tablet";
  double totalQuantity = 1;
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
                decoration: const InputDecoration(labelText: "Medicine Name"),
                onChanged: (val) => name = val,
                validator: (val) =>
                    val!.isEmpty ? "Please enter medicine name" : null,
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
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Dose Amount"),
                      onChanged: (val) =>
                          doseAmount = double.tryParse(val) ?? 1,
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
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Total Quantity"),
                onChanged: (val) => totalQuantity = double.tryParse(val) ?? 1,
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final med = Medicine(
                      name: name,
                      frequency: frequency,
                      times: times
                          .map((t) =>
                              "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}")
                          .toList(),
                      doseAmount: doseAmount,
                      doseUnit: doseUnit,
                      totalQuantity: totalQuantity,
                      alarmTone: alarmTone,
                    );
                    Navigator.pop(context, med);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
