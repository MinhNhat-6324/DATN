import 'dart:convert';
import 'package:http/http.dart' as http;

class BaoCao {
  final int id;
  final int maBaiDang;
  final int idTaiKhoanBaoCao;
  final String? lyDo;
  final String? moTaThem;
  final String? thoiGianBaoCao;
  final String? trangThai;

  BaoCao({
    required this.id,
    required this.maBaiDang,
    required this.idTaiKhoanBaoCao,
    this.lyDo,
    this.moTaThem,
    this.thoiGianBaoCao,
    this.trangThai,
  });

  factory BaoCao.fromJson(Map<String, dynamic> json) {
    return BaoCao(
      id: json['id_bao_cao'] ?? 0,
      maBaiDang: json['ma_bai_dang'] ?? 0,
      idTaiKhoanBaoCao: json['id_tai_khoan_bao_cao'] ?? 0,
      lyDo: json['ly_do'],
      moTaThem: json['mo_ta_them'],
      thoiGianBaoCao: json['thoi_gian_bao_cao'],
      trangThai: json['trang_thai'],
    );
  }
}

Future<void> guiBaoCao({
  required int idBaiDang,
  required int idNguoiBaoCao,
  String? lyDo,
  String? moTaThem,
}) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/bao-cao/bai-dang/$idBaiDang');

  final Map<String, dynamic> body = {
    'id_tai_khoan_bao_cao': idNguoiBaoCao,
    'trang_thai': 'dang_cho',
    if (lyDo != null) 'ly_do': lyDo,
    if (moTaThem != null) 'mo_ta_them': moTaThem,
  };

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode != 201) {
    throw Exception('❌ Gửi báo cáo thất bại: ${response.body}');
  }

  print('✅ Gửi báo cáo thành công');
}
