import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:front_end/services/thong_bao_service.dart';
import 'package:front_end/services/tai_khoan_service.dart';

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
  bool _biKhoa = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _kiemTraTrangThaiTaiKhoan();
  }

  Future<void> _kiemTraTrangThaiTaiKhoan() async {
    try {
      final taiKhoanData = await TaiKhoanService().getAccountById(widget.userId);
      debugPrint('Dữ liệu tài khoản: $taiKhoanData');

      final trangThai = int.tryParse(taiKhoanData['trang_thai'].toString()) ?? 0;
      debugPrint('Trạng thái tài khoản: $trangThai');

      setState(() {
        _biKhoa = trangThai == 2;
      });
    } catch (e) {
      debugPrint('Lỗi kiểm tra trạng thái tài khoản: $e');
      setState(() {
        _biKhoa = false;
      });
    }
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

  Future<void> _markAsReadAndRefresh(int index) async {
    final notification = _notifications[index];
    final int thongBaoId = notification['id_thong_bao'];
    final int daDocStatus = notification['da_doc'] ?? 0;

    if (daDocStatus == 0) {
      try {
        await _thongBaoService.markThongBaoAsRead(thongBaoId);
        setState(() {
          _notifications[index]['da_doc'] = 1;
        });
        debugPrint('Thông báo $thongBaoId đã được đánh dấu là đã đọc.');
      } catch (e) {
        debugPrint('Không thể đánh dấu đã đọc: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đánh dấu thông báo đã đọc. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showUnlockRequestDialog() async {
    final TextEditingController reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yêu cầu mở khóa tài khoản",
            style: TextStyle(color: Color(0xFF2280EF), fontWeight: FontWeight.bold, fontSize: 19)),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Nhập nội dung yêu cầu',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2280EF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Gửi yêu cầu"),
          ),
        ],
      ),
    );

    if (result == true) {
      _sendUnlockRequest(reasonController.text.trim());
    }
  }

  Future<void> _sendUnlockRequest(String content) async {
    try {
      await _thongBaoService.guiYeuCauMoKhoaTaiKhoan(
        idTaiKhoan: int.parse(widget.userId),
        noiDung: content,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Yêu cầu mở khóa đã được gửi đến quản trị viên.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      debugPrint('Lỗi gửi yêu cầu mở khóa: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể gửi yêu cầu mở khóa: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildNotificationItem(int index) {
    final notification = _notifications[index];
    final String content = notification['noi_dung'] ?? 'Không có nội dung';
    final String? createdAt = notification['thoi_gian_tao'];
    final int daDoc = notification['da_doc'] ?? 0;

    String formattedTime = '';
    if (createdAt != null) {
      try {
        final DateTime dateTime = DateTime.parse(createdAt);
        formattedTime = '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
      } catch (e) {
        debugPrint('Error parsing date: $e');
        formattedTime = createdAt;
      }
    }

    final Color cardColor = daDoc == 0 ? const Color.fromARGB(255, 173, 236, 244) : Colors.white;
    final TextStyle titleStyle = TextStyle(
      fontWeight: daDoc == 0 ? FontWeight.bold : FontWeight.normal,
      fontSize: 16,
      color: Colors.black87,
    );
    final TextStyle contentStyle = TextStyle(
      fontSize: 14,
      color: daDoc == 0 ? Colors.black87 : Colors.black54,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: cardColor,
      child: InkWell(
        onTap: () {
          _markAsReadAndRefresh(index);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_active, color: Colors.blue.shade800, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thông báo từ hệ thống', style: titleStyle),
                    const SizedBox(height: 4),
                    Text(content, style: contentStyle),
                    if (formattedTime.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          formattedTime,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
      body: Column(
        children: [
          if (_biKhoa)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_open),
                label: const Text("Gửi yêu cầu mở khóa tài khoản"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
                onPressed: _showUnlockRequestDialog,
              ),
            ),
          Expanded(
            child: _isLoading
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
                            itemBuilder: (context, index) => _buildNotificationItem(index),
                          ),
          ),
        ],
      ),
    );
  }
}
