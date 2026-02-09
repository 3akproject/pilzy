import 'package:flutter/material.dart';
import '/screens/add_medicine_screen.dart';
import "/models/medicine.dart";

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({super.key});

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  List<Medicine> medicines = []; // 👈 store medicines here

  // This function will be called when a new medicine is added
  void _addMedicine(Medicine medicine) {
    setState(() {
      medicines.add(medicine);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: medicines.isEmpty
          ? Center(
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
                  leading: Icon(Icons.medication, color: Color(0xFF6B9676)),
                  title: Text(med.name),
                  subtitle: Text("${med.doseAmount} ${med.doseUnit} • ${med.frequency}"),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF6B9676),
        onPressed: () async {
          // Navigate to AddMedicineScreen and get new medicine
          final newMedicine = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicineScreen(),
            ),
          );
          if (newMedicine != null) {
            _addMedicine(newMedicine);
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}