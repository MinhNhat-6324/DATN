import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import để quản lý SharedPreferences
import 'post_management_screen.dart';
import 'user_management_screen.dart';
import 'pending_user_management_screen.dart';
import 'admin_registration_screen.dart';
import 'login_screen.dart'; // Import màn hình đăng nhập để điều hướng về
import 'analytics_screen.dart';
import 'notification_screen.dart';

class AdminScreen extends StatefulWidget {
  final String userId;

  const AdminScreen({super.key, required this.userId}); // Cập nhật constructo

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Hàm hiển thị hộp thoại xác nhận đăng xuất
 Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Người dùng phải nhấn nút để đóng dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          // NEW: Màu nền của dialog là trắng để tạo cảm giác sạch sẽ, dịu mắt
          backgroundColor: Colors.white, 
          title: const Text(
            'Xác nhận đăng xuất',
            style: TextStyle(
              // NEW: Màu chữ cho tiêu đề sử dụng màu xanh chủ đạo của ứng dụng
              color: Color(0xFF2280EF), 
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
            style: TextStyle(
              // NEW: Màu chữ cho nội dung là đen mờ để dễ đọc trên nền trắng
              color: Colors.black87, 
            ),
          ),
          actions: <Widget>[
            TextButton(
              // NEW: Nút Hủy màu xám trung tính, không quá nổi bật
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey.shade600, // Màu xám đậm hơn một chút
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Đóng dialog
              },
            ),
            TextButton(
              // NEW: Nút Đăng xuất màu đỏ trầm hơn, vẫn thể hiện hành động nhưng không chói
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.red.shade700, // Một sắc thái đỏ đậm hơn
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Đóng dialog trước
                await _logout(); // Thực hiện đăng xuất
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm xử lý đăng xuất
  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token'); // Xóa token
      await prefs.remove('user_id');    // Xóa user ID
      await prefs.remove('user_email'); // Xóa email
      await prefs.remove('loai_tai_khoan'); // Xóa loại tài khoản

      // Điều hướng về màn hình đăng nhập và xóa tất cả các route trước đó
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // Xóa tất cả các route trong stack
      );
    } catch (e) {
      // Xử lý lỗi nếu không thể xóa dữ liệu hoặc có vấn đề khác
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng xuất: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false, // Bỏ nút back mặc định
            backgroundColor: Colors.transparent, // Để gradient Container phía dưới hiển thị
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2280EF),
                    Color(0xFF00FFDE),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 20.0),
                  child: Image.asset(
                    'images/logo.png', // Đảm bảo đường dẫn này đúng
                    width: 60,
                    height: 60,
                    alignment: Alignment.center, // Căn logo về phía trên trái
                  ),
                ),
              ),
            ),
            // NEW: Thêm actions vào SliverAppBar
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Đăng xuất',
                onPressed: _showLogoutConfirmationDialog, // Gọi hàm xác nhận đăng xuất
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 15.0,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate(
                [
                  _buildFeatureCard(
                    context,
                    icon: Icons.people_alt_outlined,
                    label: "Quản lý Người dùng",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserManagementScreen()),
                      );
                    },
                    iconColor: const Color(0xFF0079CF),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.report_outlined,
                    label: "Báo cáo Vi phạm",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PostManagementScreen()),
                      );
                    },
                    iconColor: Colors.redAccent,
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.pending_actions,
                    label: "Tài khoản chờ duyệt",
                    onPressed: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PendingUserManagementScreen()),
                      );
                    },
                    iconColor: const Color.fromARGB(255, 232, 236, 20),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.bar_chart,
                    label: "Thống kê số lượng",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardThongKeScreen()),
                      );
                    },
                    iconColor: const Color.fromARGB(255, 94, 228, 64),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.notifications_active,
                    label: "Thông báo hệ thống",
                    onPressed: () {
                      Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NotificationScreen(userId: widget.userId),
                                ),
                              );
                    },
                    iconColor: const Color.fromARGB(255, 239, 148, 11),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.person_add,
                    label: "Tạo tài khoản Admin",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminRegistrationScreen()),
                      );
                    },
                    iconColor: const Color.fromARGB(255, 175, 26, 244),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color iconColor,
  }) {
    // Điều chỉnh _buildFeatureCard để phù hợp với định dạng mới của bạn
    // Tôi sẽ giữ lại phong cách Card đã được cung cấp trong AdminRegistrationScreen trước đó
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias, // Đảm bảo nội dung không tràn ra ngoài bo tròn
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        splashColor: iconColor.withOpacity(0.1),
        highlightColor: iconColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Tăng padding để có thêm không gian
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15), // Tăng padding cho icon container
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 34, // Tăng kích thước icon
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 15), // Tăng khoảng cách
              Expanded( // Sử dụng Expanded để Text có thể co giãn nếu dài
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17, // Giảm nhẹ kích thước chữ để vừa hơn
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2, // Giới hạn 2 dòng để tránh tràn
                  overflow: TextOverflow.ellipsis, // Hiển thị "..." nếu tràn
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
