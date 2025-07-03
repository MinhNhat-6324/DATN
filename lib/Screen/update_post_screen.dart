import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:front_end/model/chuyen_nganh_service.dart';
import 'package:front_end/model/loai_san_pham_service.dart';
import 'package:front_end/model/bai_dang_service.dart';
import 'package:front_end/services/buildImage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UpdatePostScreen extends StatefulWidget {
  final int idNguoiDung;
  final BaiDang baiDang;

  const UpdatePostScreen({
    super.key,
    required this.idNguoiDung,
    required this.baiDang,
  });

  @override
  State<UpdatePostScreen> createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();

  List<Nganh> danhSachNganh = [];
  List<LoaiSanPham> danhSachLoai = [];
  Nganh? _selectedNganh;
  LoaiSanPham? _selectedLoai;

  final List<File> _capturedImages = [];
  final List<String> _existingImageUrls = [];
  final List<String> _deletedImageUrls = []; // ✅ lưu ảnh đã xoá
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.baiDang.tieuDe;
    priceController.text = widget.baiDang.gia.toString();
    conditionController.text = widget.baiDang.doMoi.toString();
    _existingImageUrls.addAll(
        widget.baiDang.anhBaiDang.map((e) => buildImageUrl(e.duongDan)));
    _loadDropdownData();
  }

  Future<void> _luuBaiDang() async {
    if (!_formKey.currentState!.validate()) return;

    final tieuDe = titleController.text.trim();
    final gia = int.tryParse(priceController.text.trim()) ?? 0;
    final doMoi = int.tryParse(conditionController.text.trim()) ?? 0;
    final idLoai = _selectedLoai?.id;
    final idNganh = _selectedNganh?.id;

    if (idLoai == null || idNganh == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chọn đầy đủ ngành và loại sản phẩm')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await updateBaiDang(
      idBaiDang: widget.baiDang.id!,
      tieuDe: tieuDe,
      gia: gia,
      doMoi: doMoi,
      idLoai: idLoai,
      idNganh: idNganh,
      hinhAnhMoi: _capturedImages,
      hinhAnhCanXoa: _deletedImageUrls,
    );

    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cập nhật bài đăng thành công')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Cập nhật thất bại. Vui lòng thử lại')),
      );
    }
  }

  Future<void> _loadDropdownData() async {
    final nganhData = await getDanhSachNganh();
    final loaiData = await getDanhSachLoai();
    setState(() {
      danhSachNganh = nganhData;
      danhSachLoai = loaiData;
      _selectedNganh = danhSachNganh.firstWhere(
          (e) => e.id == widget.baiDang.idNganh,
          orElse: () => danhSachNganh.first);
      _selectedLoai = danhSachLoai.firstWhere(
          (e) => e.id == widget.baiDang.idLoai,
          orElse: () => danhSachLoai.first);
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _capturedImages.add(File(image.path)));
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _capturedImages.add(File(photo.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chỉnh sửa bài đăng',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0079CF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Tiêu đề bài viết'),
              _buildTextFormField(
                controller: titleController,
                hintText: 'Tiêu đề (tên sản phẩm...)',
                validator: (value) => (value == null || value.isEmpty)
                    ? '❗ Tiêu đề không được để trống'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Độ mới sản phẩm'),
              _buildTextField(
                controller: conditionController,
                keyboardType: TextInputType.number,
                suffixText: '%',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Ngành'),
              _buildDropdownButtonFormField<Nganh>(
                value: _selectedNganh,
                items: danhSachNganh,
                getLabel: (nganh) => nganh.tenNganh,
                onChanged: (Nganh? newVal) =>
                    setState(() => _selectedNganh = newVal),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Loại sản phẩm'),
              _buildDropdownButtonFormField<LoaiSanPham>(
                value: _selectedLoai,
                items: danhSachLoai,
                getLabel: (loai) => loai.tenLoai,
                onChanged: (LoaiSanPham? newVal) =>
                    setState(() => _selectedLoai = newVal),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Giá tiền'),
              _buildTextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                hintText: 'Nhập giá tiền',
                suffixText: 'VNĐ',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Ảnh đã có và ảnh mới'),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 4 : 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount:
                    _existingImageUrls.length + _capturedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index ==
                      _existingImageUrls.length + _capturedImages.length) {
                    return GestureDetector(
                      onTap: _showImageSourceActionSheet,
                      child: _buildAddImageTile(),
                    );
                  } else if (index < _existingImageUrls.length) {
                    return _buildImageTile(
                        _existingImageUrls[index], true, index);
                  } else {
                    return _buildImageTile(
                      _capturedImages[index - _existingImageUrls.length],
                      false,
                      index - _existingImageUrls.length,
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _luuBaiDang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Lưu bài viết',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageTile(dynamic image, bool isOld, int index) => Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isOld
                ? CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image,
                          color: Colors.grey[400], size: 40),
                    ),
                  )
                : Image.file(image, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() {
                if (isOld) {
                  _deletedImageUrls.add(_existingImageUrls[index]);
                  _existingImageUrls.removeAt(index);
                } else {
                  _capturedImages.removeAt(index);
                }
              }),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );

  Widget _buildTextFormField({
    required TextEditingController controller,
    String? hintText,
    String? Function(String?)? validator,
  }) =>
      Container(
        decoration: _boxDecoration(),
        child: TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: _inputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? suffixText,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      Container(
        decoration: _boxDecoration(),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffixText,
            border: _inputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      );

  Widget _buildDropdownButtonFormField<T>({
    required T? value,
    required List<T> items,
    required String Function(T) getLabel,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        decoration: _boxDecoration(),
        child: DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            border: _inputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.transparent,
          ),
          items: items
              .map((T item) =>
                  DropdownMenuItem<T>(value: item, child: Text(getLabel(item))))
              .toList(),
          onChanged: onChanged,
        ),
      );

  BoxDecoration _boxDecoration() => BoxDecoration(
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
      );

  OutlineInputBorder _inputBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      );

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      );

  Widget _buildAddImageTile() => Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
        ),
      );

  void _showImageSourceActionSheet() => showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        ),
      );
}
