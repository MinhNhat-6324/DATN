import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class RegisterService {
  final String _baseUrl = ApiConfig.baseUrl; 

  Future<Map<String, dynamic>> sendOtpForRegistration(
    String email,
    String password,
    String confirmPassword,
    String hoTen,
    String? sdt,
    int? gioiTinh,
  ) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.registerEndpoint}'); 

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'mat_khau': password,
          'mat_khau_confirmation': confirmPassword,
          'ho_ten': hoTen,
          'sdt': sdt,
          'gioi_tinh': gioiTinh,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData.containsKey('user_id') && responseData['user_id'] != null) {
          return responseData;
        } else {
          throw Exception('Phản hồi từ máy chủ không chứa ID người dùng hợp lệ.');
        }
      } else if (response.statusCode == 409) { // Xử lý lỗi 409 Conflict
        throw Exception(responseData['message'] ?? 'Email này đã được đăng ký.');
      } else {
        // Log phản hồi từ backend để dễ debug hơn
        print('Backend Error Response: ${response.body}');
        throw Exception(responseData['message'] ?? 'Lỗi không xác định khi gửi OTP.');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }

  // Các phương thức verifyOtp, resendOtp, updateStudentProfile giữ nguyên
  Future<Map<String, dynamic>> verifyOtp(String userId, String otpCode) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.verifyOtpEndpoint}'); 

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'otp_code': otpCode,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        print('Backend Error Response (Verify OTP): ${response.body}');
        // Cần xử lý lỗi validation cụ thể nếu backend trả về errors field
        if (response.statusCode == 422 && responseData.containsKey('errors')) {
            String errorMsg = responseData['message'] ?? 'Lỗi xác thực OTP không xác định.';
            if (responseData['errors']['otp_code'] != null) {
                errorMsg = responseData['errors']['otp_code'][0];
            } else if (responseData['errors']['user_id'] != null) {
                errorMsg = responseData['errors']['user_id'][0];
            }
            throw Exception(errorMsg);
        }
        throw Exception(responseData['message'] ?? 'Lỗi xác thực OTP không xác định.');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }

  Future<Map<String, dynamic>> resendOtp(String userId, String email) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.resendOtpEndpoint}'); 

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'email': email,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        print('Backend Error Response (Resend OTP): ${response.body}');
        // Cần xử lý lỗi validation cụ thể nếu backend trả về errors field
        if (response.statusCode == 422 && responseData.containsKey('errors')) {
            String errorMsg = responseData['message'] ?? 'Lỗi gửi lại OTP không xác định.';
            if (responseData['errors']['user_id'] != null) {
                errorMsg = responseData['errors']['user_id'][0];
            } else if (responseData['errors']['email'] != null) {
                errorMsg = responseData['errors']['email'][0];
            }
            throw Exception(errorMsg);
        }
        throw Exception(responseData['message'] ?? 'Lỗi gửi lại OTP không xác định.');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }

  Future<Map<String, dynamic>> updateStudentProfile(
    String userId,
    String lop,
    String chuyenNganh,
    File imageFile,
  ) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.updateProfileEndpoint}'); 

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['user_id'] = userId;
      request.fields['lop'] = lop;
      request.fields['chuyen_nganh'] = chuyenNganh;

      request.files.add(
        await http.MultipartFile.fromPath(
          'anh_dai_dien',
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        print('Backend Error Response (Update Profile): ${response.body}');
        // Cần xử lý lỗi validation cụ thể nếu backend trả về errors field
        if (response.statusCode == 422 && responseData.containsKey('errors')) {
            String errorMsg = responseData['message'] ?? 'Lỗi cập nhật thông tin không xác định.';
            // Lặp qua các lỗi để lấy thông báo chi tiết
            responseData['errors'].forEach((key, value) {
                errorMsg += '\n- ${value[0]}';
            });
            throw Exception(errorMsg);
        }
        throw Exception(responseData['message'] ?? 'Lỗi cập nhật thông tin không xác định.');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ: $e');
    }
  }
}
