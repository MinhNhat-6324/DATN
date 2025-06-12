import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Để làm việc với File

class UpdatePostScreen extends StatefulWidget {
  // Bạn có thể truyền dữ liệu bài viết hiện có vào đây để cập nhật
  final String? initialTitle;
  final String? initialPrice;
  final String? initialCondition;
  final String? initialConditionType;
  final String? initialCategory;
  final List<String>? initialImageUrls; // Giả sử có URL ảnh cũ

  const UpdatePostScreen({
    super.key,
    this.initialTitle,
    this.initialPrice,
    this.initialCondition,
    this.initialConditionType,
    this.initialCategory,
    this.initialImageUrls,
  });

  @override
  State<UpdatePostScreen> createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();

  String? _selectedConditionType;
  String? _selectedCategory;

  // List để lưu trữ các ảnh đã chụp/chọn
  final List<File> _capturedImages = [];
  final List<String> _existingImageUrls = []; // Để hiển thị ảnh cũ (nếu có)

  // Đối tượng ImagePicker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu cho các controller và dropdown
    titleController.text = widget.initialTitle ?? '';
    priceController.text = widget.initialPrice ?? '';
    conditionController.text = widget.initialCondition ?? '99';
    _selectedConditionType = widget.initialConditionType ?? 'Đã sử dụng';
    _selectedCategory = widget.initialCategory ?? 'Chung';

    // Thêm các URL ảnh cũ vào danh sách để hiển thị
    if (widget.initialImageUrls != null) {
      _existingImageUrls.addAll(widget.initialImageUrls!);
    }
  }

  // Hàm xử lý việc chụp ảnh
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        setState(() {
          _capturedImages.add(File(photo.path));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã chụp ảnh!',
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF00C6FF),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có ảnh nào được chụp.')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi truy cập camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể truy cập camera: $e')),
      );
    }
  }

  // Hàm xử lý việc chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _capturedImages.add(File(image.path));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã chọn ảnh từ thư viện!',
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF00C6FF),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có ảnh nào được chọn.')),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi truy cập thư viện ảnh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể truy cập thư viện ảnh: $e')),
      );
    }
  }

  void _savePost() {
    // Logic lưu bài viết
    debugPrint('Tiêu đề: ${titleController.text}');
    debugPrint('Giá: ${priceController.text}');
    debugPrint('Tình trạng: $_selectedConditionType');
    debugPrint('Độ mới: ${conditionController.text}');
    debugPrint('Danh mục: $_selectedCategory');
    debugPrint('Số lượng ảnh mới chụp/chọn: ${_capturedImages.length}');
    debugPrint('Số lượng ảnh cũ: ${_existingImageUrls.length}');

    // Thêm logic gửi dữ liệu và ảnh lên server ở đây
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu bài viết!',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00C6FF),
      ),
    );
    // Có thể pop màn hình sau khi lưu thành công
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Nền xám nhạt đồng nhất
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Chỉnh bài viết',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Nút quay lại
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0079CF), // Xanh đậm
                Color(0xFF00FFDE), // Xanh nhạt
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Tiêu đề bài viết'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: titleController,
              hintText: 'Tiêu đề (tên sản phẩm...)',
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Tình trạng'),
                      const SizedBox(height: 8),
                      _buildDropdownButtonFormField(
                        value: _selectedConditionType,
                        items: ['Đã sử dụng', 'Mới'],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedConditionType = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Độ mới sản phẩm'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: conditionController,
                        keyboardType: TextInputType.number,
                        suffixText: '%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Danh mục'),
                      const SizedBox(height: 8),
                      _buildDropdownButtonFormField(
                        value: _selectedCategory,
                        items: ['Chung', 'Sách', 'Điện tử', 'Khác'],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Giá tiền'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        suffixText: 'VNĐ',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Ảnh đã có và ảnh mới'),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _existingImageUrls.length + _capturedImages.length + 1, // +1 cho nút thêm ảnh
              itemBuilder: (context, index) {
                // Nếu đây là ô cuối cùng, hiển thị nút thêm ảnh
                if (index == _existingImageUrls.length + _capturedImages.length) {
                  return GestureDetector(
                    onTap: () {
                      _showImageSourceActionSheet(context); // Hiển thị tùy chọn Camera/Thư viện
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                      ),
                    ),
                  );
                }
                // Nếu là ảnh cũ
                else if (index < _existingImageUrls.length) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _existingImageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _existingImageUrls.removeAt(index); // Xóa ảnh cũ
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                // Nếu là ảnh mới chụp/chọn
                else {
                  final imageIndex = index - _existingImageUrls.length;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _capturedImages[imageIndex],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _capturedImages.removeAt(imageIndex); // Xóa ảnh mới
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePost, // Gọi hàm lưu bài viết
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2), // Màu xanh đậm
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Lưu bài viết',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper cho tiêu đề phần
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  // Helper cho TextField
  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          suffixText: suffixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none, // Bỏ viền mặc định
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.transparent, // Nền trong suốt để container show màu
        ),
      ),
    );
  }

  // Helper cho DropdownButtonFormField
  Widget _buildDropdownButtonFormField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none, // Bỏ viền mặc định
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.transparent, // Nền trong suốt để container show màu
        ),
        items: items.map((String val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Hiển thị ActionSheet để chọn nguồn ảnh
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}