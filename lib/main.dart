import 'package:flutter/material.dart';
import 'Screen/start_screen.dart';
import 'Screen/admin.dart';
import 'Screen/login_screen.dart';
import 'Screen/register_screen.dart';

void main() {
  runApp(const SachChuyenTayApp());
}

class SachChuyenTayApp extends StatelessWidget {
  const SachChuyenTayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
