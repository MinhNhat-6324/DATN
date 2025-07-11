class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String baseUrlNoApi = 'http://10.0.2.2:8000'; // Dùng để load ảnh
  static const String registerEndpoint = '/register/send-otp';
  static const String verifyOtpEndpoint = '/register/verify-otp';
  static const String resendOtpEndpoint = '/register/resend-otp';
  static const String updateProfileEndpoint = '/user/update-profile';
  static const String chuyenNganhEndpoint = '/chuyennganh';
  static const String accountsEndpoint = '/tai-khoan';
  static const String listAccountsEndpoint = '/tai-khoan/danhsach';
  static const String pendingAccountsEndpoint = '/tai-khoan/pending';
  static const String thongKeBieuDoEndpoint = '/tai-khoan/thong-ke-bieu-do';
  static const String registerAdminEndpoint = '/register/admin';

  static const String changePasswordEndpoint = '/tai-khoan';

  static const String thongBaoTaiKhoanEndpoint = '/thongbao/tai-khoan/cap-nhat-trang-thai';
  static const String thongBaoTheoNguoiDungEndpoint = '/thongbao/nguoidung';
  static const String thongBaoEndpoint = '/thongbao';
  static const String guiYeuCauMoKhoaTaiKhoan = "/thongbao/tai-khoan/gui-yeu-cau-mo-khoa";

  static const String baoCaoEndpoint = '/bao-cao';
  static const String guiBaoCaoEndpoint = '/bao-cao/bai-dang';

   // --- Thống kê bài đăng ---
  static const String thongKeBaiDangTrangThaiEndpoint = '/bai-dang/thong-ke-trang-thai';
  static const String thongKeBaiDangChuyenNganhEndpoint = '/chuyen-nganh-san-pham/thong-ke-bai-dang';


  static String goBaiDangEndpoint(int baoCaoId) =>
      '/bao-cao/$baoCaoId/go-bai-dang';
  static String tuChoiBaoCaoEndpoint(int baoCaoId) =>
      '/bao-cao/$baoCaoId/tu-choi';

  // --- Các Endpoint cho chức năng Quên mật khẩu ---
  static const String forgotPasswordRequestEndpoint =
      '/password/forgot'; // Gửi OTP
  static const String verifyResetOtpEndpoint =
      '/password/verify-reset-otp'; // Xác thực OTP
  static const String resetPasswordEndpoint =
      '/password/reset'; // Đặt lại mật khẩu mới
}
