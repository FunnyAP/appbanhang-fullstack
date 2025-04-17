import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/cart/cart_bloc.dart';
import 'package:frontend/bloc/order/order_bloc.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/utils/currency_formatter.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
            );
          }

          if (state is CartInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartLoaded && state.cart.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          if (state is CartLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.cart.items.length,
                    itemBuilder: (context, index) {
                      final item = state.cart.items[index];
                      final imageUrl = item.product.image ?? '';

                      return ListTile(
                        leading: Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported,
                                size: 40, color: Colors.grey);
                          },
                        ),
                        title: Text(item.product.name),
                        subtitle: Text(
                          '${item.product.formattedPrice} x ${item.quantity}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                final newQuantity = item.quantity - 1;
                                context.read<CartBloc>().add(UpdateCartItem(
                                      product: item.product,
                                      quantity: newQuantity,
                                    ));
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                context
                                    .read<CartBloc>()
                                    .add(AddToCart(item.product));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${CurrencyFormatter.formatVND(state.cart.totalPrice)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showCheckoutPopup(context, state.cart);
                        },
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(
              child: Text('Không xác định trạng thái giỏ hàng'));
        },
      ),
    );
  }

  void showCheckoutPopup(BuildContext context, Cart cart) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state is OrderSuccess) {
                Navigator.pop(context); // Đóng popup
                context.read<CartBloc>().add(ClearCart());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Đặt hàng thành công!')),
                );
              } else if (state is OrderFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Lỗi: ${state.error}')),
                );
              }
            },
            builder: (context, state) {
              if (state is OrderSubmitting) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Xác nhận đơn hàng',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                      'Tổng tiền: ${CurrencyFormatter.formatVND(cart.totalPrice)}'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      context.read<OrderBloc>().add(SubmitOrder(cart));
                    },
                    label: const Text('Xác nhận thanh toán'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
