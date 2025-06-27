import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
class ThongBaoService {
  final baseUrl = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.thongBaoTaiKhoanEndpoint}');
  /// Gửi thông báo trạng thái tài khoản
  Future<void> guiThongBaoTaiKhoan({
    required int idTaiKhoan,
    required int trangThai,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/thongbao/tai-khoan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_tai_khoan': idTaiKhoan,
        'trang_thai': trangThai,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gửi thông báo thất bại: ${response.body}');
    }
  }

  /// Lấy danh sách thông báo của người dùng
  Future<List<dynamic>> layThongBaoTheoTaiKhoan(int idTaiKhoan) async {
    final response = await http.get(
      Uri.parse('$baseUrl/thongbao/nguoidung/$idTaiKhoan'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể lấy danh sách thông báo: ${response.body}');
    }
  }
}
