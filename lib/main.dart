import 'package:flutter/material.dart';
import 'package:front_end/Screen/home_screen.dart';
import 'Screen/admin.dart';
void main() {
  runApp(const SachChuyenTayApp());
}

class SachChuyenTayApp extends StatelessWidget {
  const SachChuyenTayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminScreen()
    );
  }
}
