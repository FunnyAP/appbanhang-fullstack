import 'package:flutter/material.dart';
import 'package:frontend/repositories/order_repository.dart';
import 'package:frontend/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  late final OrderRepository _orderRepo;
  List<dynamic> _orders = [];
  Map<String, String> _statusLabels = {};
  List<String> _statuses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final api = ApiService(
      dio: Dio(),
      storage: const FlutterSecureStorage(),
    );
    _orderRepo = OrderRepository(api);

    _loadOrders();
    _loadStatuses();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await _orderRepo.fetchAllOrders();
      setState(() {
        _orders = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Lỗi khi tải đơn hàng: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStatuses() async {
    try {
      final api = ApiService(dio: Dio(), storage: const FlutterSecureStorage());
      final response = await api.get('/order-statuses');
      if (response is Map) {
        setState(() {
          _statuses = response.keys.map((e) => e.toString()).toList();
          _statusLabels = Map<String, String>.from(response);
        });
      }
    } catch (e) {
      debugPrint('❌ Không thể tải trạng thái: $e');
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      await _orderRepo.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cập nhật trạng thái thành công!')),
      );
      _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi cập nhật: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn hàng')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final id = order['id'];
                final total = order['total_price'];
                final status = order['status'];
                final createdAt = order['created_at'];

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đơn #$id - ${_formatVND(total)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Ngày tạo: $createdAt'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Trạng thái: '),
                            DropdownButton<String>(
                              value: status,
                              onChanged: (String? newStatus) {
                                if (newStatus != null && newStatus != status) {
                                  _updateStatus(id, newStatus);
                                }
                              },
                              items: _statuses.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    _statusLabels[s] ?? s,
                                    style: TextStyle(
                                      color: s == 'canceled'
                                          ? Colors.red
                                          : s == 'completed'
                                              ? Colors.green
                                              : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatVND(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}đ';
  }
}
