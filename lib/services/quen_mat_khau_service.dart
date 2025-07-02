// lib/services/quen_mat_khau_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart'; // Import cấu hình API

class QuenMatKhauService {
  // Phương thức để gửi yêu cầu đặt lại mật khẩu, gửi mã OTP đến email.
  // Gọi API: POST /api/password/forgot
  Future<Map<String, dynamic>> sendResetOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.forgotPasswordRequestEndpoint}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        String errorMessage = responseData['message'] ?? 'Đã xảy ra lỗi không xác định từ máy chủ.';
        if (responseData['errors'] != null) {
          Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((key, value) {
            errorMessage += '\n- ${value[0]}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng hoặc địa chỉ API. Chi tiết: $e');
    }
  }

  // Phương thức để xác thực mã OTP cho đặt lại mật khẩu.
  // Gọi API: POST /api/password/verify-reset-otp
  Future<Map<String, dynamic>> verifyResetOtp(String email, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyResetOtpEndpoint}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'otp_code': otpCode,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        String errorMessage = responseData['message'] ?? 'Đã xảy ra lỗi không xác định từ máy chủ.';
        if (responseData['errors'] != null) {
          Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((key, value) {
            errorMessage += '\n- ${value[0]}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng hoặc địa chỉ API. Chi tiết: $e');
    }
  }

  // Phương thức để đặt lại mật khẩu mới sau khi xác thực OTP thành công.
  // Gọi API: POST /api/password/reset
  Future<Map<String, dynamic>> resetPassword(
      String email, String otpCode, String newPassword, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.resetPasswordEndpoint}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'otp_code': otpCode,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword, // Phải khớp với tên trường validation của backend
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        String errorMessage = responseData['message'] ?? 'Đã xảy ra lỗi không xác định từ máy chủ.';
        if (responseData['errors'] != null) {
          Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((key, value) {
            errorMessage += '\n- ${value[0]}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng hoặc địa chỉ API. Chi tiết: $e');
    }
  }
}