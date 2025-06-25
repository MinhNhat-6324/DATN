import 'dart:convert';
import 'dart:io'; // Import để bắt SocketException
import 'package:http/http.dart' as http;
import 'api_config.dart'; // Đảm bảo đường dẫn này đúng

class RegisterService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Hàm trợ giúp để định dạng lỗi validation một cách thân thiện hơn
  String _formatValidationErrorsForUser(Map<String, dynamic> errors) {
    if (errors.isEmpty) return 'Dữ liệu đầu vào không hợp lệ.';

    List<String> messages = [];
    errors.forEach((field, msgs) {
      if (msgs is List && msgs.isNotEmpty) {
        messages.add(msgs[0].toString()); // Chỉ lấy thông báo đầu tiên cho mỗi trường
      }
    });

    if (messages.contains('The email has already been taken.')) {
      return 'Email này đã được đăng ký. Vui lòng sử dụng email khác.';
    }

    // Các lỗi khác có thể được nhóm lại hoặc liệt kê đơn giản
    if (messages.isNotEmpty) {
      // Nếu có nhiều lỗi khác, có thể hiển thị một vài lỗi đầu tiên hoặc một thông báo chung
      return 'Vui lòng kiểm tra lại thông tin nhập liệu: ${messages.join(', ')}.';
    }
    return 'Dữ liệu đầu vào không hợp lệ. Vui lòng kiểm tra lại.';
  }


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
      } else if (response.statusCode == 409) { // Xử lý lỗi 409 Conflict (Email đã tồn tại)
        // Thông báo cụ thể cho lỗi email đã tồn tại
        throw Exception('Tài khoản đã tồn tại. Vui lòng đăng nhập hoặc sử dụng email khác.');
      } else if (response.statusCode == 422) { // Lỗi validation khác (ví dụ: mật khẩu không khớp, min length)
        String errorMessage = responseData['message'] ?? 'Dữ liệu đầu vào không hợp lệ.';
        if (responseData.containsKey('errors') && responseData['errors'] is Map) {
          // Sử dụng hàm trợ giúp để định dạng lỗi thân thiện
          errorMessage = _formatValidationErrorsForUser(responseData['errors']);
        }
        throw Exception(errorMessage);
      } else {
        // Xử lý các mã lỗi HTTP khác mà backend trả về
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      // Bắt bất kỳ lỗi nào khác không được xử lý cụ thể
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
        return responseData;
      } else if (response.statusCode == 422) {
        // Cụ thể hóa lỗi OTP
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
    String chuyenNganh,
    File imageFile,
  ) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.updateProfileEndpoint}'); 

    try {
      var request = http.MultipartRequest('POST', url);
      // Bạn sẽ cần một token xác thực ở đây nếu endpoint này được bảo vệ bởi middleware 'auth:sanctum'
      // Để truyền token, bạn cần thêm nó vào headers:
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('auth_token');
      // if (token != null) {
      //   request.headers['Authorization'] = 'Bearer $token';
      // } else {
      //   throw Exception('Người dùng chưa được xác thực để cập nhật hồ sơ.');
      // }


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
      } else if (response.statusCode == 422) {
        String errorMessage = responseData['message'] ?? 'Dữ liệu đầu vào không hợp lệ.';
        if (responseData.containsKey('errors') && responseData['errors'] is Map) {
          errorMessage = _formatValidationErrorsForUser(responseData['errors']);
        }
        throw Exception(errorMessage);
      } else if (response.statusCode == 403) { // Lỗi cấm truy cập
        throw Exception(responseData['message'] ?? 'Bạn không có quyền thực hiện hành động này.');
      } else if (response.statusCode == 404) { // Không tìm thấy
        throw Exception(responseData['message'] ?? 'Không tìm thấy tài nguyên. Vui lòng liên hệ hỗ trợ.');
      } else {
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.');
    }
  }
}
