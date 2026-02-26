import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmScreen extends StatefulWidget {
  final String medicineName;
  final String dose;
  final String unit;

  const AlarmScreen({
    super.key,
    required this.medicineName,
    required this.dose,
    required this.unit,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    playAlarm();
  }

  Future<void> playAlarm() async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource('alarm.mp3'));
  }

  Future<void> stopAlarm() async {
    await player.stop();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();

    return Scaffold(
      backgroundColor: Colors.red.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                now.format(context),
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                widget.medicineName,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "${widget.dose} ${widget.unit}",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(200, 60),
                ),
                onPressed: stopAlarm,
                child: const Text(
                  "STOP",
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}