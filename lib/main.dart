import 'package:flutter/material.dart';
import 'package:front_end/Screen/home_screen.dart';
import 'package:front_end/Screen/post_list_screen.dart';
import 'package:front_end/Screen/post_management_screen.dart';
import 'package:front_end/Screen/post_screen.dart';
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
