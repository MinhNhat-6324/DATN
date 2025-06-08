import 'package:flutter/material.dart';
import 'start_screen.dart';

void main() {
  runApp(const SachChuyenTayApp());
}

class SachChuyenTayApp extends StatelessWidget {
  const SachChuyenTayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sách Chuyển Tay',
      debugShowCheckedModeBanner: false,
      home: const StartScreen(),
    );
  }
}
