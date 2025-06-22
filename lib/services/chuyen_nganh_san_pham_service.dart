import 'dart:convert'; // Để xử lý JSON
import 'package:http/http.dart' as http; // Thư viện http
import 'api_config.dart'; // Import file cấu hình API

class ChuyenNganhSanPhamService {
  final String _baseUrl = ApiConfig.baseUrl; // Lấy base URL từ ApiConfig

  // Phương thức để lấy danh sách tên chuyên ngành
  Future<List<String>> fetchChuyenNganhNames() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/chuyen-nganh-san-pham')); // Gọi API endpoint của bạn

      if (response.statusCode == 200) {
        // Giải mã phản hồi JSON
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Kiểm tra cấu trúc phản hồi của Laravel (status: success, data: [])
        if (responseData['status'] == 'success' && responseData['data'] is List) {
          List<String> chuyenNganhNames = [];
          for (var item in responseData['data']) {
            // Lấy giá trị của trường 'ten_nganh' từ mỗi đối tượng
            if (item['ten_nganh'] != null) {
              chuyenNganhNames.add(item['ten_nganh'].toString());
            }
          }
          return chuyenNganhNames;
        } else {
          // Xử lý trường hợp status không phải success hoặc data không phải list
          String errorMessage = responseData['message'] ?? 'Dữ liệu API chuyên ngành không hợp lệ.';
          throw Exception('Lỗi API: $errorMessage');
        }
      } else {
        // Xử lý các lỗi HTTP khác (ví dụ: 404 Not Found, 500 Internal Server Error)
        String errorMessage = 'Không thể tải chuyên ngành. Mã lỗi: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Không thể giải mã body lỗi, dùng thông báo mặc định
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      // Xử lý lỗi kết nối mạng (ví dụ: không có internet, server không chạy)
      throw Exception('Lỗi kết nối mạng: Vui lòng kiểm tra kết nối internet hoặc địa chỉ API. Chi tiết: ${e.message}');
    } catch (e) {
      // Bắt các loại lỗi khác
      throw Exception('Đã xảy ra lỗi không xác định khi tải chuyên ngành: ${e.toString()}');
    }
  }
}