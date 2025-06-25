import 'dart:convert';
import 'package:http/http.dart' as http;

class Nganh {
  final int id;
  final String tenNganh;

  Nganh({required this.id, required this.tenNganh});

  factory Nganh.fromJson(Map<String, dynamic> json) {
    return Nganh(
      id: json['id_nganh'] ?? 0,
      tenNganh: json['ten_nganh'] ?? '',
    );
  }
}

Future<List<Nganh>> getDanhSachNganh() async {
  final url = Uri.parse('http://10.0.2.2:8000/api/chuyen-nganh-san-pham');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    final List<dynamic> data = json['data']; // 👈 lấy đúng trường 'data'
    return data.map((e) => Nganh.fromJson(e)).toList();
  } else {
    throw Exception('Không thể lấy danh sách ngành');
  }
}
