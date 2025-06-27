import 'dart:convert';
import 'package:http/http.dart' as http;

class AnhBaiDang {
  final int? idAnh; // 👈 nullable
  final int idBaiDang;
  final String duongDan;
  final int thuTu;

  AnhBaiDang({
    this.idAnh, // 👈 optional
    required this.idBaiDang,
    required this.duongDan,
    required this.thuTu,
  });

  factory AnhBaiDang.fromJson(Map<String, dynamic> json) {
    return AnhBaiDang(
      idAnh: json['id_anh'] as int?, // 👈 nullable
      idBaiDang: json['id_bai_dang'] ?? 0,
      duongDan: json['duong_dan'] ?? '',
      thuTu: json['thu_tu'] ?? 1,
    );
  }
}

class BaiDang {
  final int id;
  final String tieuDe;
  final String gia;
  final int doMoi;
  final String trangThai;
  final DateTime ngayDang;
  final List<AnhBaiDang> anhBaiDang;
  final String? tenNganh; // 👈 Thêm dòng này

  BaiDang({
    required this.id,
    required this.tieuDe,
    required this.gia,
    required this.doMoi,
    required this.trangThai,
    required this.ngayDang,
    required this.anhBaiDang,
    this.tenNganh, // 👈 Constructor
  });

  factory BaiDang.fromJson(Map<String, dynamic> json) {
    var danhSachAnh = <AnhBaiDang>[];
    if (json['anh_bai_dang'] is List) {
      danhSachAnh = (json['anh_bai_dang'] as List)
          .map((x) => AnhBaiDang.fromJson(x))
          .toList();
    }

    return BaiDang(
      id: json['id_bai_dang'] ?? 0,
      tieuDe: json['tieu_de'] ?? '',
      gia: json['gia'] ?? '',
      doMoi: json['do_moi'] ?? 0,
      trangThai: json['trang_thai'] ?? '',
      ngayDang: DateTime.parse(json['ngay_dang']),
      anhBaiDang: danhSachAnh,
      tenNganh: json['chuyen_nganh_san_pham']?['ten_nganh'], // 👈 Lấy tên ngành
    );
  }
}

Future<List<BaiDang>> getBaiDangTheoNganh(int idNganh) async {
  try {
    final url = Uri.parse('http://10.0.2.2:8000/api/bai-dang/nganh/$idNganh');
    final response = await http.get(url);
    print("RAW JSON: ${response.body}"); // 👈 In ra dữ liệu JSON để kiểm tra

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BaiDang.fromJson(json)).toList();
    } else {
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Không lấy được bài đăng theo ngành');
    }
  } catch (e) {
    print('Lỗi khi gọi API: $e');
    rethrow;
  }
}

Future<List<BaiDang>> getBaiDangTheoNganhVaLoai(
    int idNganh, int? idLoai) async {
  try {
    // 👇 Tùy biến URL dựa trên idLoai có null hay không
    final url = idLoai == null
        ? Uri.parse('http://10.0.2.2:8000/api/bai-dang/nganh/$idNganh')
        : Uri.parse(
            'http://10.0.2.2:8000/api/bai-dang/nganh/$idNganh/loai/$idLoai');

    final response = await http.get(url);
    print("JSON ngành + loại: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BaiDang.fromJson(json)).toList();
    } else {
      print('Status code: ${response.statusCode}');
      throw Exception('Không lấy được bài đăng theo ngành và loại');
    }
  } catch (e) {
    print('Lỗi khi gọi API: $e');
    rethrow;
  }
}

Future<List<BaiDang>> getBaiDangTheoTieuDe(String tieuDe) async {
  try {
    final encodedTieuDe = Uri.encodeComponent(tieuDe);
    final url =
        Uri.parse('http://10.0.2.2:8000/api/bai-dang/tieu-de/$encodedTieuDe');

    final response = await http.get(url);
    print("JSON theo tiêu đề: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BaiDang.fromJson(json)).toList();
    } else {
      print('Status code: ${response.statusCode}');
      throw Exception('Không lấy được bài đăng theo tiêu đề');
    }
  } catch (e) {
    print('Lỗi khi gọi API theo tiêu đề: $e');
    rethrow;
  }
}

Future<List<BaiDang>> getBaiDangTheoNganhLoaiTieuDe(
    int idNganh, int idLoai, String tieuDe) async {
  try {
    // Nếu tiêu đề trống, dùng ký hiệu đặc biệt '-' (giống bên Laravel)
    final safeTieuDe = tieuDe.isEmpty ? '-' : Uri.encodeComponent(tieuDe);
    final url = Uri.parse(
        'http://10.0.2.2:8000/api/bai-dang/loc/$idNganh/$idLoai/$safeTieuDe');

    final response = await http.get(url);
    print("📦 JSON ngành + loại + tiêu đề: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BaiDang.fromJson(json)).toList();
    } else {
      print('⚠️ Status code: ${response.statusCode}');
      throw Exception('Không lấy được bài đăng theo ngành, loại và tiêu đề');
    }
  } catch (e) {
    print('❌ Lỗi khi gọi API bộ lọc bài đăng: $e');
    rethrow;
  }
}

Future<List<BaiDang>> getBaiDangTheoLoaiVaTieuDe(
    int idLoai, String tieuDe) async {
  try {
    final safeTieuDe =
        tieuDe.trim().isEmpty ? '-' : Uri.encodeComponent(tieuDe);
    final url = Uri.parse(
        'http://10.0.2.2:8000/api/bai-dang/loai/$idLoai/tieu-de/$safeTieuDe');

    final response = await http.get(url);
    print("📥 JSON loại + tiêu đề: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BaiDang.fromJson(json)).toList();
    } else {
      print('⚠️ Status code: ${response.statusCode}');
      throw Exception('Không lấy được bài đăng theo loại và tiêu đề');
    }
  } catch (e) {
    print('❌ Lỗi khi gọi API loại + tiêu đề: $e');
    rethrow;
  }
}

Future<List<BaiDang>> getTatCaBaiDang() async {
  try {
    final url = Uri.parse('http://10.0.2.2:8000/api/bai-dang');
    final response = await http.get(url);

    print("📦 JSON tất cả bài đăng: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BaiDang.fromJson(json)).toList();
    } else {
      print('⚠️ Status code: ${response.statusCode}');
      throw Exception('Không lấy được toàn bộ bài đăng');
    }
  } catch (e) {
    print('❌ Lỗi khi gọi API tất cả bài đăng: $e');
    rethrow;
  }
}

Future<List<BaiDang>> getBaiDangTheoLoai(int idLoai) async {
  try {
    final url = Uri.parse('http://10.0.2.2:8000/api/bai-dang/loai/$idLoai');
    final response = await http.get(url);
    print("📦 JSON bài đăng theo loại: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BaiDang.fromJson(json)).toList();
    } else {
      print('⚠️ Status code: ${response.statusCode}');
      throw Exception('Không lấy được bài đăng theo loại');
    }
  } catch (e) {
    print('❌ Lỗi khi gọi API bài đăng theo loại: $e');
    rethrow;
  }
}
