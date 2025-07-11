import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Thêm để dùng debugPrint
import 'api_config.dart';

class ThongBaoService {
  /// Gửi thông báo trạng thái tài khoản
Future<void> guiThongBaoTaiKhoan({
  required int idTaiKhoan,
  required int trangThai,
  String? lyDo, // Thêm lý do
}) async {
  final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.thongBaoTaiKhoanEndpoint}');
  
  final body = {
    'id_tai_khoan': idTaiKhoan,
    'trang_thai': trangThai,
    if (lyDo != null && lyDo.isNotEmpty) 'ly_do': lyDo, // thêm vào nếu có
  };

  debugPrint('Đang gọi API thông báo trạng thái tài khoản: $url');
  debugPrint('Body gửi đi: ${jsonEncode(body)}');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    debugPrint('Mã trạng thái phản hồi: ${response.statusCode}');
    debugPrint('Nội dung phản hồi: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('Gửi thông báo thành công.');
    } else {
      throw Exception('Gửi thông báo thất bại: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    debugPrint('Lỗi khi gửi thông báo: $e');
    throw Exception('Lỗi kết nối hoặc phản hồi không hợp lệ khi gửi thông báo: $e');
  }
}


  /// Lấy danh sách thông báo của người dùng
  Future<List<dynamic>> layThongBaoTheoTaiKhoan(int idTaiKhoan) async {
    // URL CẦN PHẢI LÀ: ApiConfig.baseUrl + ApiConfig.thongBaoTheoNguoiDungEndpoint + / + idTaiKhoan
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.thongBaoTheoNguoiDungEndpoint}/$idTaiKhoan');
    
    debugPrint('Đang gọi API lấy thông báo theo người dùng: $url');

    try {
      final response = await http.get(url);

      debugPrint('Mã trạng thái phản hồi: ${response.statusCode}');
      debugPrint('Nội dung phản hồi: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Không thể lấy danh sách thông báo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy thông báo: $e');
      throw Exception('Lỗi kết nối hoặc phản hồi không hợp lệ khi lấy thông báo: $e');
    }
  }

   //ĐÁNH DẤU THÔNG BÁO ĐÃ ĐỌC
  Future<void> markThongBaoAsRead(int thongBaoId) async {
    // URL này sẽ khớp với Route::patch('/{idThongBao}', ...)
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.thongBaoEndpoint}/$thongBaoId');
    
    debugPrint('Đang gọi API để đánh dấu thông báo $thongBaoId là đã đọc: $url');

    try {
      final response = await http.patch( // SỬ DỤNG http.patch
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'da_doc': 1, // Gửi 1 để đánh dấu là đã đọc
        }),
      );

      debugPrint('Phản hồi đánh dấu đã đọc: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('Thông báo $thongBaoId đã được đánh dấu là đã đọc.');
      } else {
        throw Exception('Không thể đánh dấu thông báo đã đọc: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Lỗi khi đánh dấu thông báo đã đọc $thongBaoId: $e');
      throw Exception('Lỗi kết nối hoặc phản hồi không hợp lệ khi đánh dấu thông báo đã đọc: $e');
    }
  }

    /// Gửi yêu cầu mở khóa tài khoản
  Future<void> guiYeuCauMoKhoaTaiKhoan({
    required int idTaiKhoan,
    String? noiDung,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.guiYeuCauMoKhoaTaiKhoan}');
    final body = {
      'id_tai_khoan': idTaiKhoan,
      if (noiDung != null && noiDung.isNotEmpty) 'noi_dung': noiDung,
    };

    debugPrint('Đang gọi API gửi yêu cầu mở khóa: $url');
    debugPrint('Body gửi đi: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Mã phản hồi: ${response.statusCode}');
      debugPrint('Nội dung phản hồi: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Gửi yêu cầu mở khóa thành công.');
      } else {
        throw Exception('Không thể gửi yêu cầu mở khóa: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Lỗi khi gửi yêu cầu mở khóa: $e');
      throw Exception('Lỗi kết nối hoặc phản hồi không hợp lệ khi gửi yêu cầu mở khóa: $e');
    }
  }

}