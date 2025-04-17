import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Hàm gọi API đăng ký
  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/register'), // URL đăng ký API
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _passwordConfirmController.text,
        'phone': _phoneController.text,
      }),
    );

    if (response.statusCode == 201) {
      // Nếu đăng ký thành công, chuyển về màn hình đăng nhập
      Navigator.pop(context);
    } else {
      // Nếu có lỗi, hiển thị thông báo
      final responseBody = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'] ?? 'Đăng ký thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo Tài Khoản")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            TextField(
              controller: _passwordConfirmController,
              decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu'),
              obscureText: true,
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Đăng Ký'),
            ),
          ],
        ),
      ),
    );
  }
}
