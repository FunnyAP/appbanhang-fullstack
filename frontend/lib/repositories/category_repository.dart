import 'package:frontend/models/category.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/services/api_service.dart';

class CategoryRepository {
  final ApiService _apiService;

  CategoryRepository(this._apiService);

  Future<List<Category>> fetchCategories({
    int? page,
    int? limit,
    String? searchQuery,
    String? sortBy,
    String? orderBy = 'desc',
    bool? includeProducts,
  }) async {
    try {
      final response =
          await _apiService.dio.get('/categories', queryParameters: {
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
        if (searchQuery != null) 'search': searchQuery,
        if (sortBy != null) 'sort_by': sortBy,
        if (orderBy != null) 'order_by': orderBy,
        if (includeProducts != null)
          'include_products': includeProducts.toString(),
      });

      if (response.data is! List) {
        throw Exception('Invalid response format: Expected List');
      }

      return (response.data as List)
          .map<Category>((categoryJson) => Category.fromJson(categoryJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to load categories: ${e.toString()}');
    }
  }

  Future<Category> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await _apiService.dio.post(
        '/categories',
        data: categoryData,
      );

      if (response.data == null || response.data['category'] == null) {
        throw Exception('Category data not found in response');
      }

      return Category.fromJson(response.data['category']);
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }

  Future<Category> updateCategory(
    int categoryId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _apiService.dio.put(
        '/categories/$categoryId',
        data: updateData,
      );

      if (response.data == null || response.data['category'] == null) {
        throw Exception('Updated category data not found in response');
      }

      return Category.fromJson(response.data['category']);
    } catch (e) {
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      await _apiService.dio.delete('/categories/$categoryId');
      return true;
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  Future<Category> getCategoryDetail(int categoryId) async {
    try {
      final response = await _apiService.dio.get('/categories/$categoryId');

      if (response.data == null) {
        throw Exception('Category not found');
      }

      return Category.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get category detail: ${e.toString()}');
    }
  }

  Future<List<Product>> getCategoryProducts(int categoryId) async {
    try {
      final response =
          await _apiService.dio.get('/categories/$categoryId/products');

      if (response.data is! List) {
        throw Exception('Invalid response format: Expected List');
      }

      return (response.data as List)
          .map<Product>((productJson) => Product.fromJson(productJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to load category products: ${e.toString()}');
    }
  }
}
