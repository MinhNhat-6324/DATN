import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart'; // Đảm bảo đường dẫn này đúng

// --- ĐỊNH NGHĨA CLASS TAIKHOAN ---
// Đảm bảo class TaiKhoan này khớp với cấu trúc JSON của đối tượng "tai_khoan_bao_cao"
// Nếu bạn đã định nghĩa TaiKhoan ở một file riêng (ví dụ: models/tai_khoan.dart),
// thì hãy bỏ qua phần định nghĩa này và đảm bảo bạn import nó vào đây.
// Nếu chưa có, giữ nguyên đoạn code này hoặc đưa vào một file model riêng.
class TaiKhoan {
  final int id;
  final String email;
  final String? hoTen;
  final int? gioiTinh;
  final String? anhDaiDien;
  final String? sdt;
  final int? trangThai;
  final int? loaiTaiKhoan;
  final String? createdAt;
  final String? updatedAt;

  TaiKhoan({
    required this.id,
    required this.email,
    this.hoTen,
    this.gioiTinh,
    this.anhDaiDien,
    this.sdt,
    this.trangThai,
    this.loaiTaiKhoan,
    this.createdAt,
    this.updatedAt,
  });

  factory TaiKhoan.fromJson(Map<String, dynamic> json) {
    return TaiKhoan(
      id: json['id_tai_khoan'] as int,
      email: json['email'] as String,
      hoTen: json['ho_ten'] as String?,
      gioiTinh: json['gioi_tinh'] as int?,
      anhDaiDien: json['anh_dai_dien'] as String?,
      sdt: json['so_dien_thoai'] as String?,
      trangThai: json['trang_thai'] as int?,
      loaiTaiKhoan: json['loai_tai_khoan'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

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
// --- ĐỊNH NGHĨA CLASS BAIDANG ---
// Đảm bảo rằng cấu trúc BaiDang này khớp với phần "bai_dang" trong JSON của bạn.
// Nếu chưa có, giữ nguyên đoạn code này hoặc đưa vào một file model riêng.
class BaiDang {
  final int id;
  final int idTaiKhoan;
  final String? tieuDe;
  final int? doMoi;
  final int? idLoai;
  final int? idNganh;
  final String? ngayDang;
  final List<AnhBaiDang> anhBaiDang;
  final String? trangThai;
  final String? noiDung; 
  

  BaiDang({
    required this.id,
    required this.idTaiKhoan,
    this.tieuDe,
    this.doMoi,
    this.idLoai,
    this.idNganh,
    this.ngayDang,
    required this.anhBaiDang,
    this.trangThai,
    this.noiDung, 
    
  });

  factory BaiDang.fromJson(Map<String, dynamic> json) {
    var danhSachAnh = <AnhBaiDang>[];
    if (json['anh_bai_dang'] is List) {
      danhSachAnh = (json['anh_bai_dang'] as List)
          .map((x) => AnhBaiDang.fromJson(x))
          .toList();
    }
    return BaiDang(
      id: json['id_bai_dang'] as int,
      idTaiKhoan: json['id_tai_khoan'] as int,
      tieuDe: json['tieu_de'] as String?,
      doMoi: json['do_moi'] as int?,
      idLoai: json['id_loai'] as int?,
      idNganh: json['id_nganh'] as int?,
      ngayDang: json['ngay_dang'] as String?,
      anhBaiDang: danhSachAnh,
      trangThai: json['trang_thai'] as String?,
      noiDung: json['noi_dung'] as String?,
      
    );
  }
}


// --- CẬP NHẬT CLASS BAOCAO ---
class BaoCao {
  final int id;
  final int maBaiDang;
  final int idTaiKhoanBaoCao;
  final String? lyDo;
  final String? moTaThem;
  final String? thoiGianBaoCao;
  final String? trangThai;
  final BaiDang? baiDang; 
  final TaiKhoan? nguoiBaoCao; 

  BaoCao({
    required this.id,
    required this.maBaiDang,
    required this.idTaiKhoanBaoCao,
    this.lyDo,
    this.moTaThem,
    this.thoiGianBaoCao,
    this.trangThai,
    this.baiDang,
    this.nguoiBaoCao,
  });

  factory BaoCao.fromJson(Map<String, dynamic> json) {
    return BaoCao(
      id: json['id_bao_cao'] as int,
      maBaiDang: json['ma_bai_dang'] as int,
      idTaiKhoanBaoCao: json['id_tai_khoan_bao_cao'] as int,
      lyDo: json['ly_do'] as String?,
      moTaThem: json['mo_ta_them'] as String?,
      thoiGianBaoCao: json['thoi_gian_bao_cao'] as String?,
      trangThai: json['trang_thai'] as String?,
      baiDang: json['bai_dang'] != null
          ? BaiDang.fromJson(json['bai_dang']) 
          : null,
      nguoiBaoCao: json['tai_khoan_bao_cao'] != null
          ? TaiKhoan.fromJson(json['tai_khoan_bao_cao']) 
          : null,
    );
  }
}

// --- CÁC PHƯƠNG THỨC API LIÊN QUAN ĐẾN BÁO CÁO ---

Future<void> guiBaoCao({
  required int idBaiDang,
  required int idNguoiBaoCao,
  String? lyDo,
  String? moTaThem,
}) async {
  final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.guiBaoCaoEndpoint}/$idBaiDang');

  final Map<String, dynamic> body = {
    'id_tai_khoan_bao_cao': idNguoiBaoCao,
    // Theo logic backend, trạng thái mặc định sẽ là 'dang_cho', không cần gửi
    // 'trang_thai': 'dang_cho',
    if (lyDo != null) 'ly_do': lyDo,
    if (moTaThem != null) 'mo_ta_them': moTaThem,
  };

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (response.statusCode != 201) {
    throw Exception('Gửi báo cáo thất bại: ${response.body}');
  }

  print('Gửi báo cáo thành công');
}

/// Phương thức để lấy danh sách tất cả các báo cáo từ backend.
/// Phương thức này đã trả về đối tượng BaoCao đầy đủ với baiDang và nguoiBaoCao lồng ghép.
Future<List<BaoCao>> getDanhSachBaoCao() async {
  final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.baoCaoEndpoint}'); 

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => BaoCao.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách báo cáo: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Không thể kết nối hoặc xảy ra lỗi: $e');
  }
}

// <<<<<< LOẠI BỎ HÀM capNhatTrangThaiBaoCao CŨ VÀ THÊM CÁC HÀM MỚI >>>>>>

/// Gửi yêu cầu gỡ bài đăng và duyệt báo cáo.
/// Trả về true nếu thành công, false nếu có lỗi hoặc báo cáo không ở trạng thái 'dang_cho'.
Future<bool> goBaiDangBaoCao(int baoCaoId) async {
  final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.goBaiDangEndpoint(baoCaoId)}');

  try {
    final response = await http.post(url); // Sử dụng POST method như định nghĩa backend

    if (response.statusCode == 200) { // Backend trả về 200 OK cho thành công
      print('Gỡ bài đăng và duyệt báo cáo $baoCaoId thành công.');
      return true;
    } else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final String message = responseBody['message'] ?? 'Lỗi không xác định.';
      print('Lỗi khi gỡ bài đăng và duyệt báo cáo $baoCaoId: ${response.statusCode} - $message');
      // Có thể throw Exception hoặc xử lý lỗi cụ thể hơn nếu cần
      return false;
    }
  } catch (e) {
    print('Lỗi khi gọi API gỡ bài đăng và duyệt báo cáo: $e');
    return false;
  }
}

/// Gửi yêu cầu từ chối báo cáo và duyệt nó.
/// Trả về true nếu thành công, false nếu có lỗi hoặc báo cáo không ở trạng thái 'dang_cho'.
Future<bool> tuChoiBaoCao(int baoCaoId) async {
  final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tuChoiBaoCaoEndpoint(baoCaoId)}');

  try {
    final response = await http.post(url); // Sử dụng POST method như định nghĩa backend

    if (response.statusCode == 200) { // Backend trả về 200 OK cho thành công
      print('Từ chối báo cáo $baoCaoId và duyệt thành công.');
      return true;
    } else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final String message = responseBody['message'] ?? 'Lỗi không xác định.';
      print('Lỗi khi từ chối báo cáo $baoCaoId: ${response.statusCode} - $message');
      // Có thể throw Exception hoặc xử lý lỗi cụ thể hơn nếu cần
      return false;
    }
  } catch (e) {
    print('Lỗi khi gọi API từ chối báo cáo: $e');
    return false;
  }
}


// Phương thức này có thể không cần thiết nếu getDanhSachBaoCao đã trả về baiDang lồng ghép.
// Giữ lại nếu bạn có nhu cầu lấy chi tiết riêng một bài đăng.
// Tốt nhất nên để hàm này trong một service riêng cho BaiDang nếu bạn cần nó.
Future<BaiDang> getBaiDangById(int idBaiDang) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/bai-dang/$idBaiDang'); 

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return BaiDang.fromJson(json);
    } else {
      throw Exception('Lỗi khi tải chi tiết bài đăng: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Không thể kết nối hoặc xảy ra lỗi khi tải bài đăng: $e');
  }
}

// Phương thức giả định để xóa bài đăng (nếu bạn xử lý xóa bài đăng từ báo cáo)
// Tốt nhất nên để hàm này trong một service riêng cho BaiDang nếu bạn cần nó.
Future<bool> xoaBaiDang(int idBaiDang) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/bai-dang/$idBaiDang'); 

  try {
    final response = await http.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) { 
      print('Đã xóa bài đăng $idBaiDang thành công.');
      return true;
    } else {
      print('Lỗi xóa bài đăng $idBaiDang: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Lỗi khi gọi API xóa bài đăng: $e');
    return false;
  }
}