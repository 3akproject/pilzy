import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'pages/medicines_page.dart';
import 'pages/schedules_page.dart';
import 'pages/history_page.dart';
import 'pages/documents_page.dart';
import 'pages/alerts_page.dart';
import 'pages/user_page.dart';
import 'services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  File? profileImage;
  int? userId;

  final List<Widget> _pages = const [
    MedicinesPage(),
    SchedulesPage(),
    HistoryPage(),
    DocumentsPage(),
    AlertsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final db = DatabaseHelper.instance;
    final users = await db.getAllUsers();
    final user = users.firstWhere((u) => u['username'] == widget.username);
    userId = user['id'] as int;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile_$userId.png');

    if (await file.exists()) {
      setState(() => profileImage = file);
    }
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openUserPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserPage()),
    );
    _loadProfileImage(); // refresh after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            backgroundImage:
                profileImage != null ? FileImage(profileImage!) : null,
            child: profileImage == null
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
          onPressed: _openUserPage,
        ),
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