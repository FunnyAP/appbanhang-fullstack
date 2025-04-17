import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class ApiService {
  final Dio dio;
  final FlutterSecureStorage storage;
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  ApiService({required this.dio, required this.storage}) {
    dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          await storage.delete(key: 'token');
        }
        return handler.next(error);
      },
    ));
  }

  // ============ PRODUCT METHODS ============
  Future<List<Map<String, dynamic>>> getProducts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/products',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data is List) {
        return (response.data as List).map((item) {
          final product = _convertDynamicMap(item);
          return _processProduct(product);
        }).toList();
      }
      throw Exception('Invalid products data format');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> productData) async {
    try {
      final response = await dio.post(
        '/products',
        data: _prepareProductData(productData),
      );
      return _processProduct(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ HELPER METHODS ============
  Map<String, dynamic> _convertDynamicMap(dynamic item) {
    if (item is! Map) return {'error': 'Invalid format'};
    final Map<String, dynamic> result = {};
    item.forEach((key, value) => result[key.toString()] = value);
    return result;
  }

  Map<String, dynamic> _processProduct(Map<String, dynamic> product) {
    final price = _parseNumber(product['price']);
    return {
      ...product,
      'price': price,
      'formatted_price': NumberFormat('#,###').format(price) + 'đ',
      'discount': _parseNumber(product['discount'] ?? 0),
      'quantity': _parseNumber(product['quantity'] ?? 0),
    };
  }

  Map<String, dynamic> _prepareProductData(Map<String, dynamic> data) {
    return {
      ...data,
      'price': _parseNumber(data['price']).toString(),
      'discount': _parseNumber(data['discount'] ?? 0).toString(),
      'quantity': _parseNumber(data['quantity'] ?? 0).toString(),
    };
  }

  double _parseNumber(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
    }
    return 0.0;
  }

  dynamic _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('message')) {
        throw Exception(data['message']);
      }
      throw Exception(
        'Request failed with status: ${error.response?.statusCode}\n'
        'Error: ${error.response?.statusMessage}',
      );
    }
    throw Exception('Network error: ${error.message}');
  }

  // ============ BASIC HTTP METHODS ============
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await dio.get(endpoint, queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint,
      {required Map<String, dynamic> data}) async {
    try {
      final response = await dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint,
      {required Map<String, dynamic> data}) async {
    try {
      final response = await dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> uploadFile(String endpoint, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await dio.post(endpoint, data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
