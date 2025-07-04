import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front_end/services/api_config.dart';

class DoiTuongChat {
  final int idTaiKhoan;
  final String hoTen;
  final String? anhDaiDien;
  final String? tinNhanCuoi;
  final DateTime? thoiGian;

  DoiTuongChat({
    required this.idTaiKhoan,
    required this.hoTen,
    this.anhDaiDien,
    this.tinNhanCuoi,
    this.thoiGian,
  });

  factory DoiTuongChat.fromJson(Map<String, dynamic> json) {
    return DoiTuongChat(
      idTaiKhoan: json['id_tai_khoan'],
      hoTen: json['ho_ten'] ?? '',
      anhDaiDien: json['anh_dai_dien'],
      tinNhanCuoi: json['tin_nhan_cuoi'],
      thoiGian: json['thoi_gian'] != null
          ? DateTime.tryParse(json['thoi_gian'])
          : null,
    );
  }
}

class DoiTuongChatService {
  Future<List<DoiTuongChat>> fetchDoiTuongChat(int userId) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/tin-nhan/danh-sach-doi-tuong/$userId');

    final response = await http.get(url, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => DoiTuongChat.fromJson(json)).toList();
    } else {
      throw Exception('Không thể tải danh sách đối tượng chat');
    }
  }
}
