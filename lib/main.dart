import 'package:flutter/material.dart';
import 'package:runningmusic/widget/step_to_beat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Music for Running',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const StepToBeat());
  }
}
