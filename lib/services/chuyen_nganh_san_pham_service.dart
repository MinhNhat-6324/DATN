import 'dart:convert'; // Để xử lý JSON
import 'package:http/http.dart' as http; // Thư viện http
import 'api_config.dart'; // Import file cấu hình API
import 'package:front_end/model/chuyen_nganh_item.dart';
import 'dart:io'; // Để xử lý SocketException

class ChuyenNganhSanPhamService {
  final String _baseUrl = ApiConfig.baseUrl; // Lấy base URL từ ApiConfig

  // CẬP NHẬT: Đổi tên phương thức và kiểu trả về
  Future<List<ChuyenNganhItem>> fetchAllChuyenNganh() async {
    try {
      // Đảm bảo endpoint này trả về cả id_nganh và ten_nganh
      final response = await http.get(Uri.parse('$_baseUrl/chuyen-nganh-san-pham'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Kiểm tra cấu trúc phản hồi của Laravel (status: success, data: [])
        if (responseData['status'] == 'success' && responseData['data'] is List) {
          List<ChuyenNganhItem> chuyenNganhList = [];
          for (var item in responseData['data']) {
            // CẬP NHẬT: Sử dụng factory constructor để parse JSON thành ChuyenNganhItem
            try {
              chuyenNganhList.add(ChuyenNganhItem.fromJson(item));
            } catch (e) {
              // Log hoặc xử lý lỗi nếu một item không đúng định dạng
              print('Lỗi khi parse ChuyenNganhItem từ API: $item, Lỗi: $e');
            }
          }
          return chuyenNganhList;
        } else {
          String errorMessage = responseData['message'] ?? 'Dữ liệu API chuyên ngành không hợp lệ.';
          throw Exception('Lỗi API: $errorMessage');
        }
      } else {
        String errorMessage = 'Không thể tải chuyên ngành. Mã lỗi: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Không thể giải mã body lỗi, dùng thông báo mặc định
        }
        throw Exception(errorMessage);
      }
    } on SocketException {
      // Xử lý lỗi kết nối mạng
      throw Exception('Lỗi kết nối mạng: Vui lòng kiểm tra kết nối internet hoặc địa chỉ API.');
    } on http.ClientException catch (e) {
      // Xử lý các lỗi HTTP client khác (ví dụ: host lookup failed)
      throw Exception('Lỗi HTTP Client: ${e.message}');
    } catch (e) {
      // Bắt các loại lỗi khác
      throw Exception('Đã xảy ra lỗi không xác định khi tải chuyên ngành: ${e.toString()}');
    }
  }
}