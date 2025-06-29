import 'dart:convert';
import 'package:http/http.dart' as http;

class SinhVien {
  final int idSinhVien;
  final String? anhTheSinhVien;
  final String? lop;
  final int? chuyenNganh; // vẫn dùng tên này trong app

  SinhVien({
    required this.idSinhVien,
    this.anhTheSinhVien,
    this.lop,
    this.chuyenNganh,
  });

  factory SinhVien.fromJson(Map<String, dynamic> json) {
    return SinhVien(
      idSinhVien: json['id_sinh_vien'],
      anhTheSinhVien: json['anh_the_sinh_vien'],
      lop: json['lop'],
      chuyenNganh: json['id_nganh'], // ✅ Đã sửa đúng tên
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sinh_vien': idSinhVien,
      'anh_the_sinh_vien': anhTheSinhVien,
      'lop': lop,
      'id_nganh': chuyenNganh, // hoặc 'chuyen_nganh' tùy backend
    };
  }
}

Future<SinhVien?> fetchSinhVienById(int id) async {
  try {
    final url = Uri.parse('http://10.0.2.2:8000/api/sinh-vien/$id');
    final response = await http.get(url);

    print("📥 JSON sinh viên: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return SinhVien.fromJson(jsonData);
    } else {
      print('⚠️ Status code: ${response.statusCode}');
      print('⚠️ Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    print('❌ Lỗi khi gọi API lấy sinh viên: $e');
    rethrow;
  }
}
