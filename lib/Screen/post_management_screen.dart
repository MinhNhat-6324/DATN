import 'package:flutter/material.dart';

class PostManagementScreen extends StatefulWidget {
  const PostManagementScreen({super.key});

  @override
  State<PostManagementScreen> createState() => _PostManagementScreenState();
}

class _PostManagementScreenState extends State<PostManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9), // Light cream background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2280EF), Color(0xFF00FFDE)], // Blue to Turquoise gradient
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
            const Text(
              "Danh sách bài đăng vi phạm",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
        backgroundColor: Colors.transparent, // Make AppBar background transparent to show gradient
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: PostList(),
      ),
    );
  }
}

class PostList extends StatelessWidget {
  const PostList({super.key});

  final List<Map<String, dynamic>> posts = const [
    {
      "image": "https://dilib.vn/img/news/2024/05/larger/14728-dao-hai-tac-one-piece-1.jpg?v=5406",
      "title": "Vật lý đại cương",
      "price": "250.000 đ",
    },
    {
      "image": "https://dilib.vn/img/news/2024/05/larger/14728-dao-hai-tac-one-piece-1.jpg?v=5406",
      "title": "Pháp luật",
      "price": "750.000 đ",
    },
    {
      "image": "https://dilib.vn/img/news/2024/05/larger/14728-dao-hai-tac-one-piece-1.jpg?v=5406",
      "title": "Toán cao cấp A1",
      "price": "300.000 đ",
    },
    {
      "image": "https://dilib.vn/img/news/2024/05/larger/14728-dao-hai-tac-one-piece-1.jpg?v=5406",
      "title": "Lịch sử Đảng Cộng sản Việt Nam",
      "price": "180.000 đ",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostItem(
            title: post["title"],
            price: post["price"],
            imageUrl: post["image"],
          ),
        );
      },
    );
  }
}

class PostItem extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;

  const PostItem({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // Increased padding for better spacing
      decoration: BoxDecoration(
        color: const Color(0xFF00CAFF), // Bright blue for post items
        borderRadius: BorderRadius.circular(18), // Slightly more rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Softer shadow
            blurRadius: 10, // Increased blur for a smoother look
            offset: const Offset(0, 5), // Adjusted offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14), // Rounded corners for image
            child: Image.network(
              imageUrl,
              height: 180, // Slightly reduced height for compactness
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16), // Increased spacing
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20, // Slightly larger font for title
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8), // Spacing between title and price
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17, // Slightly larger font for price
              fontWeight: FontWeight.w500, // Medium font weight
            ),
          ),
          const SizedBox(height: 20), // More spacing before the button
          Align(
            alignment: Alignment.centerRight,
            child: DeleteButton(),
          ),
        ],
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // White button background
        foregroundColor: const Color(0xFF2193b0), // Darker blue for text
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Increased padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // More rounded button
        ),
        elevation: 4, // Added elevation for button
      ),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFF2193b0), // Matching dialog background
            title: const Text(
              "Xác nhận gỡ",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // Center align title
            ),
            content: const Text(
              "Bạn có chắc chắn muốn gỡ bài đăng này không?", // Added confirmation message
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceAround, // Distribute actions evenly
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Huỷ", style: TextStyle(fontSize: 16)), // Larger text
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2193b0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Gỡ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Larger and bold text
              ),
            ],
          ),
        );

        if (confirm == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã gỡ bài đăng"),
              backgroundColor: Color(0xFF00C6FF), // SnackBar matches theme
              behavior: SnackBarBehavior.floating, // Floating SnackBar
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: const Text(
        "Gỡ bài đăng",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Slightly larger and bold text
      ),
    );
  }
}