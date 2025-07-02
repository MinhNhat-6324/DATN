import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Import để sử dụng debugPrint
import 'package:shared_preferences/shared_preferences.dart'; // Import nếu bạn cần lưu/lấy token

import 'api_config.dart';

class RegisterService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Hàm trợ giúp để định dạng lỗi validation một cách thân thiện hơn
  String _formatValidationErrorsForUser(Map<String, dynamic> errors) {
    if (errors.isEmpty) return 'Dữ liệu đầu vào không hợp lệ.';

    List<String> messages = [];
    errors.forEach((field, msgs) {
      if (msgs is List && msgs.isNotEmpty) {
        // Lấy thông báo đầu tiên và dịch/làm đẹp nếu cần
        String msg = msgs[0].toString();
        if (field == 'email' && msg.contains('has already been taken')) {
          msg = 'Email này đã được đăng ký.';
        } else if (field == 'mat_khau' && msg.contains('The mat khau confirmation does not match')) {
          msg = 'Mật khẩu xác nhận không khớp.';
        }
        messages.add(msg);
      }
    });

    if (messages.isEmpty) return 'Dữ liệu đầu vào không hợp lệ. Vui lòng kiểm tra lại.';
    return 'Vui lòng kiểm tra lại thông tin nhập liệu: ${messages.join(', ')}. ';
  }

  // Hàm trợ giúp để lấy token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ... Các phương thức sendOtpForRegistration, verifyOtp, resendOtp giữ nguyên ...

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
          throw Exception('Đã xảy ra lỗi. Không thể lấy ID người dùng. Vui lòng liên hệ hỗ trợ.');
        }
      } else if (response.statusCode == 409) {
        throw Exception('Tài khoản đã tồn tại. Vui lòng đăng nhập hoặc sử dụng email khác.');
      } else if (response.statusCode == 422) {
        String errorMessage = responseData['message'] ?? 'Dữ liệu đầu vào không hợp lệ.';
        if (responseData.containsKey('errors') && responseData['errors'] is Map) {
          errorMessage = _formatValidationErrorsForUser(responseData['errors']);
        }
        throw Exception(errorMessage);
      } else {
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi. Vui lòng thử lại.');
    }
  }

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
        final token = responseData['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }
        return responseData;
    }else if (response.statusCode == 422) {
        String errorMessage = responseData['message'] ?? 'Mã OTP không hợp lệ hoặc đã hết hạn.';
        if (responseData.containsKey('errors') && responseData['errors'] is Map) {
          if (responseData['errors'].containsKey('otp_code')) {
            errorMessage = responseData['errors']['otp_code'][0];
          } else if (responseData['errors'].containsKey('user_id')) {
            errorMessage = responseData['errors']['user_id'][0];
          }
        }
        throw Exception(errorMessage);
      } else {
        throw Exception(responseData['message'] ?? 'Lỗi xác thực OTP không xác định. Vui lòng thử lại.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi. Vui lòng thử lại.');
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
      } else if (response.statusCode == 422) {
        String errorMessage = responseData['message'] ?? 'Dữ liệu yêu cầu gửi lại OTP không hợp lệ.';
        if (responseData.containsKey('errors') && responseData['errors'] is Map) {
          if (responseData['errors'].containsKey('user_id')) {
            errorMessage = responseData['errors']['user_id'][0];
          } else if (responseData['errors'].containsKey('email')) {
            errorMessage = responseData['errors']['email'][0];
          }
        }
        throw Exception(errorMessage);
      } else {
        throw Exception(responseData['message'] ?? 'Lỗi gửi lại OTP không xác định. Vui lòng thử lại.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.');
    }
  }

  Future<Map<String, dynamic>> updateStudentProfile(
    String userId,
    String lop,
    int chuyenNganhId, // ĐÃ SỬA: Thay đổi kiểu dữ liệu thành int
    File studentCardImageFile, // Đổi tên biến cho rõ ràng
  ) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.updateProfileEndpoint}'); 

    try {
      var request = http.MultipartRequest('POST', url); // Laravel mong đợi POST cho Multipart

      // THÊM TOKEN XÁC THỰC
      final token = await _getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      } else {
        throw Exception('Người dùng chưa được xác thực để cập nhật hồ sơ.');
      }
      
      // THÊM _method: PUT/PATCH nếu Laravel route mong đợi PUT/PATCH nhưng nhận POST cho multipart
      // request.fields['_method'] = 'PUT'; 

      request.fields['user_id'] = userId;
      request.fields['lop'] = lop;
      // ĐÃ SỬA: Gửi id của chuyên ngành dưới dạng chuỗi
      request.fields['chuyen_nganh_id'] = chuyenNganhId.toString(); 

      // ĐÃ SỬA: Tên trường file phải khớp với tên trong Laravel Controller
      request.files.add(
        await http.MultipartFile.fromPath(
          'anh_the_sinh_vien_file', // TÊN TRƯỜNG PHẢI KHỚP VỚI LARAVEL CONTROLLER
          studentCardImageFile.path,
          filename: studentCardImageFile.path.split('/').last,
        ),
      );

      debugPrint('Sending student profile update for User ID: $userId');
      debugPrint('Lop: $lop, ChuyenNganh ID: $chuyenNganhId');
      debugPrint('Student Card File Path: ${studentCardImageFile.path}');
      debugPrint('Target URL: $url');
      debugPrint('Request Fields: ${request.fields}');
      debugPrint('Request Files: ${request.files.map((f) => f.filename).toList()}');


      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else if (response.statusCode == 422) {
        String errorMessage = responseData['message'] ?? 'Dữ liệu đầu vào không hợp lệ.';
        if (responseData.containsKey('errors') && responseData['errors'] is Map) {
          errorMessage = _formatValidationErrorsForUser(responseData['errors']);
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) { // Unauthorized, token hết hạn hoặc không hợp lệ
        throw Exception('Phiên đăng nhập đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 403) {
        throw Exception(responseData['message'] ?? 'Bạn không có quyền thực hiện hành động này.');
      } else if (response.statusCode == 404) {
        throw Exception(responseData['message'] ?? 'Không tìm thấy tài nguyên. Vui lòng liên hệ hỗ trợ.');
      } else {
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      // debugPrint là tốt để gỡ lỗi trong quá trình phát triển, nhưng không nên đưa vào production log quá nhiều
      debugPrint('Unexpected error in updateStudentProfile (Flutter): $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }
}