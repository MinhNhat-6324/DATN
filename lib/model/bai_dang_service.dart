import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class AnhBaiDang {
  final int? idAnh;
  final int idBaiDang;
  final String duongDan;
  final int thuTu;

  AnhBaiDang({
    this.idAnh,
    required this.idBaiDang,
    required this.duongDan,
    required this.thuTu,
  });

  factory AnhBaiDang.fromJson(Map<String, dynamic> json) {
    return AnhBaiDang(
      idAnh: json['id_anh'] as int?,
      idBaiDang: json['id_bai_dang'] ?? 0,
      duongDan: json['duong_dan'] ?? '',
      thuTu: json['thu_tu'] ?? 1,
    );
  }
}

class BaiDang {
  final int id;
  final String tieuDe;
  final int doMoi;
  final String trangThai;
  final DateTime ngayDang;
  final List<AnhBaiDang> anhBaiDang;
  final String? tenNganh;
  final int? idNganh;
  final int? idLoai;
  final int idTaiKhoan;

  BaiDang({
    required this.id,
    required this.tieuDe,
    required this.doMoi,
    required this.trangThai,
    required this.ngayDang,
    required this.anhBaiDang,
    required this.idTaiKhoan,
    this.tenNganh,
    this.idLoai,
    this.idNganh,
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
      doMoi: json['do_moi'] ?? 0,
      trangThai: json['trang_thai'] ?? '',
      ngayDang: DateTime.parse(json['ngay_dang']),
      anhBaiDang: danhSachAnh,
      idTaiKhoan: json['id_tai_khoan'] ?? 0,
      tenNganh: json['chuyen_nganh_san_pham']?['ten_nganh'],
      idNganh: json['id_nganh'],
      idLoai: json['id_loai'],
    );
  }
}

Future<List<BaiDang>> getBaiDangTheoNganh(int idNganh) async {
  try {
    final url = Uri.parse('http://10.0.2.2:8000/api/bai-dang/nganh/$idNganh');
    final response = await http.get(url);
    print("RAW JSON: ${response.body}");
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

Future<bool> postBaiDang({
  required int idTaiKhoan,
  required String tieuDe,
  required int doMoi,
  required int idLoai,
  required int idNganh,
  required List<File> hinhAnh,
}) async {
  try {
    final uri = Uri.parse("http://10.0.2.2:8000/api/bai-dang");
    final request = http.MultipartRequest('POST', uri);

    request.fields['id_tai_khoan'] = idTaiKhoan.toString();
    request.fields['tieu_de'] = tieuDe;
    request.fields['do_moi'] = doMoi.toString();
    request.fields['id_loai'] = idLoai.toString();
    request.fields['id_nganh'] = idNganh.toString();

    for (int i = 0; i < hinhAnh.length; i++) {
      final file = hinhAnh[i];
      final mimeType =
          lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];

      request.files.add(await http.MultipartFile.fromPath(
        'hinh_anh[$i]',
        file.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print(
        "\uD83D\uDCE4 POST bài đăng: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 201) {
      print('⚠️ Đăng bài thất bại! Mã lỗi: ${response.statusCode}');
      print('⚠️ Nội dung lỗi: ${response.body}');
    }

    return response.statusCode == 201;
  } catch (e) {
    print("❌ Lỗi khi gửi bài đăng: $e");
    return false;
  }
}

Future<List<BaiDang>> getBaiDangTheoNguoiDung(int idTaiKhoan) async {
  try {
    final url =
        Uri.parse('http://10.0.2.2:8000/api/bai-dang/nguoi-dung/$idTaiKhoan');
    final response = await http.get(url);

    print("📦 JSON bài đăng theo người dùng: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BaiDang.fromJson(json)).toList();
    } else {
      print('⚠️ Status code: ${response.statusCode}');
      throw Exception('Không lấy được bài đăng theo người dùng');
    }
  } catch (e) {
    print('❌ Lỗi khi gọi API bài đăng theo người dùng: $e');
    rethrow;
  }
}

Future<BaiDang?> getBaiDangTheoId(int idBaiDang) async {
  try {
    final url = Uri.parse('http://10.0.2.2:8000/api/bai-dang/$idBaiDang');
    final response = await http.get(url);

    print("📥 JSON chi tiết bài đăng theo ID: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return BaiDang.fromJson(data);
    } else if (response.statusCode == 404) {
      print('⚠️ Bài đăng không tồn tại');
      return null;
    } else {
      print('⚠️ Status code: ${response.statusCode}');
      throw Exception('Không lấy được bài đăng theo ID');
    }
  } catch (e) {
    print('❌ Lỗi khi gọi API chi tiết bài đăng: $e');
    return null;
  }
}

Future<bool> updateBaiDang({
  required int idBaiDang,
  required String tieuDe,
  required int doMoi,
  required int idLoai,
  required int idNganh,
  required List<File> hinhAnhMoi,
  required List<String> hinhAnhCanXoa,
}) async {
  try {
    final uri = Uri.parse("http://10.0.2.2:8000/api/bai-dang/$idBaiDang");
    final request = http.MultipartRequest('POST', uri);

    request.fields['_method'] = 'PUT'; // Laravel expects PUT via _method
    request.fields['tieu_de'] = tieuDe;
    request.fields['do_moi'] = doMoi.toString();
    request.fields['id_loai'] = idLoai.toString();
    request.fields['id_nganh'] = idNganh.toString();

    // 🧹 Gửi danh sách ảnh cần xoá (chỉ tên file)
    for (int i = 0; i < hinhAnhCanXoa.length; i++) {
      final fileName = hinhAnhCanXoa[i].split('/').last;
      request.fields['hinh_anh_can_xoa[$i]'] = fileName;
    }

    // 🖼️ Gửi ảnh mới thêm
    for (int i = 0; i < hinhAnhMoi.length; i++) {
      final file = hinhAnhMoi[i];
      final mimeType =
          lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];

      request.files.add(await http.MultipartFile.fromPath(
        'hinh_anh[$i]',
        file.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("📤 UPDATE bài đăng: ${response.statusCode} - ${response.body}");

    return response.statusCode == 200;
  } catch (e) {
    print("❌ Lỗi khi cập nhật bài đăng: $e");
    return false;
  }
}

Future<bool> deleteBaiDang(int idBaiDang) async {
  try {
    final url = Uri.parse('http://10.0.2.2:8000/api/bai-dang/$idBaiDang');

    final response = await http.delete(url);

    print("🗑️ DELETE bài đăng: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      print('⚠️ Lỗi khi xoá bài đăng. Mã lỗi: ${response.statusCode}');
      print('⚠️ Nội dung lỗi: ${response.body}');
      return false;
    }
  } catch (e) {
    print("❌ Lỗi khi gọi API xoá bài đăng: $e");
    return false;
  }
}

Future<bool> doiTrangThaiBaiDang(int idBaiDang, String trangThaiMoi) async {
  final response = await http.put(
    Uri.parse('http://10.0.2.2:8000/api/bai-dang/$idBaiDang/doi-trang-thai'),
    body: {'trang_thai': trangThaiMoi},
  );
  return response.statusCode == 200;
}
