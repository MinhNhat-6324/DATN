import 'dart:convert';
import 'package:http/http.dart' as http;

class LoaiSanPham {
  final int id;
  final String tenLoai;

  LoaiSanPham({
    required this.id,
    required this.tenLoai,
  });

  factory LoaiSanPham.fromJson(Map<String, dynamic> json) {
    return LoaiSanPham(
      id: json['id_loai'],
      tenLoai: json['ten_loai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_loai': id,
      'ten_loai': tenLoai,
    };
  }
}

Future<List<LoaiSanPham>> getDanhSachLoai() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/loai'));
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => LoaiSanPham.fromJson(json)).toList();
  } else {
    throw Exception('Lỗi khi tải danh sách loại sản phẩm');
  }
}
