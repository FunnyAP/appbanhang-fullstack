import 'package:dio/dio.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/models/product.dart';

class CartRepository {
  final Dio _dio;

  CartRepository(this._dio);

  /// 🔄 Lấy giỏ hàng hiện tại từ server
  Future<Cart> fetchCart() async {
    try {
      final response = await _dio.get('/cart');
      return Cart.fromJson(response.data); // ✅ mong đợi dạng {"items": [...]}
    } catch (e) {
      throw Exception('❌ Failed to fetch cart: ${e.toString()}');
    }
  }

  /// ➕ Thêm sản phẩm vào giỏ
  Future<Cart> addToCart({
    required Product product,
    int quantity = 1,
  }) async {
    try {
      final response = await _dio.post(
        '/cart',
        data: {
          'product_id': product.id,
          'quantity': quantity,
          'price': product.price, // ✅ Gửi kèm giá để tránh lỗi validate
        },
      );
      return Cart.fromJson(response.data);
    } catch (e) {
      throw Exception('❌ Failed to add to cart: ${e.toString()}');
    }
  }

  /// 🔁 Cập nhật số lượng sản phẩm trong giỏ
  Future<Cart> updateCartItem({
    required Product product,
    required int quantity,
  }) async {
    try {
      final response = await _dio.put(
        '/cart/${product.id}',
        data: {'quantity': quantity},
      );
      return Cart.fromJson(response.data);
    } catch (e) {
      throw Exception('❌ Failed to update cart item: ${e.toString()}');
    }
  }

  /// ❌ Xoá 1 sản phẩm khỏi giỏ
  Future<Cart> removeFromCart(Product product) async {
    try {
      final response = await _dio.delete('/cart/${product.id}');
      return Cart.fromJson(response.data);
    } catch (e) {
      throw Exception('❌ Failed to remove from cart: ${e.toString()}');
    }
  }

  /// 🧹 Xoá toàn bộ giỏ hàng
  Future<bool> clearCart() async {
    try {
      await _dio.delete('/cart/clear');
      return true;
    } catch (e) {
      throw Exception('❌ Failed to clear cart: ${e.toString()}');
    }
  }

  /// 📦 Lấy danh sách sản phẩm trong giỏ (dạng Product nếu cần riêng)
  Future<List<Product>> getCartProducts() async {
    try {
      final response = await _dio.get('/cart/products');
      if (response.data is! List) {
        throw Exception('❌ Invalid response format: Expected List');
      }
      return (response.data as List)
          .map<Product>((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('❌ Failed to get cart products: ${e.toString()}');
    }
  }
}
