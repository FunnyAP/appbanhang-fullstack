import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/product/product_bloc.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/bloc/cart/cart_bloc.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách sản phẩm')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(LoadProducts());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is ProductLoaded) {
            return ListView.builder(
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ListTile(
                    leading: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.image),
                    title: Text(product.name),
                    subtitle: Text(product.description ?? 'Không có mô tả'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        context.read<CartBloc>().add(AddToCart(product));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${product.name} đã thêm vào giỏ hàng'),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Kéo xuống để tải lại'));
        },
      ),
    );
  }
}
