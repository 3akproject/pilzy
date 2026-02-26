import 'package:flutter/material.dart';
import '/screens/add_medicine_screen.dart';
import "/models/medicine.dart";
import '../services/database_helper.dart';

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({super.key});

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  List<Medicine> medicines = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    final data = await DatabaseHelper.instance.getAllMedicines();
    setState(() {
      medicines = data;
    });
  }

  Future<void> _addMedicine(Medicine medicine) async {
    await DatabaseHelper.instance.insertMedicine(medicine);
    _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: medicines.isEmpty
          ? const Center(
              child: Text(
                "No medicines added yet",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF415F49),
                ),
              ),
            )
          : ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                return ListTile(
                  leading: const Icon(Icons.medication, color: Color(0xFF6B9676)),
                  title: Text(med.name),
                  subtitle: Text(
                      "${med.doseAmount} ${med.doseUnit} • ${med.frequency}"),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6B9676),
        onPressed: () async {
          final newMedicine = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicineScreen(),
            ),
          );

          if (newMedicine != null) {
            await _addMedicine(newMedicine);
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}