import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/cart.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  /// 🧾 Tạo đơn hàng từ giỏ hàng
  Future<void> createOrder(Cart cart) async {
    try {
      final response = await _apiService.post('/orders', data: {
        'items': cart.items.map((item) {
          return {
            'product_id': item.product.id,
            'quantity': item.quantity,
            'price': item.product.price,
          };
        }).toList(),
        'total': cart.totalPrice,
      });

      if (response == null || (response is Map && response['error'] != null)) {
        throw Exception('Tạo đơn hàng thất bại');
      }
    } catch (e) {
      throw Exception('❌ Lỗi khi tạo đơn hàng: $e');
    }
  }

  /// 📋 Lấy đơn hàng người dùng hiện tại
  Future<List<dynamic>> fetchMyOrders() async {
    try {
      final response = await _apiService.get('/orders');
      if (response is List) return response;
      if (response is Map && response['data'] is List) return response['data'];
      throw Exception('Dữ liệu không hợp lệ');
    } catch (e) {
      throw Exception('❌ Lỗi khi tải đơn hàng của bạn: $e');
    }
  }

  /// 📦 Lấy tất cả đơn hàng (cho admin)
  Future<List<dynamic>> fetchAllOrders() async {
    try {
      final response = await _apiService
          .get('/admin/orders'); // ✅ sửa lại path đúng cho admin
      if (response is List) return response;
      if (response is Map && response['data'] is List) return response['data'];
      throw Exception('Dữ liệu không hợp lệ');
    } catch (e) {
      throw Exception('❌ Lỗi khi tải danh sách đơn hàng: $e');
    }
  }

  /// 🔍 Chi tiết đơn hàng theo ID
  Future<Map<String, dynamic>> fetchOrderDetail(int orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');
      if (response is Map)
        return Map<String, dynamic>.from(response); // 👈 chuẩn rồi
      throw Exception('Dữ liệu chi tiết đơn hàng không hợp lệ');
    } catch (e) {
      throw Exception('❌ Lỗi khi tải chi tiết đơn hàng: $e');
    }
  }

  /// 🔁 Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus({
    required int orderId,
    required String newStatus,
  }) async {
    try {
      final response = await _apiService.put('/orders/$orderId/status', data: {
        'status': newStatus,
      });

      if (response == null || (response is Map && response['error'] != null)) {
        throw Exception('Không thể cập nhật trạng thái đơn hàng');
      }
    } catch (e) {
      throw Exception('❌ Lỗi khi cập nhật trạng thái: $e');
    }
  }

  /// 📥 Lấy danh sách trạng thái đơn hàng từ backend
  Future<Map<String, String>> fetchOrderStatuses() async {
    try {
      final response = await _apiService.get('/order-statuses');
      if (response is Map) {
        return Map<String, String>.from(response);
      }
      throw Exception('Dữ liệu trạng thái không hợp lệ');
    } catch (e) {
      throw Exception('❌ Lỗi khi tải trạng thái đơn hàng: $e');
    }
  }
}
