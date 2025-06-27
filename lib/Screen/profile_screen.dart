// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:front_end/Screen/my_post_screen.dart';
import 'image_picker_screen.dart';
import 'package:front_end/services/tai_khoan_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front_end/Screen/login_screen.dart';
import 'package:front_end/Screen/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  final TaiKhoanService _taiKhoanService = TaiKhoanService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _taiKhoanService.getAccountById(widget.userId);
      debugPrint('Fetched user data: $data'); // Debug: In ra dữ liệu nhận được
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _changeProfilePicture() async {
    final String? imagePath = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ImagePickerScreen()),
    );

    if (imagePath != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final File imageFile = File(imagePath);
        await _taiKhoanService.updateProfilePicture(widget.userId, imageFile);
        await _fetchUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Cập nhật ảnh đại diện thành công!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error updating profile picture: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lỗi cập nhật ảnh đại diện: ${e.toString().replaceFirst('Exception: ', '')}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEditPhoneDialog(BuildContext context) {
    final TextEditingController phoneController =
        TextEditingController(text: _userData?['so_dien_thoai'] ?? '');

    bool dialogIsLoading = false; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setStateInDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Nhập số điện thoại mới',
                        hintStyle: const TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    dialogIsLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  phoneController.dispose();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Huỷ"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final newPhone = phoneController.text.trim();
                                  if (newPhone.isNotEmpty) {
                                    setStateInDialog(() { 
                                      dialogIsLoading = true;
                                    });
                                    try {
                                      await _taiKhoanService.updateAccount(
                                        widget.userId,
                                        sdt: newPhone,
                                      );
                                      await _fetchUserData();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Cập nhật số điện thoại thành công!',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            margin: const EdgeInsets.all(10),
                                          ),
                                        );
                                      }
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      debugPrint('Error updating phone: $e');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Lỗi cập nhật số điện thoại: ${e.toString().replaceFirst('Exception: ', '')}',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                            backgroundColor: Colors.redAccent,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            margin: const EdgeInsets.all(10),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setStateInDialog(() {
                                          dialogIsLoading = false;
                                        });
                                      }
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Số điện thoại không được để trống!',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor: Colors.orange,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          margin: EdgeInsets.all(10),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Lưu số"),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      phoneController.dispose();
    });
  }

  String _getGenderString(int? gender) {
    if (gender == 1) {
      return 'Nam';
    } else if (gender == 0) {
      return 'Nữ';
    }
    return 'Không xác định';
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('loai_tai_khoan');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Đăng xuất thành công!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Có lỗi xảy ra khi đăng xuất: ${e.toString().replaceFirst('Exception: ', '')}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          title: const Text(
            'Xác nhận đăng xuất',
            style: TextStyle(
              color: Color(0xFF2280EF),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                elevation: 5,
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C6FF),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white,))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                    _userData?['anh_dai_dien'] ??
                                        'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
                                  ),
                                  backgroundColor: Colors.white,
                                  onBackgroundImageError: (exception, stackTrace) {
                                    debugPrint('Error loading profile image: $exception');
                                  },
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _changeProfilePicture,
                                        icon: const Icon(Icons.image, size: 18),
                                        label: const Text("Đổi ảnh đại diện"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black87,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          elevation: 2,
                                          textStyle:
                                              const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Thông tin cá nhân
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F1E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              _InfoRow(
                                  icon: Icons.person,
                                  text: _userData?['ho_ten'] ?? 'Đang tải...'),
                              _InfoRow(
                                  icon: Icons.credit_card,
                                  text: _userData?['sinh_vien']?['lop'] ??
                                      'Chưa cập nhật'),
                              // SỬA DÒNG NÀY ĐỂ TRUY CẬP ĐÚNG TÊN CHUYÊN NGÀNH
                              _InfoRow(
                                  icon: Icons.school,
                                  text: _userData?['sinh_vien']?['chuyen_nganh'] ?? // Cập nhật cách truy cập
                                      'Chưa cập nhật'),
                              _InfoRow(
                                  icon: Icons.transgender,
                                  text: _getGenderString(_userData?['gioi_tinh'])),
                              _InfoRow(
                                  icon: Icons.email,
                                  text: _userData?['email'] ?? 'Đang tải...'),
                              _InfoRow(
                                  icon: Icons.phone_android,
                                  text: _userData?['so_dien_thoai'] ??
                                      'Chưa cập nhật',
                                  showEdit: true,
                                  onEditPressed: () => _showEditPhoneDialog(context),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            tileColor: const Color(0xFFF6F1E9),
                            leading:
                                const Icon(Icons.article, color: Colors.black87),
                            title: const Text('Bài viết của tôi'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyPostScreen()));
                            },
                          ),
                        ),

                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            tileColor: const Color(0xFFF6F1E9),
                            leading: const Icon(Icons.notifications,
                                color: Colors.black87),
                            title: const Text('Thông báo'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // TODO: Điều hướng đến trang thông báo
                            },
                          ),
                        ),

                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            tileColor: const Color(0xFFF6F1E9),
                            leading: const Icon(Icons.lock, color: Colors.black87),
                            title: const Text(
                              'Đổi mật khẩu',
                              style: TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap:() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangePasswordScreen(userId: widget.userId),
                                  ),
                                );
                              }, 
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            tileColor: const Color(0xFFF6F1E9),
                            leading: const Icon(Icons.logout, color: Colors.black87),
                            title: const Text(
                              'Đăng xuất',
                              style: TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                            onTap: _showLogoutConfirmationDialog,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool showEdit;
  final VoidCallback? onEditPressed;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.showEdit = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              if (showEdit)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: onEditPressed,
                ),
            ],
          ),
        ),
        const Divider(thickness: 1, height: 0, color: Colors.black12),
      ],
    );
  }
}