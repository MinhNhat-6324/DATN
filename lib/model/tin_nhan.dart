import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front_end/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TinNhan {
  final int id;
  final int nguoiGui;
  final int nguoiNhan;
  final int? baiDangLienQuan;
  final String noiDung;
  final DateTime thoiGianGui;

  TinNhan({
    required this.id,
    required this.nguoiGui,
    required this.nguoiNhan,
    this.baiDangLienQuan,
    required this.noiDung,
    required this.thoiGianGui,
  });

  factory TinNhan.fromJson(Map<String, dynamic> json) {
    return TinNhan(
      id: json['id_tin_nhan'],
      nguoiGui: json['nguoi_gui'],
      nguoiNhan: json['nguoi_nhan'],
      baiDangLienQuan: json['bai_dang_lien_quan'],
      noiDung: json['noi_dung'],
      thoiGianGui: DateTime.parse(json['thoi_gian_gui']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tin_nhan': id,
      'nguoi_gui': nguoiGui,
      'nguoi_nhan': nguoiNhan,
      'bai_dang_lien_quan': baiDangLienQuan,
      'noi_dung': noiDung,
      'thoi_gian_gui': thoiGianGui.toIso8601String(),
    };
  }
}

class TinNhanService {
  Future<List<TinNhan>> getTinNhanGiuaHaiNguoi(int user1, int user2) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/tin-nhan/giua/$user1/$user2'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => TinNhan.fromJson(item)).toList();
    } else {
      throw Exception('Lấy tin nhắn thất bại');
    }
  }

  Future<bool> guiTinNhan({
    required int nguoiGui,
    required int nguoiNhan,
    int? baiDangLienQuan,
    required String noiDung,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      print("❌ Không tìm thấy access_token khi gửi tin nhắn");
      return false;
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/gui-tin-nhan'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nguoi_gui': nguoiGui,
        'nguoi_nhan': nguoiNhan,
        'bai_dang_lien_quan': baiDangLienQuan,
        'noi_dung': noiDung,
      }),
    );

    print('📤 Phản hồi gửi tin: ${response.statusCode} => ${response.body}');
    return response.statusCode == 201;
  }

  Future<bool> thuHoiTinNhan({
    required int idTinNhan,
    required int nguoiGui,
    required int nguoiNhan,
    int? baiDangLienQuan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      print("❌ Không tìm thấy access_token khi thu hồi tin nhắn");
      return false;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/tin-nhan/$idTinNhan');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'nguoi_gui': nguoiGui,
        'nguoi_nhan': nguoiNhan,
        'bai_dang_lien_quan': baiDangLienQuan,
        'noi_dung': 'đã thu hồi',
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('❌ Lỗi thu hồi tin nhắn: ${response.body}');
      return false;
    }
  }

  Future<TinNhan?> guiEmailVaLuuTinNhan({
    required int nguoiGui,
    required int nguoiNhan,
    int? baiDangLienQuan,
    required String noiDung,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      print("❌ Không tìm thấy access_token khi gửi email và lưu tin nhắn");
      return null;
    }

    final response = await http.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/gui-email-luu-tin-nhan'), // <-- endpoint Laravel bạn tạo
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nguoi_gui': nguoiGui,
        'nguoi_nhan': nguoiNhan,
        'bai_dang_lien_quan': baiDangLienQuan,
        'noi_dung': noiDung,
      }),
    );

    print(
        '📤 Phản hồi gửi email và lưu tin nhắn: ${response.statusCode} => ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return TinNhan.fromJson(jsonData['tin_nhan']);
    } else {
      return null;
    }
  }
}