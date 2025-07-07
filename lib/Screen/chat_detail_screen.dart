// ... các import giữ nguyên
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_end/services/tai_khoan_service.dart';
import 'package:front_end/model/tin_nhan.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final int idBaiDang;
  final int idNguoiDang;
  final int idNguoiHienTai;

  const ChatDetailScreen({
    super.key,
    required this.idBaiDang,
    required this.idNguoiDang,
    required this.idNguoiHienTai,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  String? userName;
  String? avatarUrl;
  bool isLoading = true;
  List<TinNhan> tinNhans = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchNguoiDang();
    fetchTinNhan();
    _timer = Timer.periodic(const Duration(seconds: 1000), (timer) {
      fetchTinNhan();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchNguoiDang() async {
    try {
      final taiKhoanService = TaiKhoanService();
      final data =
          await taiKhoanService.getAccountById(widget.idNguoiDang.toString());

      setState(() {
        userName = data['ho_ten'] ?? 'Không rõ';
        avatarUrl = data['anh_dai_dien'] ?? '';
      });
    } catch (e) {
      setState(() {
        userName = 'Lỗi kết nối';
      });
      debugPrint('Lỗi khi fetch thông tin người đăng: $e');
    }
  }

  Future<void> fetchTinNhan() async {
    try {
      final tinNhanService = TinNhanService();
      final data = await tinNhanService.getTinNhanGiuaHaiNguoi(
        widget.idNguoiHienTai,
        widget.idNguoiDang,
      );

      setState(() {
        tinNhans = data;
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      debugPrint('Lỗi khi fetch tin nhắn: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage() async {
    final noiDung = messageController.text.trim();
    if (noiDung.isEmpty) return;

    final success = await TinNhanService().guiTinNhan(
      nguoiGui: widget.idNguoiHienTai,
      nguoiNhan: widget.idNguoiDang,
      baiDangLienQuan: widget.idBaiDang,
      noiDung: noiDung,
    );

    if (success) {
      messageController.clear();
      await fetchTinNhan();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi tin nhắn thất bại')),
      );
    }
  }

  Future<void> recallMessage(TinNhan tn) async {
    final success = await TinNhanService().thuHoiTinNhan(
      idTinNhan: tn.id,
      nguoiGui: tn.nguoiGui,
      nguoiNhan: tn.nguoiNhan,
      baiDangLienQuan: tn.baiDangLienQuan,
    );
    if (success) {
      setState(() {
        final index = tinNhans.indexWhere((msg) => msg.id == tn.id);
        if (index != -1) {
          tinNhans[index] = TinNhan(
            id: tn.id,
            nguoiGui: tn.nguoiGui,
            nguoiNhan: tn.nguoiNhan,
            baiDangLienQuan: tn.baiDangLienQuan,
            noiDung: 'đã thu hồi',
            thoiGianGui: tn.thoiGianGui,
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thu hồi tin nhắn thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              userName ?? 'Đang tải...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: tinNhans.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có tin nhắn nào.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: tinNhans.length,
                          itemBuilder: (context, index) {
                            final tn = tinNhans[index];
                            final isMe = tn.nguoiGui == widget.idNguoiHienTai;
                            final formattedTime =
                                DateFormat('HH:mm').format(tn.thoiGianGui);

                            return Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onLongPress: isMe
                                      ? () async {
                                          final selected =
                                              await showMenu<String>(
                                            context: context,
                                            position: RelativeRect.fromLTRB(
                                                200, 200, 0, 0),
                                            items: const [
                                              PopupMenuItem<String>(
                                                value: 'recall',
                                                child: Text('Thu hồi'),
                                              ),
                                            ],
                                          );
                                          if (selected == 'recall') {
                                            await recallMessage(tn);
                                          }
                                        }
                                      : null,
                                  child: MessageBubble(
                                    text: tn.noiDung,
                                    time: formattedTime,
                                    isMe: isMe,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                ),
                _buildInputBox(),
              ],
            ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn ...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF0F2F5),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF0079CF)),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRecalled = text.trim().toLowerCase() == 'đã thu hồi';

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isRecalled
                ? Colors.grey.shade300
                : isMe
                    ? const Color(0xFFE0F7FA)
                    : const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(12),
            border: isRecalled ? Border.all(color: Colors.redAccent) : null,
          ),
          child: Text(
            isRecalled ? '🛑 Tin nhắn đã được thu hồi' : text,
            style: TextStyle(
              fontStyle: isRecalled ? FontStyle.italic : FontStyle.normal,
              fontWeight: isRecalled ? FontWeight.w500 : FontWeight.normal,
              color: isRecalled
                  ? Colors.redAccent
                  : isMe
                      ? Colors.blue.shade900
                      : Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
