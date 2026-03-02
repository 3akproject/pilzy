import 'package:flutter/material.dart';

import 'pages/medicines_page.dart';
import 'pages/schedules_page.dart';
import 'pages/history_page.dart';
import 'pages/documents_page.dart';
import 'pages/alerts_page.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 1; // 👈 Schedule default

  final List<Widget> _pages = const [
    MedicinesPage(),
    SchedulesPage(),
    HistoryPage(),
    DocumentsPage(),
    AlertsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hi, ${widget.username}"),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            label: "Medicines",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: "Schedules",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: "Documents",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: "Alerts",
          ),
        ],
      ),
    );
  }
}
