// services/tai_khoan_service.dart
import 'dart:convert';
import 'dart:io'; // Import để bắt SocketException
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Để lấy token
import 'package:flutter/foundation.dart'; // For debugPrint

class TaiKhoanService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Phương thức chung để lấy token xác thực
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('Người dùng chưa được xác thực. Vui lòng đăng nhập lại.');
    }
    return token;
  }

  // Hàm trợ giúp để định dạng lỗi validation một cách thân thiện hơn
  String _formatValidationErrors(Map<String, dynamic> errors) {
    List<String> messages = [];
    errors.forEach((field, msgs) {
      if (msgs is List && msgs.isNotEmpty) {
        messages.add(msgs[0].toString()); // Chỉ lấy thông báo đầu tiên cho mỗi trường
      }
    });
    return messages.isNotEmpty ? messages.join('\n') : 'Dữ liệu không hợp lệ.';
  }

  // Phương thức để lấy danh sách tài khoản chung (có hỗ trợ tìm kiếm, phân trang và lọc theo trạng thái)
  Future<Map<String, dynamic>> getAccounts({
    String? search,
    int page = 1,
    int perPage = 10,
    int? status, // THÊM THAM SỐ TRẠNG THÁI
  }) async {
    final token = await _getToken();

    String queryString = '?page=$page&per_page=$perPage';
    if (search != null && search.isNotEmpty) {
      queryString += '&search=$search';
    }
    // NỐI THAM SỐ TRẠNG THÁI VÀO QUERY STRING NẾU CÓ
    if (status != null) {
      queryString += '&trang_thai=$status'; // Đảm bảo tên tham số khớp với backend của bạn
    }

    final url = Uri.parse('$_baseUrl${ApiConfig.accountsEndpoint}$queryString');

    // IN RA URL ĐỂ DEBUG
    debugPrint('Fetching accounts from URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 403) {
        throw Exception(responseData['message'] ?? 'Bạn không có quyền truy cập chức năng này.');
      } else {
        // In chi tiết lỗi từ backend để dễ debug hơn trong môi trường dev
        debugPrint('Backend Error Response (Get Accounts): ${response.body}');
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định khi lấy danh sách tài khoản.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      // In chi tiết lỗi không mong muốn để dễ debug
      debugPrint('Unexpected error in getAccounts: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }

  // Phương thức để lấy danh sách tài khoản đang chờ duyệt
  Future<Map<String, dynamic>> getPendingAccounts({String? search, int page = 1, int perPage = 10}) async {
    final token = await _getToken();

    String queryString = '?page=$page&per_page=$perPage';
    if (search != null && search.isNotEmpty) {
      queryString += '&search=$search';
    }

    final url = Uri.parse('$_baseUrl${ApiConfig.pendingAccountsEndpoint}$queryString');

    // IN RA URL ĐỂ DEBUG
    debugPrint('Fetching pending accounts from URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 403) {
        throw Exception(responseData['message'] ?? 'Bạn không có quyền truy cập danh sách này.');
      } else {
        debugPrint('Backend Error Response (Get Pending Accounts): ${response.body}');
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định khi lấy danh sách tài khoản chờ duyệt.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('Unexpected error in getPendingAccounts: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }

  // Phương thức lấy thông tin chi tiết một tài khoản bằng ID
  Future<Map<String, dynamic>> getAccountById(String id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl${ApiConfig.accountsEndpoint}/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 403) {
        throw Exception(responseData['message'] ?? 'Bạn không có quyền truy cập thông tin này.');
      } else if (response.statusCode == 404) {
        throw Exception(responseData['message'] ?? 'Không tìm thấy tài khoản.');
      } else {
        debugPrint('Backend Error Response (Get Account By ID): ${response.body}');
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định khi lấy thông tin tài khoản.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('Unexpected error in getAccountById: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }

  // Phương thức tạo tài khoản mới (thường dùng cho Admin tạo, khác với đăng ký của người dùng)
  Future<Map<String, dynamic>> createAccount({
    required String email,
    required String hoTen,
    required String matKhau,
    bool? gioiTinh,
    String? anhDaiDien, // Đây là chuỗi đường dẫn, không phải file
    String? sdt,
    bool? trangThai,
    bool? loaiTaiKhoan,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl${ApiConfig.accountsEndpoint}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'ho_ten': hoTen,
          'mat_khau': matKhau,
          'gioi_tinh': gioiTinh,
          'anh_dai_dien': anhDaiDien, // Gửi chuỗi đường dẫn ảnh (nếu có)
          'so_dien_thoai': sdt,
          'trang_thai': trangThai,
          'loai_tai_khoan': loaiTaiKhoan,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) { // 201 Created
        return responseData;
      } else if (response.statusCode == 422) { // Validation error
        throw Exception(responseData['message'] ?? 'Dữ liệu không hợp lệ.\n${_formatValidationErrors(responseData['errors'] ?? {})}.');
      } else {
        debugPrint('Backend Error Response (Create Account): ${response.body}');
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định khi tạo tài khoản.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('Unexpected error in createAccount: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }

  // Phương thức để cập nhật hồ sơ sinh viên (hoàn tất đăng ký)
  // Gửi thông tin Lop, ChuyenNganh, và File ảnh thẻ sinh viên
  Future<Map<String, dynamic>> updateStudentProfile(
      String userId,
      String lop,
      int chuyenNganhId, // ĐÃ SỬA: Thay đổi kiểu dữ liệu từ String sang int
      File studentCardImageFile) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl${ApiConfig.accountsEndpoint}/$userId');

    try {
      // Sử dụng MultipartRequest để gửi file
      var request = http.MultipartRequest('POST', url) // Laravel mong đợi POST và _method: PUT/PATCH
        ..headers.addAll({
          'Authorization': 'Bearer $token',
        })
        ..fields['_method'] = 'PUT' // Hoặc 'PATCH' tùy vào cấu hình route Laravel của bạn
        ..fields['sinh_vien[lop]'] = lop
        ..fields['sinh_vien[chuyen_nganh_id]'] = chuyenNganhId.toString(); // ĐÃ SỬA: Chuyển int sang String và dùng tên trường là chuyen_nganh_id

      // Thêm file ảnh thẻ sinh viên
      request.files.add(await http.MultipartFile.fromPath(
        'sinh_vien[anh_the_sinh_vien_file]', // Tên trường file mà Laravel Controller mong đợi
        studentCardImageFile.path,
        filename: studentCardImageFile.path.split('/').last,
      ));

      debugPrint('Sending student profile update for User ID: $userId');
      debugPrint('Lop: $lop, ChuyenNganh ID: $chuyenNganhId'); // Log ID thay vì tên chuyên ngành
      debugPrint('Student Card File Path: ${studentCardImageFile.path}');
      debugPrint('Target URL: $url');
      debugPrint('Request Fields: ${request.fields}');
      debugPrint('Request Files: ${request.files.map((f) => f.filename).toList()}');


      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 422) { // Validation error
        throw Exception(responseData['message'] ?? 'Dữ liệu không hợp lệ.\n${_formatValidationErrors(responseData['errors'] ?? {})}.');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        debugPrint('Backend Error Response (Update Student Profile): ${response.body}');
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định khi cập nhật hồ sơ sinh viên.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('Unexpected error in updateStudentProfile: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }


  // Phương thức cập nhật thông tin tài khoản (không bao gồm file upload)
  Future<Map<String, dynamic>> updateAccount(String id, {
    String? email,
    String? hoTen,
    String? matKhau,
    bool? gioiTinh,
    String? anhDaiDien, // Đây là chuỗi đường dẫn, không phải file
    String? sdt,
    int? trangThai, // Thay đổi sang int để khớp với 0/1/2 của DB
    bool? loaiTaiKhoan,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl${ApiConfig.accountsEndpoint}/$id');

    try {
      final response = await http.put( // Sử dụng PUT hoặc PATCH
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'ho_ten': hoTen,
          'mat_khau': matKhau,
          'gioi_tinh': gioiTinh,
          'anh_dai_dien': anhDaiDien,
          'so_dien_thoai': sdt,
          'trang_thai': trangThai, // Giá trị 0/1/2
          'loai_tai_khoan': loaiTaiKhoan,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 422) { // Validation error
        throw Exception(responseData['message'] ?? 'Dữ liệu không hợp lệ.\n${_formatValidationErrors(responseData['errors'] ?? {})}.');
      } else if (response.statusCode == 404) {
        throw Exception(responseData['message'] ?? 'Không tìm thấy tài khoản để cập nhật.');
      } else {
        debugPrint('Backend Error Response (Update Account): ${response.body}');
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định khi cập nhật tài khoản.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('Unexpected error in updateAccount: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }

  // Phương thức để cập nhật trạng thái khóa/kích hoạt của tài khoản (trang_thai)
  Future<Map<String, dynamic>> updateAccountStatus(String id, int newStatus) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl${ApiConfig.accountsEndpoint}/$id'); // Sử dụng endpoint update chung

    try {
      final response = await http.put( // Sử dụng PUT hoặc PATCH
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'trang_thai': newStatus, // Chỉ gửi trường trạng thái
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 422) {
        throw Exception(responseData['message'] ?? 'Dữ liệu không hợp lệ.\n${_formatValidationErrors(responseData['errors'] ?? {})}.');
      } else if (response.statusCode == 404) {
        throw Exception(responseData['message'] ?? 'Không tìm thấy tài khoản để cập nhật trạng thái.');
      } else {
        debugPrint('Backend Error Response (Update Account Status): ${response.body}');
        throw Exception(responseData['message'] ?? 'Lỗi không xác định khi cập nhật trạng thái tài khoản.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('Unexpected error in updateAccountStatus: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }

  // Phương thức xóa tài khoản
  Future<Map<String, dynamic>> deleteAccount(String id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl${ApiConfig.accountsEndpoint}/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Nếu xóa thành công, Laravel thường trả về 204 No Content
      if (response.statusCode == 204) {
        return {'message': 'Tài khoản đã được xóa thành công.'};
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Không tìm thấy tài khoản để xóa.');
      } else {
        debugPrint('Backend Error Response (Delete Account): ${response.body}');
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Lỗi không xác định khi xóa tài khoản.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('Unexpected error in deleteAccount: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }

    // Phương thức đăng ký tài khoản Admin
  Future<Map<String, dynamic>> registerAdminAccount({
    required String email,
    required String hoTen,
    required String matKhau,
    String? sdt,
    int? gioiTinh, // 0 for nữ, 1 for nam
  }) async {
    final url = '${ApiConfig.baseUrl}${ApiConfig.registerAdminEndpoint}';
    final body = {
      'email': email,
      'ho_ten': hoTen,
      'mat_khau': matKhau,
      'mat_khau_confirmation': matKhau, // Laravel requires 'confirmed' validation
      if (sdt != null) 'sdt': sdt,
      if (gioiTinh != null) 'gioi_tinh': gioiTinh,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // No Authorization header needed if this route is not protected
        },
        body: json.encode(body),
      );

      debugPrint('POST Admin Register URL: $url');
      debugPrint('POST Admin Register Body: $body');
      debugPrint('POST Admin Register Response Status: ${response.statusCode}');
      debugPrint('POST Admin Register Response Body: ${response.body}');

      if (response.statusCode == 201) { // 201 Created is expected for successful registration
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Đăng ký tài khoản quản trị thất bại';
        // Có thể lấy errors chi tiết nếu có
        final errors = errorData['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          // Xử lý các lỗi validation cụ thể để hiển thị cho người dùng
          String detailedErrors = '';
          errors.forEach((key, value) {
            detailedErrors += '${key}: ${(value as List).join(', ')}\n';
          });
          throw Exception('$errorMessage\n$detailedErrors');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error registering admin account: $e');
      throw Exception('Lỗi khi đăng ký tài khoản quản trị: $e');
    }
  }

    // Phương thức để cập nhật ảnh đại diện người dùng
  Future<Map<String, dynamic>> updateProfilePicture(
      String userId, File profileImageFile) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl${ApiConfig.accountsEndpoint}/$userId');

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
        })
        ..fields['_method'] = 'PUT'; // Sử dụng PUT method cho update

      // Thêm file ảnh đại diện
      request.files.add(await http.MultipartFile.fromPath(
        'anh_dai_dien_file', // Tên trường file mà Laravel Controller mong đợi cho ảnh đại diện
        profileImageFile.path,
        filename: profileImageFile.path.split('/').last,
      ));

      debugPrint('Sending profile picture update for User ID: $userId');
      debugPrint('Profile Image File Path: ${profileImageFile.path}');
      debugPrint('Target URL: $url');
      debugPrint('Request Fields: ${request.fields}');
      debugPrint('Request Files: ${request.files.map((f) => f.filename).toList()}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 422) { // Validation error
        throw Exception(responseData['message'] ?? 'Dữ liệu ảnh không hợp lệ.\n${_formatValidationErrors(responseData['errors'] ?? {})}.');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 404) {
        throw Exception(responseData['message'] ?? 'Không tìm thấy tài khoản để cập nhật ảnh đại diện.');
      } else {
        debugPrint('Backend Error Response (Update Profile Picture): ${response.body}');
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi không xác định khi cập nhật ảnh đại diện.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('Unexpected error in updateProfilePicture: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }

  // Phương thức để thay đổi mật khẩu (giữ nguyên)
  Future<Map<String, dynamic>> changePassword(String userId, String currentPassword, String newPassword) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl${ApiConfig.changePasswordEndpoint}'); // Bạn cần định nghĩa endpoint này


    debugPrint('Change Password Request URL: $url');
    debugPrint('Token retrieved by _getToken(): $token'); // Kiểm tra xem token có giá trị không
    debugPrint('Headers being sent: {Content-Type: application/json, Authorization: Bearer $token}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword, // Cần cho Laravel 'confirmed' rule
        }),
      );

      final responseData = jsonDecode(response.body);
      debugPrint('Change Password Response: ${response.body}');

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 422) { // Validation error (invalid current password, new password rules, etc.)
        throw Exception(responseData['message'] ?? 'Dữ liệu không hợp lệ.\n${_formatValidationErrors(responseData['errors'] ?? {})}.');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 403) { // Forbidden, if the user_id doesn't match authenticated user
        throw Exception(responseData['message'] ?? 'Bạn không có quyền thực hiện hành động này.');
      } else {
        throw Exception(responseData['message'] ?? 'Đã xảy ra lỗi khi thay đổi mật khẩu.');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ máy chủ. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('Unexpected error in changePassword: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn khi thay đổi mật khẩu: ${e.toString().replaceFirst('Exception: ', '')}.');
    }
  }
}
