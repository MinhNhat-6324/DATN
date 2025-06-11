import 'package:flutter/material.dart';
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
import 'package:front_end/Screen/image_picker_screen.dart';

void main() {
  runApp(const SachChuyenTayApp());
}

class SachChuyenTayApp extends StatelessWidget {
  const SachChuyenTayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReportFormScreen(),
    );
  }
}
