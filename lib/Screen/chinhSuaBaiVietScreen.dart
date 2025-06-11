import 'package:flutter/material.dart';

class UpdatePostScreen extends StatefulWidget {
  const UpdatePostScreen({super.key});

  @override
  State<UpdatePostScreen> createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController conditionController =
      TextEditingController(text: '99');

  String selectedCondition = 'Đã sử dụng';
  String selectedCategory = 'Chung';

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
      backgroundColor: const Color(0xFFF6F1E9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0079CF),
                    Color(0xFF00FFDE),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(
                child: Text(
                  'Chỉnh bài viết',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tiêu đề bài viết'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Tiêu đề (tên sản phẩm...)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tình trạng'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  items:
                                      ['Đã sử dụng', 'Mới'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  value: selectedCondition,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCondition = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Độ mới sản phẩm'),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: conditionController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    suffixText: '%',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
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
                                const Text('Danh mục'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  items: ['Chung', 'Sách', 'Điện tử', 'Khác']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  value: selectedCategory,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value!;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Giá tiền'),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    suffixText: 'VNĐ',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Ảnh đã chụp'),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 40),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF0079CF),
                                Color(0xFF00FFDE),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('Camera'),
                                SizedBox(width: 8),
                                Icon(Icons.camera_alt),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0056D2),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          child: const Text(
                            'Lưu',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Trang chủ'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_box), label: 'Đăng bài'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.message), label: 'Tin nhắn'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Tài khoản'),
              ],
              backgroundColor: const Color(0xFF0065F8),
              selectedItemColor: const Color(0xFF00CAFF),
              unselectedItemColor: const Color(0xFF00CAFF),
              selectedLabelStyle: const TextStyle(color: Colors.white),
              unselectedLabelStyle: const TextStyle(color: Colors.white),
              type: BottomNavigationBarType.fixed,
            ),
          ],
        ),
      ),
    );
  }
}
