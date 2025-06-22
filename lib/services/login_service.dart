import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_end/services/api_config.dart'; // Import cấu hình API

class LoginService {
  // Phương thức đăng nhập 
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'), // Sử dụng baseUrl từ ApiConfig
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Đăng nhập thành công, trả về toàn bộ dữ liệu phản hồi từ server
        return responseData;
      } else {
        // Xử lý lỗi từ server
        String errorMessage = responseData['message'] ?? 'Đã xảy ra lỗi không xác định.';
        if (responseData['errors'] != null) {
          // Lấy chi tiết lỗi validation từ Laravel
          Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((key, value) {
            errorMessage += '\n- ${value[0]}'; // Lấy thông báo lỗi đầu tiên cho mỗi trường
          });
        }
        // Ném một ngoại lệ để hàm gọi (trong LoginScreen) có thể bắt và hiển thị lỗi
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Xử lý lỗi mạng hoặc các lỗi khác không liên quan đến phản hồi HTTP
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng hoặc địa chỉ API. Chi tiết: $e');
    }
  }
}