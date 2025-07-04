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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Bài viết của tôi',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
      ),
      body: FutureBuilder<List<BaiDang>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có bài đăng nào.'));
          } else {
            final posts = snapshot.data!;

            for (var post in posts) {
              if (post.anhBaiDang.isNotEmpty) {
                final imageUrl = buildImageUrl(post.anhBaiDang[0].duongDan);
                precacheImage(CachedNetworkImageProvider(imageUrl), context);
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: posts[index],
                  userId: widget.userId,
                  onPostUpdated: _refreshAfterUpdate,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final BaiDang post;
  final String userId;
  final VoidCallback onPostUpdated;

  const PostCard({
    super.key,
    required this.post,
    required this.userId,
    required this.onPostUpdated,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'san_sang':
        return Colors.green.shade600;
      case 'dang_giao_dich':
        return Colors.orange.shade700;
      case 'hoan_thanh':
        return Colors.blue.shade700;
      case 'vi_pham':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'san_sang':
        return Icons.check_circle;
      case 'dang_giao_dich':
        return Icons.compare_arrows;
      case 'hoan_thanh':
        return Icons.done_all;
      case 'vi_pham':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'san_sang':
        return 'Sẵn sàng';
      case 'dang_giao_dich':
        return 'Đang giao dịch';
      case 'hoan_thanh':
        return 'Hoàn thành';
      case 'vi_pham':
        return 'Vi phạm';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = post.anhBaiDang.isNotEmpty
        ? buildImageUrl(post.anhBaiDang[0].duongDan)
        : 'https://cdn-icons-png.flaticon.com/512/4140/4140037.png';

    final statusColor = _getStatusColor(post.trangThai);
    final statusIcon = _getStatusIcon(post.trangThai);
    final statusLabel = _getStatusLabel(post.trangThai);

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
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image,
                          color: Colors.grey[400], size: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.tieuDe,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${post.gia} VNĐ',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 18),
                          const SizedBox(width: 6),
                          Text(statusLabel,
                              style: TextStyle(color: statusColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
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
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text(
                              'Bạn có chắc muốn xóa bài viết này không?'),
                          actions: [
                            TextButton(
                              child: const Text('Hủy'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: const Text('Xóa',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final success = await deleteBaiDang(post.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(success
                                ? 'Đã xóa bài viết thành công'
                                : 'Xóa thất bại. Vui lòng thử lại'),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ));
                          if (success) onPostUpdated();
                        }
                      }
                    } else if (value == 'change_status') {
                      if (post.trangThai.toLowerCase() == 'vi_pham') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Bài đăng hiện đang vi phạm.'),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }
                      String current = post.trangThai.toLowerCase();
                      String newStatus =
                          current == 'san_sang' ? 'dang_giao_dich' : 'san_sang';

                      final success =
                          await doiTrangThaiBaiDang(post.id, newStatus);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success
                              ? 'Đã đổi trạng thái sang "${newStatus == 'san_sang' ? 'Sẵn sàng' : 'Đang giao dịch'}"'
                              : 'Đổi trạng thái thất bại'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ));
                        if (success) onPostUpdated();
                      }
                    }
                  },
                  itemBuilder: (_) => <PopupMenuEntry<String>>[
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa')
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'change_status',
                      child: Row(children: [
                        Icon(Icons.published_with_changes),
                        SizedBox(width: 8),
                        Text('Đổi trạng thái')
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 8),
                        Text('Xóa bài viết')
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
