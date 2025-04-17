import 'package:flutter/material.dart';
import 'package:frontend/screens/admin/category_management_screen.dart';
import 'package:frontend/screens/admin/product_management_screen.dart';
import 'package:frontend/screens/admin/order_management_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang quản trị'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildManagementCard(
              context,
              icon: Icons.shopping_bag,
              title: 'Quản lý sản phẩm',
              onTap: () =>
                  _navigateTo(context, const ProductManagementScreen()),
            ),
            _buildManagementCard(
              context,
              icon: Icons.category,
              title: 'Quản lý danh mục',
              onTap: () =>
                  _navigateTo(context, const CategoryManagementScreen()),
            ),
            _buildManagementCard(
              context,
              icon: Icons.receipt,
              title: 'Quản lý đơn hàng',
              onTap: () => _navigateTo(context, const AdminOrderScreen()),
            ),
            _buildManagementCard(
              context,
              icon: Icons.people,
              title: 'Quản lý người dùng',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
