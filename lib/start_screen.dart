import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007EF4), Color(0xFF00C6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Image(
                image: AssetImage('images/logo.png'),
                height: 250,
                width: 250,
              ),
              const SizedBox(height: 100),

              // Nút Đăng nhập
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4300FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ),
              ),

              const SizedBox(height: 20),

              // Nút Đăng ký
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4300FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                            'Đăng ký',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
