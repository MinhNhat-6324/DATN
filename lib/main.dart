import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:front_end/Screen/baoCaoScreen.dart';
import 'package:front_end/Screen/chiTietSanPhamScreen.dart';
import 'package:front_end/Screen/chinhSuaBaiVietScreen.dart';
import 'package:front_end/Screen/home_screen.dart';
import 'package:front_end/Screen/post_screen.dart';
import 'package:front_end/Screen/profile_screen.dart';
import 'package:front_end/Screen/baiDangCuaToiScreen.dart';
import 'package:front_end/Screen/register_screen.dart';
import 'package:front_end/Screen/sanPhamLienQuanScreen.dart';
import 'package:front_end/Screen/start_screen.dart';
=======
import 'package:front_end/Screen/home_screen.dart';
>>>>>>> ba7c42e84c62f75a57cd315dcf76c53f22a58b4c

void main() {
  runApp(const SachChuyenTayApp());
}

class SachChuyenTayApp extends StatelessWidget {
  const SachChuyenTayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      home: ReportFormScreen(),
=======
      home: HomeScreen(),
>>>>>>> ba7c42e84c62f75a57cd315dcf76c53f22a58b4c
    );
  }
}
