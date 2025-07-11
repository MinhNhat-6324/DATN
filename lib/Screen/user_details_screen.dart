import 'package:flutter/material.dart';
import 'package:front_end/services/tai_khoan_service.dart';
import 'package:front_end/services/thong_bao_service.dart'; // Import service thông báo
import 'package:flutter/foundation.dart'; // Import for debugPrint

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TaiKhoanService _taiKhoanService = TaiKhoanService();
  final ThongBaoService _thongBaoService = ThongBaoService(); // Khởi tạo ThongBaoService
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _taiKhoanService.getAccountById(widget.userId);
      setState(() {
        _userDetails = data;
      });

      debugPrint('--- User Details Fetched Successfully ---');
      debugPrint('Full response data: ${data.toString()}');

      String? avatarUrl = _userDetails!['anh_dai_dien'];
      debugPrint('Avatar URL from backend: $avatarUrl');

      if (_userDetails!.containsKey('sinh_vien') && _userDetails!['sinh_vien'] != null) {
        String? studentCardUrl = _userDetails!['sinh_vien']['anh_the_sinh_vien'];
        debugPrint('Student Card URL from backend: $studentCardUrl');
        if (studentCardUrl != null && (Uri.tryParse(studentCardUrl)?.isAbsolute != true)) {
          debugPrint('WARNING: Student Card URL might not be absolute or valid: $studentCardUrl');
        }
      } else {
        debugPrint('SinhVien data is null or missing.');
      }
      debugPrint('---------------------------------------');

    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      debugPrint('ERROR: Failed to fetch user details: $_errorMessage');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Phương thức để cập nhật trạng thái tài khoản (kích hoạt, hạn chế, khóa)
Future<void> _updateAccountStatus(int targetStatus) async {
  if (_userDetails == null) return;

  final String hoTen = _userDetails!['ho_ten'] ?? 'người dùng này';
  final int currentTrangThaiBeforeUpdate = _userDetails!['trang_thai'] ?? 0;

  if (targetStatus == 2) {
    // Trường hợp KHÓA -> cần nhập lý do
    String lyDo = '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final TextEditingController reasonController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Xác nhận khóa tài khoản",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 21),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Nhập lý do khóa tài khoản của       $hoTen:",
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Nhập lý do...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                lyDo = reasonController.text.trim();
                if (lyDo.isEmpty) {
                  _showSnackBar("Vui lòng nhập lý do khóa!", isError: true);
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text("Khóa"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _taiKhoanService.updateAccountStatus(widget.userId, targetStatus);
        setState(() {
          _userDetails!['trang_thai'] = targetStatus;
        });

        // GỬI THÔNG BÁO CÓ LÝ DO KHÓA
        final int? idTaiKhoan = _userDetails!['id_tai_khoan'] is int
            ? _userDetails!['id_tai_khoan']
            : int.tryParse(widget.userId);

        if (idTaiKhoan != null) {
          await _thongBaoService.guiThongBaoTaiKhoan(
            idTaiKhoan: idTaiKhoan,
            trangThai: targetStatus,
            lyDo: lyDo, // Truyền thêm lý do
          );
        }

        _showSnackBar("Đã khóa tài khoản của $hoTen thành công!", isError: false);
      } catch (e) {
        _showSnackBar("Lỗi khi khóa tài khoản: ${e.toString().replaceFirst('Exception: ', '')}", isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  } 
  else {
    // Các trường hợp KHÔNG PHẢI khóa -> xử lý như cũ
    await _handleNormalStatusChange(targetStatus, hoTen, currentTrangThaiBeforeUpdate);
  }
}

// Helper tách phần còn lại (kích hoạt, mở khóa)
Future<void> _handleNormalStatusChange(int targetStatus, String hoTen, int currentTrangThaiBeforeUpdate) async {
  String actionDescription, confirmMessage, confirmButtonText;

  if (targetStatus == 0) {
    actionDescription = "chuyển về trạng thái chờ duyệt";
    confirmMessage = "Bạn có chắc chắn muốn chuyển tài khoản của $hoTen về trạng thái chờ duyệt?";
    confirmButtonText = "Chuyển";
  } else if (targetStatus == 1) {
    if (currentTrangThaiBeforeUpdate == 0) {
      actionDescription = "kích hoạt";
      confirmMessage = "Bạn có chắc chắn muốn kích hoạt tài khoản của $hoTen?";
      confirmButtonText = "Kích hoạt";
    } else {
      actionDescription = "mở khóa";
      confirmMessage = "Bạn có chắc chắn muốn mở khóa tài khoản của $hoTen?";
      confirmButtonText = "Mở khóa";
    }
  } else {
    return;
  }

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        "Xác nhận $actionDescription tài khoản",
        style: const TextStyle(color: Color(0xFF2280EF), fontWeight: FontWeight.bold),
      ),
      content: Text(confirmMessage, style: const TextStyle(color: Colors.black87)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2280EF),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmButtonText),
        ),
      ],
    ),
  );

  if (confirm == true) {
    setState(() {
      _isLoading = true;
    });

    try {
      await _taiKhoanService.updateAccountStatus(widget.userId, targetStatus);
      setState(() {
        _userDetails!['trang_thai'] = targetStatus;
      });

      final int? idTaiKhoan = _userDetails!['id_tai_khoan'] is int
          ? _userDetails!['id_tai_khoan']
          : int.tryParse(widget.userId);

      if (idTaiKhoan != null) {
        await _thongBaoService.guiThongBaoTaiKhoan(
          idTaiKhoan: idTaiKhoan,
          trangThai: targetStatus,
        );
      }

      String successMessage = (targetStatus == 0)
          ? "Đã chuyển tài khoản của $hoTen về trạng thái chờ duyệt!"
          : (currentTrangThaiBeforeUpdate == 0)
              ? "Đã kích hoạt tài khoản của $hoTen thành công!"
              : "Đã mở khóa tài khoản của $hoTen thành công!";

      _showSnackBar(successMessage, isError: false);
    } catch (e) {
      _showSnackBar("Lỗi khi $actionDescription tài khoản: ${e.toString().replaceFirst('Exception: ', '')}", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  // Phương thức để xóa tài khoản
  Future<void> _deleteUser() async {
    if (_userDetails == null) return;

    final String userName = _userDetails!['ho_ten'] ?? 'người dùng này';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          "Xác nhận xóa tài khoản",
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold), // Tiêu đề đỏ cho hành động xóa
        ),
        content: Text(
          "Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản của $userName? Hành động này không thể hoàn tác và sẽ xóa tất cả dữ liệu liên quan.",
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, // Nút đỏ cho hành động xóa
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa vĩnh viễn"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _taiKhoanService.deleteAccount(widget.userId);
        _showSnackBar("Đã xóa tài khoản của $userName thành công!");
        Navigator.pop(context, true); // Pop this screen after successful deletion
                                      // true indicates a successful deletion back to the previous screen.
      } on Exception catch (e) {
        _showSnackBar("Lỗi khi xóa tài khoản: ${e.toString().replaceFirst('Exception: ', '')}", isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isAvatarUrlValid = _userDetails?['anh_dai_dien'] != null &&
        (Uri.tryParse(_userDetails!['anh_dai_dien'])?.isAbsolute == true);

    final bool isStudentCardUrlValid = _userDetails?.containsKey('sinh_vien') == true &&
        _userDetails!['sinh_vien'] != null && 
        _userDetails!['sinh_vien']['anh_the_sinh_vien'] != null &&
        (Uri.tryParse(_userDetails!['sinh_vien']['anh_the_sinh_vien'])?.isAbsolute == true);

    // Determine status for Chip display based on trang_thai
    String statusText = 'Không xác định';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.info_outline;

    if (_userDetails != null && _userDetails!['trang_thai'] != null) {
      switch (_userDetails!['trang_thai']) {
        case 0:
          statusText = 'Chờ duyệt'; // Hiển thị 'Chờ duyệt'
          statusColor = Colors.orangeAccent;
          statusIcon = Icons.hourglass_empty;
          break;
        case 1:
          statusText = 'Đang hoạt động'; // Hiển thị 'Đang hoạt động'
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
          break;
        case 2:
          statusText = 'Bị khóa'; // Hiển thị 'Bị khóa'
          statusColor = Colors.redAccent;
          statusIcon = Icons.lock;
          break;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Thông tin người dùng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2280EF), Color(0xFF2280EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_userDetails != null && (_userDetails!['loai_tai_khoan'] ?? 0) == 0) // Only for regular user accounts (loai_tai_khoan = 0)
            PopupMenuButton<int>( // Use int for PopupMenuItem value
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (int value) {
                if (value == 99) { // Using 99 as a special value for delete
                  _deleteUser();
                } else {
                  _updateAccountStatus(value); // Call method to update status with target value
                }
              },
              itemBuilder: (BuildContext context) {
                final int currentTrangThai = _userDetails!['trang_thai'] ?? 0;
                List<PopupMenuEntry<int>> menuItems = [];

                if (currentTrangThai == 0) { // Current status is "Pending" (0)
                  menuItems.add(
                    PopupMenuItem<int>(
                      value: 1, // Activate account -> to 1 (Active)
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text('Kích hoạt tài khoản'),
                        ],
                      ),
                    ),
                  );
                  menuItems.add( // Allow deletion if in pending status
                    PopupMenuItem<int>(
                      value: 99, // Special value for delete
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('Xóa tài khoản'),
                        ],
                      ),
                    ),
                  );
                } else if (currentTrangThai == 1) { // Current status is "Active" (1)
                  menuItems.add(
                    PopupMenuItem<int>(
                      value: 2, // Lock account -> to 2 (Restricted)
                      child: Row(
                        children: [
                          Icon(Icons.lock, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('Khóa tài khoản'),
                        ],
                      ),
                    ),
                  );
                } else if (currentTrangThai == 2) { // Current status is "Restricted" (2)
                  menuItems.add(
                    PopupMenuItem<int>(
                      value: 1, // Unlock account -> to 1 (Active)
                      child: Row(
                        children: [
                          Icon(Icons.lock_open, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text('Mở khóa tài khoản'),
                        ],
                      ),
                    ),
                  );
                }
                
                // Removed the option to revert to pending (status 0) when currentTrangThai is 1 or 2
                // as per user request.

                return menuItems;
              },
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2280EF), Color(0xFF00C6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  )
                : _userDetails == null
                    ? const Center(
                        child: Text(
                          'Không tìm thấy thông tin người dùng.',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar and Name Section
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00FFDE),
                                  width: 3.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00C6FF).withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                backgroundImage: isAvatarUrlValid
                                    ? NetworkImage(_userDetails!['anh_dai_dien'])
                                    : null,
                                onBackgroundImageError: isAvatarUrlValid
                                    ? (exception, stackTrace) {
                                          debugPrint('ERROR LOADING AVATAR IMAGE: URL: ${_userDetails!['anh_dai_dien']} - Exception: $exception');
                                        }
                                    : null,
                                child: isAvatarUrlValid
                                    ? null
                                    : Text(
                                          _userDetails!['ho_ten'] != null && _userDetails!['ho_ten'].isNotEmpty
                                              ? _userDetails!['ho_ten'].substring(0, 1).toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                              color: Color(0xFF2280EF), fontWeight: FontWeight.bold, fontSize: 40),
                                        ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _userDetails!['ho_ten'] ?? 'Không có tên',
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            // Chip displaying status
                            Chip(
                              avatar: Icon(
                                statusIcon,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: Text(
                                statusText,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: statusColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            ),
                            const SizedBox(height: 30),

                            // Detailed Information Section (wrapped in a modern Card/Container)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(Icons.email, 'Email', _userDetails!['email']),
                                  _buildInfoRow(Icons.phone, 'Số điện thoại', _userDetails!['so_dien_thoai'] ?? 'N/A'),
                                  _buildInfoRow(Icons.male, 'Giới tính', _userDetails!['gioi_tinh'] == 1 ? 'Nam' : (_userDetails!['gioi_tinh'] == 0 ? 'Nữ' : 'N/A')),

                                  // Student Information (if available)
                                  if (_userDetails!.containsKey('sinh_vien') && _userDetails!['sinh_vien'] != null) ...[
                                    const Divider(height: 40, thickness: 1, color: Colors.grey),
                                    const Text(
                                      'Thông tin Sinh viên',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2280EF),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildInfoRow(Icons.school, 'Lớp', _userDetails!['sinh_vien']['lop'] ?? 'N/A'),
                                    _buildInfoRow(Icons.menu_book, 'Chuyên ngành', _userDetails!['sinh_vien']['chuyen_nganh'] ?? 'N/A'),
                                    
                                    // Student ID Card Image
                                    if (isStudentCardUrlValid) // Use valid check variable
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Ảnh thẻ sinh viên:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF666666),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Center(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.network(
                                                  _userDetails!['sinh_vien']['anh_the_sinh_vien'],
                                                  height: 200,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    debugPrint('ERROR LOADING STUDENT CARD IMAGE: URL: ${_userDetails!['sinh_vien']['anh_the_sinh_vien']} - Error: $error');
                                                    return Container(
                                                      height: 200,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
                                                          Text('Không thể tải ảnh', style: TextStyle(color: Colors.grey[500])),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  // Helper widget to build information rows
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2280EF), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}