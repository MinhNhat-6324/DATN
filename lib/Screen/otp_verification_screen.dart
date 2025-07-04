// lib/screens/otp_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front_end/services/quen_mat_khau_service.dart';
import 'package:front_end/services/login_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String otpType; // 'registration' hoặc 'password_reset'

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.otpType,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final QuenMatKhauService _quenMatKhauService = QuenMatKhauService();
  final LoginService _loginService = LoginService();

  bool _isLoading = false;
  bool _isResending = false;
  int _countdownSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdownSeconds = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdownSeconds == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _countdownSeconds--;
        });
      }
    });
  }

  void _showMessage(String title, String message,
      {bool success = false, VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF4300FF),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: success ? Colors.greenAccent : const Color(0xFF00FFDE),
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00FFDE),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onOkPressed?.call();
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateOtp(String? otp) {
    if (otp == null || otp.isEmpty) {
      return 'Mã OTP không được để trống.';
    }
    if (otp.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return 'Mã OTP phải là 6 chữ số.';
    }
    return null;
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;

      final otpCode = _otpController.text.trim();

      if (widget.otpType == 'password_reset') {
        final responseData =
            await _quenMatKhauService.verifyResetOtp(widget.email, otpCode);

        _showMessage(
          'Thành công',
          responseData['message'] ?? 'Mã OTP đã được xác thực thành công!',
          success: true,
          onOkPressed: () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(
                    email: widget.email,
                    otpCode: otpCode,
                  ),
                ),
              );
            }
          },
        );
      } else {
        _showMessage(
          'Thông báo',
          'Tính năng xác thực OTP đăng ký chưa được tích hợp hoàn chỉnh tại đây.',
          success: true,
        );
      }
    } on Exception catch (_) {
      _showMessage('Lỗi xác thực OTP', 'Mã OTP không hợp lệ hoặc đã hết hạn.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending || !_canResend) return;

    setState(() => _isResending = true);

    try {
      if (widget.otpType == 'password_reset') {
        final responseData =
            await _quenMatKhauService.sendResetOtp(widget.email);
        _showMessage(
          'Thành công',
          responseData['message'] ?? 'Mã OTP mới đã được gửi lại!',
          success: true,
        );
      } else {
        _showMessage('Thông báo',
            'Chức năng gửi lại OTP đăng ký đang được xử lý.');
      }

      _startCountdown();
    } on Exception catch (e) {
      _showMessage('Lỗi gửi lại OTP',
          e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = 'Xác Thực OTP';
    final descriptionText =
        'Mã OTP đã được gửi đến email ${widget.email}. Vui lòng kiểm tra hộp thư đến.';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007EF4), Color(0xFF00C6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Text(
                          descriptionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          controller: _otpController,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          keyboardType: TextInputType.number,
                          animationDuration:
                              const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: const Color(0xFF4300FF),
                            inactiveFillColor:
                                const Color(0xFF4300FF).withOpacity(0.7),
                            selectedFillColor: const Color(0xFF4300FF),
                            activeColor: const Color(0xFF00FFDE),
                            inactiveColor: Colors.white54,
                            selectedColor: Colors.white,
                            errorBorderColor: Colors.redAccent,
                          ),
                          onChanged: (_) {},
                          validator: _validateOtp,
                          beforeTextPaste: (text) => true,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Xác thực OTP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _canResend && !_isResending
                                  ? _resendOtp
                                  : null,
                              child: Text(
                                _canResend
                                    ? 'Gửi lại mã'
                                    : 'Gửi lại sau ($_countdownSeconds s)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _canResend
                                      ? const Color(0xFF00FFDE)
                                      : Colors.white54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
