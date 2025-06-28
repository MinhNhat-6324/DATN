// front_end/Screen/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:front_end/services/thong_bao_service.dart';
import 'package:flutter/foundation.dart'; // Thêm để dùng debugPrint
// import 'package:front_end/config/api_config.dart'; // Không cần thiết ở đây vì ThongBaoService đã xử lý

class NotificationScreen extends StatefulWidget {
  final String userId;

  const NotificationScreen({super.key, required this.userId});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ThongBaoService _thongBaoService = ThongBaoService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _thongBaoService.layThongBaoTheoTaiKhoan(int.parse(widget.userId));
      debugPrint('Fetched notifications: $data');
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Hàm để đánh dấu thông báo đã đọc và cập nhật UI
  Future<void> _markAsReadAndRefresh(int index) async {
    final notification = _notifications[index];
    // Đảm bảo khóa chính của thông báo là 'id' trong JSON trả về từ backend.
    // Nếu backend trả về 'id_thong_bao', bạn cần đổi thành notification['id_thong_bao']
    final int thongBaoId = notification['id_thong_bao']; 
    final int daDocStatus = notification['da_doc'] ?? 0; // Lấy trạng thái hiện tại

    if (daDocStatus == 0) { // Chỉ đánh dấu nếu chưa đọc
      try {
        await _thongBaoService.markThongBaoAsRead(thongBaoId);
        setState(() {
          // Cập nhật trạng thái 'da_doc' trong danh sách cục bộ
          // Điều này giúp giao diện phản hồi tức thì mà không cần gọi lại API
          _notifications[index]['da_doc'] = 1;
        });
        debugPrint('Thông báo $thongBaoId đã được đánh dấu là đã đọc trong UI.');
      } catch (e) {
        debugPrint('Không thể đánh dấu thông báo đã đọc qua API: $e');
        // Có thể hiển thị SnackBar lỗi nếu cần thông báo cho người dùng
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đánh dấu thông báo đã đọc. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00C6FF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF00C6FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Lỗi: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? const Center(
                      child: Text(
                        'Bạn chưa có thông báo nào.',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        final String content = notification['noi_dung'] ?? 'Không có nội dung';
                        final String? createdAt = notification['thoi_gian_tao'];
                        final int daDoc = notification['da_doc'] ?? 0; // Lấy trạng thái đã đọc

                        String formattedTime = '';
                        if (createdAt != null) {
                          try {
                            final DateTime dateTime = DateTime.parse(createdAt);
                            formattedTime = '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
                          } catch (e) {
                            debugPrint('Error parsing date: $e');
                            formattedTime = createdAt; // Giữ nguyên chuỗi nếu không parse được
                          }
                        }

                        // Icon và màu sắc mặc định, không phụ thuộc vào 'type'
                        IconData iconData = Icons.notifications_active; // Icon thông báo chung
                        Color iconColor = Colors.blue.shade800; // Màu xanh đậm

                        // Điều chỉnh màu nền và kiểu chữ dựa trên trạng thái đã đọc
                        final Color cardColor = daDoc == 0 ? const Color.fromARGB(255, 173, 236, 244) : Colors.white; // Màu nhạt hơn nếu chưa đọc
                        final TextStyle titleStyle = TextStyle(
                          fontWeight: daDoc == 0 ? FontWeight.bold : FontWeight.normal, // Đậm hơn nếu chưa đọc
                          fontSize: 16,
                          color: Colors.black87,
                        );
                        final TextStyle contentStyle = TextStyle(
                          fontSize: 14,
                          color: daDoc == 0 ? Colors.black87 : Colors.black54, // Đậm hơn nếu chưa đọc
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          color: cardColor, // Áp dụng màu nền
                          child: InkWell( // Sử dụng InkWell để tạo hiệu ứng chạm và bắt sự kiện onTap
                            onTap: () {
                              _markAsReadAndRefresh(index); // Đánh dấu là đã đọc khi chạm vào
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(iconData, color: iconColor, size: 28), // Sử dụng icon và màu mặc định
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Thông báo từ hệ thống', // Tiêu đề mặc định nếu không có 'tieu_de'
                                          style: titleStyle,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          content, // Nội dung chính
                                          style: contentStyle,
                                        ),
                                        if (formattedTime.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6.0),
                                            child: Text(
                                              formattedTime,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}