class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String registerEndpoint = '/register/send-otp';
  static const String verifyOtpEndpoint = '/register/verify-otp';
  static const String resendOtpEndpoint = '/register/resend-otp';
  static const String updateProfileEndpoint = '/user/update-profile';
  static const String chuyenNganhEndpoint = '/chuyennganh'; // Nếu có
}
