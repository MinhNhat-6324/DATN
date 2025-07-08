import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'update_post_screen.dart';
import 'package:front_end/model/bai_dang_service.dart';
import 'package:front_end/Screen/product_details_screen.dart';
import 'package:front_end/services/buildImage.dart';

class MyPostScreen extends StatefulWidget {
  final String userId;

  const MyPostScreen({super.key, required this.userId});

  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  late Future<List<BaiDang>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _futurePosts = getBaiDangTheoNguoiDung(int.parse(widget.userId));
  }

  void _refreshAfterUpdate() {
    setState(() {
      _loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Bài viết của tôi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0079CF), Color(0xFF00C6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Sẵn sàng'),
              Tab(text: 'Đã cho tặng'),
            ],
          ),
        ),
        body: FutureBuilder<List<BaiDang>>(
          future: _futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0079CF)),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Đã xảy ra lỗi khi tải bài viết.'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Bạn chưa có bài đăng nào.'));
            } else {
              final posts = snapshot.data!;
              final sanSang = posts.where((e) => e.trangThai.toLowerCase() == 'san_sang').toList();
              final daChoTang = posts.where((e) => e.trangThai.toLowerCase() == 'da_cho_tang').toList();

              return TabBarView(
                children: [
                  _buildPostList(sanSang, allowActions: true),
                  _buildPostList(daChoTang, allowActions: false),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPostList(List<BaiDang> posts, {required bool allowActions}) {
    if (posts.isEmpty) {
      return const Center(child: Text('Không có bài viết nào.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: posts[index],
          userId: widget.userId,
          onPostUpdated: _refreshAfterUpdate,
          allowActions: allowActions,
        );
      },
    );
  }
}

class PostCard extends StatelessWidget {
  final BaiDang post;
  final String userId;
  final VoidCallback onPostUpdated;
  final bool allowActions;

  const PostCard({
    super.key,
    required this.post,
    required this.userId,
    required this.onPostUpdated,
    required this.allowActions,
  });

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'san_sang':
        return 'Sẵn sàng';
      case 'da_cho_tang':
        return 'Đã cho tặng';
      default:
        return status.replaceAll('_', ' ').toCapitalized();
    }
  }

  Color _getStatusColor(String status) {
    switch (_formatStatusText(status)) {
      case 'Sẵn sàng':
        return Colors.green.shade600;
      case 'Đã cho tặng':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (_formatStatusText(status)) {
      case 'Sẵn sàng':
        return Icons.check_circle;
      case 'Đã cho tặng':
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = post.anhBaiDang.isNotEmpty
        ? buildImageUrl(post.anhBaiDang[0].duongDan)
        : 'https://cdn-icons-png.flaticon.com/512/4140/4140037.png';

    final formattedStatus = _formatStatusText(post.trangThai);
    final statusColor = _getStatusColor(post.trangThai);
    final statusIcon = _getStatusIcon(post.trangThai);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              baiDang: post,
              idNguoiBaoCao: int.parse(userId),
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.tieuDe,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              formattedStatus,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                if (allowActions)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdatePostScreen(
                              idNguoiDung: int.parse(userId),
                              baiDang: post,
                            ),
                          ),
                        );
                        onPostUpdated();
                      } else if (value == 'delete') {
                        // START: Beautiful Confirmation Dialog for Delete
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Row(
                              children: [
                                const Icon(Icons.warning_rounded, color: Colors.red, size: 30),
                                const SizedBox(width: 10),
                                Text(
                                  'Xác nhận xóa',
                                  style: TextStyle(
                                      color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            content: const Text(
                              'Bạn có chắc chắn muốn xóa bài viết này không? Hành động này không thể hoàn tác.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  elevation: 5,
                                ),
                                child: const Text('Xóa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                        // END: Beautiful Confirmation Dialog for Delete

                        if (confirm == true) {
                          final success = await deleteBaiDang(post.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(success
                                  ? 'Đã xóa bài viết thành công.'
                                  : 'Xóa bài viết thất bại.'),
                              backgroundColor:
                                  success ? Colors.green : Colors.redAccent,
                            ));
                            if (success) onPostUpdated();
                          }
                        }
                      } else if (value == 'change_status') {
                        // START: Beautiful Confirmation Dialog for Change Status
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Color.fromARGB(255, 17, 155, 214), size: 30),
                                const SizedBox(width: 10),
                                Text(
                                  'Đã cho tặng?',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 17, 155, 214), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            content: const Text(
                              'Bạn có muốn xác nhận đã cho tặng bài viết này không?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 17, 155, 214), // Màu sắc phù hợp cho xác nhận
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  elevation: 5,
                                ),
                                child: const Text('Xác nhận', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                        // END: Beautiful Confirmation Dialog for Change Status

                        if (confirm == true) {
                          final success =
                              await doiTrangThaiBaiDang(post.id, 'da_cho_tang');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(success
                                  ? 'Cho tặng thành công!.'
                                  : 'Đổi trạng thái thất bại.'),
                              backgroundColor:
                                  success ? Colors.green : Colors.redAccent,
                            ));
                            if (success) onPostUpdated();
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            const Text('Chỉnh sửa', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'change_status',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.green.shade600),
                            const SizedBox(width: 8),
                            const Text('Đã cho tặng', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Text('Xóa bài viết', style: TextStyle(color: Colors.red.shade600, fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
          )
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}