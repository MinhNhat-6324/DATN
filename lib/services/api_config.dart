class ApiConfig {
  // Địa chỉ API Laravel
  // Android Emulator: 'http://10.0.2.2:8000/api'
  // Web: 'http://127.0.0.1:8000/api'
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String registerEndpoint = '/register/send-otp';
  static const String verifyOtpEndpoint = '/register/verify-otp';
  static const String resendOtpEndpoint = '/register/resend-otp';
  static const String updateProfileEndpoint = '/user/update-profile';
  static const String chuyenNganhEndpoint = '/chuyennganh'; // Nếu có
  static const String accountsEndpoint = '/tai-khoan';
  static const String pendingAccountsEndpoint = '/tai-khoan/pending';

  static const String forgotPasswordEndpoint = '/password/forgot'; // Endpoint để yêu cầu OTP
  static const String resetPasswordEndpoint = '/password/reset'; 
  static const String registerAdminEndpoint = '/register/admin'; 
}