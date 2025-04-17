import 'package:frontend/models/product.dart';
import 'package:frontend/services/api_service.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  Future<List<Product>> fetchProducts({
    int? page,
    int? limit,
    String? searchQuery,
    int? categoryId,
    String? sortBy,
    String? orderBy = 'desc',
  }) async {
    try {
      final response = await _apiService.get('/products', queryParams: {
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
        if (searchQuery != null) 'search': searchQuery,
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (sortBy != null) 'sort_by': sortBy,
        if (orderBy != null) 'order_by': orderBy,
      });

      if (response is! List) {
        throw Exception('Invalid response format: Expected List');
      }

      return response
          .map<Product>((productJson) => Product.fromJson(productJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to load products: ${e.toString()}');
    }
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.post('/products', data: productData);

      if (response['product'] == null) {
        throw Exception('Product data not found in response');
      }

      return Product.fromJson(response['product']);
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  Future<Product> updateProduct(
    int productId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _apiService.put(
        '/products/$productId',
        data: updateData,
      );

      if (response['product'] == null) {
        throw Exception('Updated product data not found in response');
      }

      return Product.fromJson(response['product']);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      await _apiService.delete('/products/$productId');
      return true;
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  Future<Product> getProductDetail(int productId) async {
    try {
      final response = await _apiService.get('/products/$productId');

      if (response == null) {
        throw Exception('Product not found');
      }

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get product detail: ${e.toString()}');
    }
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _apiService.get('/products', queryParams: {
        'category_id': categoryId.toString(),
      });

      if (response is! List) {
        throw Exception('Invalid response format: Expected List');
      }

      return response
          .map<Product>((productJson) => Product.fromJson(productJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to load category products: ${e.toString()}');
    }
  }
}
