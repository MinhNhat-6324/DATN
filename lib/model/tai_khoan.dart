import 'dart:convert';
import 'package:http/http.dart' as http;

class TaiKhoan {
  final int id;
  final String hoTen;
  final String? anhDaiDien;

  TaiKhoan({
    required this.id,
    required this.hoTen,
    this.anhDaiDien,
  });

  factory TaiKhoan.fromJson(Map<String, dynamic> json) {
    return TaiKhoan(
      id: json['id_tai_khoan'],
      hoTen: json['ho_ten'] ?? '',
      anhDaiDien: json['anh_dai_dien'],
    );
  }
}

/// Trả về Map gồm 2 danh sách: da_gui_toi và duoc_gui_tu
Future<Map<String, List<TaiKhoan>>> fetchDanhSachDoiTuongChat({
  required int userId,
  String? token,
}) async {
  final url = Uri.parse(
      'http://10.0.2.2:8000/api/tin-nhan/danh-sach-doi-tuong/$userId');

  final headers = {
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);

    final List<TaiKhoan> daGuiToi = (json['da_gui_toi'] as List)
        .map((item) => TaiKhoan.fromJson(item))
        .toList();

    final List<TaiKhoan> duocGuiTu = (json['duoc_gui_tu'] as List)
        .map((item) => TaiKhoan.fromJson(item))
        .toList();

    return {
      'da_gui_toi': daGuiToi,
      'duoc_gui_tu': duocGuiTu,
    };
  } else {
    throw Exception(
        'Lỗi khi tải danh sách đối tượng chat: ${response.statusCode}');
  }
}
