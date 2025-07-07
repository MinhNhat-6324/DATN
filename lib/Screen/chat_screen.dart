// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'chat_detail_screen.dart';
// import 'package:front_end/model/doi_tuong_chat.dart';
// import 'package:front_end/services/api_config.dart';

// class ChatScreen extends StatefulWidget {
//   final int userId;

//   const ChatScreen({super.key, required this.userId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   List<DoiTuongChat> _chatList = [];
//   bool _isLoading = true;
//   Timer? _refreshTimer;

//   @override
//   void initState() {
//     super.initState();
//     _fetchChatList();

//     // Tự động làm mới mỗi 60 giây
//     _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _fetchChatList();
//     });
//   }

//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _fetchChatList() async {
//     try {
//       final newList =
//           await DoiTuongChatService().fetchDoiTuongChat(widget.userId);

//       if (mounted && !_listEquals(_chatList, newList)) {
//         setState(() {
//           _chatList = newList;
//           _isLoading = false;
//         });
//       } else if (_isLoading && mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Lỗi tải danh sách chat: $e');
//     }
//   }

//   // So sánh danh sách dựa trên id + tin nhắn cuối
//   bool _listEquals(List<DoiTuongChat> oldList, List<DoiTuongChat> newList) {
//     if (oldList.length != newList.length) return false;
//     for (int i = 0; i < oldList.length; i++) {
//       if (oldList[i].idTaiKhoan != newList[i].idTaiKhoan ||
//           oldList[i].tinNhanCuoi != newList[i].tinNhanCuoi) {
//         return false;
//       }
//     }
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F1E9),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         title: const Text(
//           'Tin nhắn',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF0079CF), Color(0xFF00FFDE)],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _chatList.isEmpty
//               ? const Center(child: Text('Không có tin nhắn nào.'))
//               : ListView.builder(
//                   itemCount: _chatList.length,
//                   itemBuilder: (context, index) {
//                     final chat = _chatList[index];
//                     final avatarUrl = chat.anhDaiDien != null
//                         ? '${ApiConfig.baseUrlNoApi}${chat.anhDaiDien}'
//                         : 'https://cdn-icons-png.flaticon.com/512/4140/4140037.png';

//                     return _buildChatItem(
//                       context,
//                       userIdKhac: chat.idTaiKhoan,
//                       userName: chat.hoTen,
//                       lastMessage: chat.tinNhanCuoi ?? '',
//                       avatarAsset: avatarUrl,
//                     );
//                   },
//                 ),
//     );
//   }

//   Widget _buildChatItem(
//     BuildContext context, {
//     required int userIdKhac,
//     required String userName,
//     required String lastMessage,
//     required String avatarAsset,
//   }) {
//     return GestureDetector(
//       onTap: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatDetailScreen(
//               idNguoiHienTai: widget.userId,
//               idNguoiDang: userIdKhac,
//               idBaiDang: 1, // TODO: truyền id bài đăng thật nếu có
//             ),
//           ),
//         );
//         _fetchChatList(); // Tải lại sau khi quay lại
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 3,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 28,
//               backgroundColor: Colors.grey[200],
//               backgroundImage: NetworkImage(avatarAsset),
//               onBackgroundImageError: (exception, stackTrace) {
//                 debugPrint('Lỗi tải ảnh avatar: $exception');
//               },
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     userName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF333333),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     lastMessage,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       color: Colors.grey,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
