import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/cart/cart_bloc.dart';
import 'package:frontend/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    height: 160, // ✅ Tăng chiều cao ảnh để tránh overflow
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 40),
                  )
                : Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child:
                        const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
          ),

          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.all(8), // ✅ Giảm padding để tránh tràn
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  product.formattedPrice,
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
                const SizedBox(height: 12),

                // Nút thêm vào giỏ hàng
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onPressed: () {
                      BlocProvider.of<CartBloc>(context)
                          .add(AddToCart(product));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('✅ Đã thêm "${product.name}" vào giỏ hàng'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Thêm vào giỏ'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
