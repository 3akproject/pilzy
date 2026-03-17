import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/medicine.dart';
import '../screens/add_medicine_screen.dart';

class MedicinesPage extends StatefulWidget {
  final int? userId;

  const MedicinesPage({super.key, this.userId});

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
    final data = await DatabaseHelper.instance.getAllMedicines(userId: widget.userId);
    setState(() {
      medicines = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: medicines.isEmpty
          ? const Center(
              child: Text(
                "No medicines added yet",
                style: TextStyle(fontSize: 18, color: Color(0xFF415F49)),
              ),
            )
          : ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                return ListTile(
                  leading: const Icon(Icons.medication, color: Color(0xFF6B9676)),
                  title: Text(med.name),
                  subtitle: Text("${med.doseAmount} ${med.doseUnit} • ${med.frequency}"),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddMedicineScreen(medicine: med, userId: widget.userId)),
                    );
                    if (result != null) _loadMedicines();
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6B9676),
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => AddMedicineScreen(userId: widget.userId)));
          if (result == true) _loadMedicines();
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}