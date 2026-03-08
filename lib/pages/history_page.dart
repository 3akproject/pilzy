import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/medicine_history.dart';
import '../models/medicine.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<MedicineHistory> _historyList = [];
  List<MedicineHistory> _filteredList = [];
  List<Medicine> _medicines = [];

  String _selectedMedicine = "All";
  String _selectedRange = "All";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await DatabaseHelper.instance.getAllMedicineHistory();
    final meds = await DatabaseHelper.instance.getAllMedicines();

    setState(() {
      _historyList = history;
      _filteredList = history;
      _medicines = meds;
    });
  }

  void _applyFilters() {
    List<MedicineHistory> temp = List.from(_historyList);

    // Filter by medicine
    if (_selectedMedicine != "All") {
      final med = _medicines.firstWhere(
        (m) => m.name == _selectedMedicine,
      );
      temp = temp.where((h) => h.medicineId == med.id).toList();
    }

    // Filter by date range
    DateTime now = DateTime.now();
    DateTime? cutoff;

    if (_selectedRange == "1 Week") {
      cutoff = now.subtract(const Duration(days: 7));
    } else if (_selectedRange == "1 Month") {
      cutoff = DateTime(now.year, now.month - 1, now.day);
    } else if (_selectedRange == "3 Months") {
      cutoff = DateTime(now.year, now.month - 3, now.day);
    }

    if (cutoff != null) {
      temp = temp.where((h) => h.takenTime.isAfter(cutoff!)).toList();
    }

    temp.sort((a, b) => b.takenTime.compareTo(a.takenTime));

    setState(() {
      _filteredList = temp;
    });
  }

  String _getMedicineName(int id) {
    try {
      return _medicines.firstWhere((m) => m.id == id).name;
    } catch (_) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicine History")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Medicine Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMedicine,
                    items: [
                      const DropdownMenuItem(
                        value: "All",
                        child: Text("All Medicines"),
                      ),
                      ..._medicines.map((m) => DropdownMenuItem(
                            value: m.name,
                            child: Text(m.name),
                          )),
                    ],
                    onChanged: (value) {
                      _selectedMedicine = value!;
                      _applyFilters();
                    },
                    decoration: const InputDecoration(
                      labelText: "Medicine",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Range Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRange,
                    items: const [
                      DropdownMenuItem(value: "All", child: Text("All Time")),
                      DropdownMenuItem(value: "1 Week", child: Text("1 Week")),
                      DropdownMenuItem(value: "1 Month", child: Text("1 Month")),
                      DropdownMenuItem(value: "3 Months", child: Text("3 Months")),
                    ],
                    onChanged: (value) {
                      _selectedRange = value!;
                      _applyFilters();
                    },
                    decoration: const InputDecoration(
                      labelText: "Time Range",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _filteredList.isEmpty
                ? const Center(child: Text("No history found"))
                : ListView.builder(
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final item = _filteredList[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(_getMedicineName(item.medicineId)),
                        subtitle: Text(
                          "${item.doseAmount} ${item.doseUnit}",
                        ),
                        trailing: Text(
                          "${item.takenTime.day}/${item.takenTime.month}/${item.takenTime.year}\n"
                          "${item.takenTime.hour.toString().padLeft(2, '0')}:"
                          "${item.takenTime.minute.toString().padLeft(2, '0')}",
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}