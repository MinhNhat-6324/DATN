import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front_end/services/api_config.dart';

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
  //final String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<TinNhan>> getTinNhanGiuaHaiNguoi(int user1, int user2) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/tin-nhan/giua/$user1/$user2'));

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
    final url = Uri.parse('${ApiConfig.baseUrl}/gui-tin-nhan');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'nguoi_gui': nguoiGui,
        'nguoi_nhan': nguoiNhan,
        'bai_dang_lien_quan': baiDangLienQuan,
        'noi_dung': noiDung,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Lỗi gửi tin nhắn: ${response.body}');
      return false;
    }
  }

  Future<bool> thuHoiTinNhan({
    required int idTinNhan,
    required int nguoiGui,
    required int nguoiNhan,
    int? baiDangLienQuan,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/tin-nhan/$idTinNhan');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'nguoi_gui': nguoiGui,
        'nguoi_nhan': nguoiNhan,
        'bai_dang_lien_quan': baiDangLienQuan,
        'noi_dung': 'đã thu hồi', // thu hồi = rỗng
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Lỗi thu hồi tin nhắn: ${response.body}');
      return false;
    }
  }
}
