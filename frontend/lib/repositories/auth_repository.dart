import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthRepository({required this.dio, required this.storage});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      final user = response.data['user'];

      if (token == null) {
        throw Exception('Token not found in response');
      }

      await storage.write(key: 'token', value: token);
      if (user != null) {
        await storage.write(key: 'user_name', value: user['name'] ?? 'User');
        await storage.write(
          key: 'is_admin',
          value: (user['role'] == 'Admin').toString(),
        );
        await storage.write(key: 'user_email', value: email);
      }

      return {
        'status': response.statusCode ?? 200,
        'message': 'Đăng nhập thành công',
        'data': {
          'token': token,
          'user': {
            'name': user?['name'],
            'is_admin': user?['role'] == 'Admin',
          }
        }
      };
    } on DioException catch (e) {
      return {
        'status': e.response?.statusCode ?? 500,
        'message': e.response?.data?['message'] ?? 'Đăng nhập thất bại',
      };
    }
  }

  Future<bool> isAdmin() async {
    final isAdmin = await storage.read(key: 'is_admin');
    return isAdmin == 'true';
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'user_name');
    await storage.delete(key: 'is_admin');
    await storage.delete(key: 'user_email');
  }
}
