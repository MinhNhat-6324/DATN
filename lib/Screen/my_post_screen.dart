import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'update_post_screen.dart';
import 'package:front_end/model/bai_dang_service.dart'; // Đảm bảo đã import BaiDang và các service liên quan
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
    // Đảm bảo rằng getBaiDangTheoNguoiDung trả về Future<List<BaiDang>> và userId được parse đúng
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Bài viết của tôi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
      ),
      body: FutureBuilder<List<BaiDang>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0079CF)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 60),
                    const SizedBox(height: 15),
                    Text(
                      'Rất tiếc! Đã xảy ra lỗi khi tải bài viết.\nVui lòng thử lại sau.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadPosts,
                      icon: Icon(Icons.refresh),
                      label: Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0079CF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.feed_outlined,
                        color: Colors.grey[400], size: 80),
                    const SizedBox(height: 15),
                    Text(
                      'Bạn chưa có bài đăng nào.\nHãy tạo một bài đăng mới ngay!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          } else {
            final posts = snapshot.data!;

            for (var post in posts) {
              if (post.anhBaiDang.isNotEmpty) {
                final imageUrl = buildImageUrl(post.anhBaiDang[0].duongDan);
                precacheImage(CachedNetworkImageProvider(imageUrl), context);
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
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

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'san_sang':
        return 'Sẵn sàng';
      case 'dang_giao_dich':
        return 'Giao dịch';
      case 'hoan_thanh':
        return 'Hoàn thành';
      default:
        // Fallback for unexpected statuses, ensuring it's capitalized
        return status.replaceAll('_', ' ').toCapitalized();
    }
  }

  // Hàm mở rộng để viết hoa chữ cái đầu của mỗi từ trong chuỗi
  String _toCapitalized(String text) {
    if (text.isEmpty) return '';
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Color _getStatusColor(String status) {
    switch (_formatStatusText(status)) {
      case 'Sẵn sàng':
        return Colors.green.shade600;
      case 'Giao dịch':
        return Colors.orange.shade700;
      case 'Hoàn thành':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (_formatStatusText(status)) {
      case 'Sẵn sàng':
        return Icons.check_circle;
      case 'Giao dịch':
        return Icons.compare_arrows;
      case 'Hoàn thành':
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

    final String formattedStatus = _formatStatusText(post.trangThai);
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
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadowColor: Colors.black12.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0079CF),
                          ),
                        ),
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
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.tieuDe,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.gia, // Sử dụng giá đã được định dạng
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1),
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
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Align(
                  alignment: Alignment.topRight,
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: Colors.grey[600], size: 28),
                    splashRadius: 25,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    offset: const Offset(0, 50),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            title: const Text('Xác nhận xóa bài viết',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text(
                                'Bạn có chắc chắn muốn xóa bài viết này không? Hành động này không thể hoàn tác.'),
                            actions: [
                              TextButton(
                                child: Text('Hủy',
                                    style: TextStyle(color: Colors.grey[700])),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Xóa'),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                  SizedBox(width: 10),
                                  Text('Đang xóa bài viết...',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              backgroundColor: Colors.blueAccent,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                          final success = await deleteBaiDang(post.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                      success
                                          ? Icons.check_circle_outline
                                          : Icons.error_outline,
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                      success
                                          ? 'Đã xóa bài viết thành công!'
                                          : 'Xóa bài viết thất bại. Vui lòng thử lại.',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                              backgroundColor: success
                                  ? Colors.green[600]
                                  : Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 2),
                            ));
                            if (success) onPostUpdated();
                          }
                        }
                      } else if (value == 'change_status') {
                        String current = post.trangThai.toLowerCase();
                        String newStatus =
                            (current == 'san_sang' || current == 'sẵn sàng')
                                ? 'dang_giao_dich'
                                : 'san_sang';

                        final confirmChange = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            title: const Text('Xác nhận đổi trạng thái',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            content: Text(
                                'Bạn có muốn chuyển trạng thái bài viết này từ "${_formatStatusText(current)}" sang "${_formatStatusText(newStatus)}"?'),
                            actions: [
                              TextButton(
                                child: Text('Hủy',
                                    style: TextStyle(color: Colors.grey[700])),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0079CF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Xác nhận'),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        );

                        if (confirmChange == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                  SizedBox(width: 10),
                                  Text('Đang đổi trạng thái...',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              backgroundColor: Colors.blueAccent,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                          final success =
                              await doiTrangThaiBaiDang(post.id, newStatus);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                      success
                                          ? Icons.check_circle_outline
                                          : Icons.error_outline,
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                      success
                                          ? 'Đã đổi trạng thái thành công!'
                                          : 'Đổi trạng thái thất bại. Vui lòng thử lại.',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                              backgroundColor: success
                                  ? Colors.green[600]
                                  : Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 2),
                            ));
                            if (success) onPostUpdated();
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'edit',
                        child:
                            _buildPopupMenuItemContent(Icons.edit, 'Chỉnh sửa'),
                      ),
                      PopupMenuItem(
                        value: 'change_status',
                        child: _buildPopupMenuItemContent(
                            Icons.published_with_changes,
                            (post.trangThai.toLowerCase() == 'san_sang' ||
                                    post.trangThai.toLowerCase() == 'sẵn sàng')
                                ? 'Chuyển sang Đang giao dịch'
                                : 'Chuyển sang Sẵn sàng'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: _buildPopupMenuItemContent(
                            Icons.delete_outline, 'Xóa bài viết',
                            textColor: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenuItemContent(IconData icon, String text,
      {Color? textColor}) {
    return Row(
      children: [
        Icon(icon, color: textColor ?? Colors.grey[700]),
        const SizedBox(width: 10),
        Text(text,
            style:
                TextStyle(color: textColor ?? Colors.grey[800], fontSize: 15)),
      ],
    );
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
